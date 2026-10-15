import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/classification_repository.dart';
import '../../domain/models/classification_result.dart';

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
  final ClassificationRepository _repository;
  final ImagePicker _picker = ImagePicker();

  ClassificationController(this._repository)
      : super(const ClassificationState()) {
    loadHistory();
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
            errorMessage: 'Image size exceeds 5 MB. Please select a smaller photo.',
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
      final result = await _repository.classifyImage(
        bytes: bytes,
        filename: name,
      );

      // Prepend to history if automatically saved on backend
      final updatedHistory = List<ClassificationResult>.from(state.history);
      if (result.saved && result.scanId != null) {
        updatedHistory.insert(0, result);
      }

      state = state.copyWith(
        isClassifying: false,
        latestResult: result,
        history: updatedHistory,
        successMessage: result.saved
            ? 'Scan complete! Record automatically archived to your audit history.'
            : 'Scan complete! (Guest mode: temporary preview only).',
      );
    } catch (e) {
      state = state.copyWith(
        isClassifying: false,
        errorMessage: 'Classification failed: ${e.toString()}',
      );
    }
  }

  /// Load user's scan history from PostgreSQL
  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      final list = await _repository.fetchHistory();
      state = state.copyWith(
        history: list,
        isLoadingHistory: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        // Suppress initial history error if not authenticated or offline
      );
    }
  }

  /// Delete a scan from user history
  Future<void> deleteScan(int scanId) async {
    state = state.copyWith(deletingScanId: scanId, clearError: true);
    try {
      await _repository.deleteScan(scanId);
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
}

final classificationControllerProvider =
    StateNotifierProvider<ClassificationController, ClassificationState>((ref) {
  final repo = ref.watch(classificationRepositoryProvider);
  return ClassificationController(repo);
});
