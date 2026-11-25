import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/services/classification/classification_service.dart';

import 'widget_test.dart' show FakeClassificationRepository, kValidPngBytes;

class _BatchService extends FakeClassificationRepository {
  final started = <String>[];
  final first = Completer<ClassificationResult>();

  @override
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
    String regionType = 'eye',
  }) async {
    expect(regionType, 'auto');
    started.add(filename);
    if (filename == 'first.png') return first.future;
    if (filename == 'whole.png') {
      throw const ClassificationApiException(
        code: 'WHOLE_TILAPIA_CLOSE_UP_REQUIRED',
        message: 'Find an eye.',
        statusCode: 422,
      );
    }
    return const ClassificationResult(
      scanId: 2,
      label: 'Not Fresh',
      confidence: 0.9,
      regionType: 'gill',
      saved: true,
    );
  }
}

void main() {
  test('runs one scan at a time and continues past a whole fish', () async {
    final service = _BatchService();
    final controller = ClassificationController(service);
    addTearDown(controller.dispose);
    final work = controller.processBatch([
      for (final name in ['first.png', 'whole.png', 'last.png'])
        XFile.fromData(kValidPngBytes, name: name, path: name),
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(service.started, ['first.png']);
    expect(controller.state.isBatchRunning, isTrue);
    service.first.complete(
      const ClassificationResult(
        scanId: 1,
        label: 'Fresh',
        confidence: 0.95,
        regionType: 'eye',
        saved: true,
      ),
    );
    await work;
    expect(service.started, ['first.png', 'whole.png', 'last.png']);
    expect(controller.state.batchScans.map((item) => item.status), [
      BatchScanStatus.complete,
      BatchScanStatus.needsReview,
      BatchScanStatus.complete,
    ]);
    expect(controller.state.history.map((result) => result.scanId), [2, 1]);
    expect(controller.state.isBatchRunning, isFalse);
    await controller.openBatchPhoto(1);
    expect(controller.state.selectedImageName, 'whole.png');
    expect(controller.state.selectedRegion, AnatomicalRegion.auto);
    controller.confirmCroppedRegion(kValidPngBytes);
    await controller.classify();
    expect(controller.state.batchScans[1].status, BatchScanStatus.complete);
    expect(controller.state.batchScans[1].result?.label, 'Not Fresh');
  });
}
