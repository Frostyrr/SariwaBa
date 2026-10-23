import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/classification/classification_result.dart';
import '../../services/classification/classification_service.dart';
import '../../services/storage/guest_history_cache.dart';
import '../auth/auth_controller.dart';

class ClassificationState {
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;
  final bool isClassifying;
  final ClassificationResult? latestResult;
  final List<ClassificationResult> history;
  final bool isLoadingHistory;
  final int? deletingScanId;
  final String? errorMessage;
  final String? successMessage;

  const ClassificationState({
    this.selectedImageBytes,
    this.selectedImageName,
    this.isClassifying = false,
    this.latestResult,
    this.history = const [],
    this.isLoadingHistory = false,
    this.deletingScanId,
    this.errorMessage,
    this.successMessage,
  });

  ClassificationState copyWith({
    Uint8List? selectedImageBytes,
    String? selectedImageName,
    bool clearImage = false,
    bool? isClassifying,
    ClassificationResult? latestResult,
    bool clearResult = false,
    List<ClassificationResult>? history,
    bool? isLoadingHistory,
    int? deletingScanId,
    bool clearDeleting = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ClassificationState(
      selectedImageBytes:
          clearImage ? null : (selectedImageBytes ?? this.selectedImageBytes),
      selectedImageName:
          clearImage ? null : (selectedImageName ?? this.selectedImageName),
      isClassifying: isClassifying ?? this.isClassifying,
      latestResult:
          clearResult ? null : (latestResult ?? this.latestResult),
      history: history ?? this.history,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      deletingScanId:
          clearDeleting ? null : (deletingScanId ?? this.deletingScanId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class ClassificationController extends StateNotifier<ClassificationState> {
  final ClassificationService _service;
  final GuestHistoryCache _guestCache;
  final bool _isAuthenticated;
  final ImagePicker _picker = ImagePicker();

  ClassificationController(
    this._service, {
    GuestHistoryCache? guestCache,
    bool autoLoadHistory = true,
  })  : _guestCache = guestCache ?? GuestHistoryCache(),
        _isAuthenticated = autoLoadHistory,
        super(const ClassificationState()) {
    if (_isAuthenticated) {
      loadHistory();
    } else {
      loadGuestCache();
    }
  }

  /// Load guest scans from local cache
  Future<void> loadGuestCache() async {
    final cached = await _guestCache.getCachedHistory();
    if (mounted) {
      state = state.copyWith(
        history: cached,
        isLoadingHistory: false,
      );
    }
  }

  /// Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();

        // 5 MB file size limit check
        const maxBytes = 5 * 1024 * 1024;
        if (bytes.lengthInBytes > maxBytes) {
          state = state.copyWith(
            errorMessage:
                'Image size exceeds 5 MB. Please select a smaller photo.',
            clearSuccess: true,
          );
          return;
        }

        state = state.copyWith(
          selectedImageBytes: bytes,
          selectedImageName: picked.name,
          clearError: true,
          clearResult: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unable to select image: ${e.toString()}',
      );
    }
  }

  /// Clear the currently selected image
  void clearSelection() {
    state = state.copyWith(
      clearImage: true,
      clearResult: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  /// Run AI classification against backend
  Future<void> classify() async {
    final bytes = state.selectedImageBytes;
    final name = state.selectedImageName ?? 'fish_scan.jpg';

    if (bytes == null) {
      state = state.copyWith(
        errorMessage: 'Please select or capture a fish image first.',
      );
      return;
    }

    state = state.copyWith(
      isClassifying: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final result = await _service.classifyImage(
        bytes: bytes,
        filename: name,
      );

      List<ClassificationResult> updatedHistory;
      if (result.saved && result.scanId != null) {
        updatedHistory = List<ClassificationResult>.from(state.history)
          ..insert(0, result);
      } else {
        // Guest Mode: save to local cache (up to 10 recent scans)
        updatedHistory = await _guestCache.addScan(result);
      }

      state = state.copyWith(
        isClassifying: false,
        latestResult: result,
        history: updatedHistory,
        successMessage: result.saved
            ? 'Scan complete! Record automatically saved to your classification history.'
            : 'Scan complete! Cached locally in Guest Mode (sign in to back up permanently).',
      );
    } catch (e) {
      state = state.copyWith(
        isClassifying: false,
        errorMessage: 'Classification failed: ${e.toString()}',
      );
    }
  }

  /// Load user's scan history (or local guest cache when in Guest Mode)
  Future<void> loadHistory() async {
    if (!_isAuthenticated) {
      await loadGuestCache();
      return;
    }

    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      final list = await _service.fetchHistory();
      if (mounted) {
        state = state.copyWith(
          history: list,
          isLoadingHistory: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoadingHistory: false,
        );
      }
    }
  }

  /// Delete a scan from user history or local guest cache
  Future<void> deleteScan(int scanId) async {
    state = state.copyWith(deletingScanId: scanId, clearError: true);
    try {
      if (!_isAuthenticated || scanId < 0) {
        final updated = await _guestCache.removeScan(scanId);
        state = state.copyWith(
          history: updated,
          clearDeleting: true,
          successMessage: 'Scan removed from temporary guest cache.',
        );
        return;
      }

      await _service.deleteScan(scanId);
      final updated = state.history.where((s) => s.scanId != scanId).toList();
      state = state.copyWith(
        history: updated,
        clearDeleting: true,
        successMessage: 'Scan #$scanId permanently removed.',
      );
    } catch (e) {
      state = state.copyWith(
        clearDeleting: true,
        errorMessage: 'Could not delete scan: ${e.toString()}',
      );
    }
  }

  /// Clear all locally cached guest scans
  Future<void> clearGuestCache() async {
    await _guestCache.clearCache();
    state = state.copyWith(
      history: const [],
      successMessage: 'Temporary guest scan cache cleared.',
    );
  }
}

final classificationControllerProvider =
    StateNotifierProvider<ClassificationController, ClassificationState>((ref) {
  final service = ref.watch(classificationServiceProvider);
  final guestCache = ref.watch(guestHistoryCacheProvider);
  final isAuthenticated =
      ref.watch(authControllerProvider.select((s) => s.isAuthenticated));
  return ClassificationController(
    service,
    guestCache: guestCache,
    autoLoadHistory: isAuthenticated,
  );
});
