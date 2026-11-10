import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/controllers/auth/auth_state.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/storage/guest_history_cache.dart';

import 'widget_test.dart' show FakeClassificationRepository, kValidPngBytes;

class GuestService extends FakeClassificationRepository {
  int historyCalls = 0;
  int deleteCalls = 0;
  @override
  Future<List<ClassificationResult>> fetchHistory() async {
    historyCalls++;
    return [];
  }

  @override
  Future<void> deleteScan(int scanId) async {
    deleteCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Guest mode routes directly to dashboard', () {
    expect(
      AppRoutes.pathForStatus(AuthViewStatus.guestMode),
      AppRoutes.dashboard,
    );
  });

  test(
    'Guest scans persist locally, reload and delete without server history',
    () async {
      final service = GuestService()
        ..resultToReturn = ClassificationResult(
          label: 'Fresh',
          confidence: .96,
          saved: false,
          regionType: 'eye',
          modelVersion: 'test-model',
          regionVerified: false,
        );
      final controller = ClassificationController(
        service,
        isAuthenticated: false,
      );
      addTearDown(controller.dispose);
      await controller.loadHistory();
      controller.setSelectedImage(bytes: kValidPngBytes, filename: 'eye.png');
      controller.confirmFullImageAsCloseUp();
      await controller.classify();
      expect(controller.state.history, hasLength(1));
      final restored = await GuestHistoryCache().getCachedHistory();
      expect(restored, hasLength(1));
      expect(restored.single.saved, isFalse);
      expect(restored.single.scanId, isNegative);
      expect(restored.single.modelVersion, 'test-model');
      expect(restored.single.regionType, 'eye');
      await controller.deleteScan(restored.single.scanId!);
      expect(await GuestHistoryCache().getCachedHistory(), isEmpty);
      expect(service.historyCalls, 0);
      expect(service.deleteCalls, 0);
    },
  );

  test('Guest cache retains only the latest ten scans', () async {
    final cache = GuestHistoryCache();
    for (var i = 0; i < 12; i++) {
      await cache.addScan(ClassificationResult(label: '$i', confidence: .9));
    }
    final records = await GuestHistoryCache().getCachedHistory();
    expect(records, hasLength(10));
    expect(records.first.label, '11');
    expect(records.last.label, '2');
  });
}
