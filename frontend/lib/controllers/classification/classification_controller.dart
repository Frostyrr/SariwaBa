import '../auth/auth_controller.dart';
import '../../services/storage/guest_history_cache.dart';

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/classification/classification_result.dart';
import '../../services/classification/classification_service.dart';

/// Conceptual workflow states for the Live Freshness Inspection pipeline.
enum ClassificationWorkflowStage {
  initial,
  imageUploading,
  imageSelected,
  regionSelected,
  cropEditing,
  cropConfirmed,
  processing,
  classificationSuccess,
  validationRejected,
  networkOrServerError,
}

class ClassificationState {
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;
  final AnatomicalRegion? selectedRegion;
  final Uint8List? confirmedImageBytes;
  final bool isCropConfirmed;
  final bool isFullImageConfirmed;
  final bool isEditingCrop;
  final Rect? lastCropNormalizedRect;
  final bool isUploadingImage;
  final bool isClassifying;
  final String? processingStage;
  final ClassificationResult? latestResult;
  final List<ClassificationResult> history;
  final bool isLoadingHistory;
  final int? deletingScanId;
  final String? errorMessage;
  final String? errorCode;
  final bool isInputRejection;
  final String? successMessage;

  const ClassificationState({
    this.selectedImageBytes,
    this.selectedImageName,
    this.selectedRegion = AnatomicalRegion.eye,
    this.confirmedImageBytes,
    this.isCropConfirmed = false,
    this.isFullImageConfirmed = false,
    this.isEditingCrop = false,
    this.lastCropNormalizedRect,
    this.isUploadingImage = false,
    this.isClassifying = false,
    this.processingStage,
    this.latestResult,
    this.history = const [],
    this.isLoadingHistory = false,
    this.deletingScanId,
    this.errorMessage,
    this.errorCode,
    this.isInputRejection = false,
    this.successMessage,
  });

  bool get hasSelectedImage => selectedImageBytes != null;
  bool get hasSelectedRegion => selectedRegion != null;
  bool get isReadyToClassify =>
      hasSelectedImage &&
      hasSelectedRegion &&
      isCropConfirmed &&
      confirmedImageBytes != null;

  /// Current conceptual stage in the classification state machine.
  ClassificationWorkflowStage get workflowStage {
    if (isUploadingImage) {
      return ClassificationWorkflowStage.imageUploading;
    }
    if (isClassifying) {
      return ClassificationWorkflowStage.processing;
    }
    if (errorMessage != null) {
      return isInputRejection
          ? ClassificationWorkflowStage.validationRejected
          : ClassificationWorkflowStage.networkOrServerError;
    }
    if (latestResult != null) {
      return ClassificationWorkflowStage.classificationSuccess;
    }
    if (isCropConfirmed && confirmedImageBytes != null) {
      return ClassificationWorkflowStage.cropConfirmed;
    }
    if (hasSelectedImage && isEditingCrop) {
      return ClassificationWorkflowStage.cropEditing;
    }
    if (hasSelectedImage && hasSelectedRegion) {
      return ClassificationWorkflowStage.regionSelected;
    }
    if (hasSelectedImage) {
      return ClassificationWorkflowStage.imageSelected;
    }
    return ClassificationWorkflowStage.initial;
  }

  ClassificationState copyWith({
    Uint8List? selectedImageBytes,
    String? selectedImageName,
    bool clearImage = false,
    AnatomicalRegion? selectedRegion,
    bool clearRegion = false,
    Uint8List? confirmedImageBytes,
    bool clearConfirmedImage = false,
    bool? isCropConfirmed,
    bool? isFullImageConfirmed,
    bool? isEditingCrop,
    Rect? lastCropNormalizedRect,
    bool clearCropRect = false,
    bool? isUploadingImage,
    bool? isClassifying,
    String? processingStage,
    bool clearProcessingStage = false,
    ClassificationResult? latestResult,
    bool clearResult = false,
    List<ClassificationResult>? history,
    bool? isLoadingHistory,
    int? deletingScanId,
    bool clearDeleting = false,
    String? errorMessage,
    String? errorCode,
    bool? isInputRejection,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ClassificationState(
      selectedImageBytes: clearImage
          ? null
          : (selectedImageBytes ?? this.selectedImageBytes),
      selectedImageName: clearImage
          ? null
          : (selectedImageName ?? this.selectedImageName),
      selectedRegion: clearRegion
          ? AnatomicalRegion.eye
          : (selectedRegion ?? this.selectedRegion),
      confirmedImageBytes: clearImage || clearConfirmedImage
          ? null
          : (confirmedImageBytes ?? this.confirmedImageBytes),
      isCropConfirmed: clearImage || clearConfirmedImage
          ? false
          : (isCropConfirmed ?? this.isCropConfirmed),
      isFullImageConfirmed: clearImage || clearConfirmedImage
          ? false
          : (isFullImageConfirmed ?? this.isFullImageConfirmed),
      isEditingCrop: clearImage ? false : (isEditingCrop ?? this.isEditingCrop),
      lastCropNormalizedRect: clearImage || clearCropRect
          ? null
          : (lastCropNormalizedRect ?? this.lastCropNormalizedRect),
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isClassifying: isClassifying ?? this.isClassifying,
      processingStage: clearProcessingStage
          ? null
          : (processingStage ?? this.processingStage),
      latestResult: clearResult ? null : (latestResult ?? this.latestResult),
      history: history ?? this.history,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      deletingScanId: clearDeleting
          ? null
          : (deletingScanId ?? this.deletingScanId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      isInputRejection: clearError
          ? false
          : (isInputRejection ?? this.isInputRejection),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class ClassificationController extends StateNotifier<ClassificationState> {
  final ClassificationService _service;
  final ImagePicker _picker;
  final GuestHistoryCache _guestCache;
  final bool isAuthenticated;
  int _activeRequestId = 0;

  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  ClassificationController(
    this._service, {
    ImagePicker? picker,
    GuestHistoryCache? guestCache,
    this.isAuthenticated = true,
  }) : _guestCache = guestCache ?? GuestHistoryCache(),
       _picker = picker ?? ImagePicker(),
       super(const ClassificationState()) {
    loadHistory();
  }

  /// Public convenience getter so widgets can check readiness after synchronous confirmation
  bool get isReadyToClassify => state.isReadyToClassify;

  static bool isHeicHeader(Uint8List bytes) {
    if (bytes.length < 12) return false;
    final hasFtyp =
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70;
    if (!hasFtyp) return false;
    final headerAscii = String.fromCharCodes(
      bytes.sublist(8, bytes.length < 32 ? bytes.length : 32),
    ).toLowerCase();
    const heicBrands = [
      'heic',
      'heix',
      'hevc',
      'hevx',
      'heim',
      'heis',
      'hevm',
      'hevs',
      'mif1',
      'msf1',
    ];
    return heicBrands.any(headerAscii.contains);
  }

  static bool isSupportedImageFormat(Uint8List bytes, String filename) {
    final lower = filename.trim().toLowerCase();
    final hasAllowedExtension =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.heif');

    final isPngHeader =
        bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isJpegHeader =
        bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;

    // Require a valid JPEG/PNG byte signature and (if an extension is present) a supported extension
    if (!isPngHeader && !isJpegHeader && !isHeicHeader(bytes)) {
      return false;
    }
    if (lower.contains('.') && !hasAllowedExtension) {
      return false;
    }
    return true;
  }

  /// Set image uploading loading state manually when necessary
  void setUploadingImage(bool isUploading) {
    state = state.copyWith(isUploadingImage: isUploading);
  }

  /// Pick image from gallery or camera with an explicit loading state
  Future<void> pickImage(ImageSource source) async {
    state = state.copyWith(isUploadingImage: true, clearError: true);
    try {
      final picked = await _picker.pickImage(source: source);

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setSelectedImage(bytes: bytes, filename: picked.name);
      }
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Unable to select image. Please try another photo.',
        errorCode: 'INVALID_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
    } finally {
      if (mounted) {
        state = state.copyWith(isUploadingImage: false);
      }
    }
  }

  /// Validate and set selected image bytes (usable by both ImagePicker and tests)
  void setSelectedImage({required Uint8List bytes, required String filename}) {
    if (bytes.isEmpty) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'The selected image file is empty.',
        errorCode: 'EMPTY_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (bytes.lengthInBytes > maxFileSizeBytes) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Image size exceeds 5 MB. Please select a smaller photo.',
        errorCode: 'IMAGE_TOO_LARGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (!isSupportedImageFormat(bytes, filename)) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Unsupported image format. Only JPG, JPEG, PNG, and HEIC images are allowed.',
        errorCode: 'UNSUPPORTED_IMAGE_TYPE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    // Invalidate any in-flight classification request from a previous selection
    _activeRequestId++;

    state = state.copyWith(
      selectedImageBytes: bytes,
      selectedImageName: filename,
      selectedRegion: state.selectedRegion ?? AnatomicalRegion.eye,
      isUploadingImage: false,
      isClassifying: false,
      isEditingCrop: false,
      clearProcessingStage: true,
      clearConfirmedImage: true,
      clearCropRect: true,
      clearError: true,
      clearSuccess: true,
      clearResult: true,
    );
  }

  /// Select the target Tilapia anatomical region (Eye or Gill)
  void selectRegion(AnatomicalRegion region) {
    final regionChanged = state.selectedRegion != region;
    if (regionChanged) {
      _activeRequestId++;
    }
    state = state.copyWith(
      selectedRegion: region,
      isClassifying: regionChanged ? false : state.isClassifying,
      isEditingCrop: false,
      clearProcessingStage: regionChanged,
      clearConfirmedImage: regionChanged,
      clearError: true,
      clearSuccess: true,
      clearResult: regionChanged,
    );
  }

  /// Switch to the alternate anatomical region (Eye <-> Gill) during rejection recovery
  void changeRegion() {
    final nextRegion = state.selectedRegion == AnatomicalRegion.eye
        ? AnatomicalRegion.gill
        : AnatomicalRegion.eye;
    selectRegion(nextRegion);
  }

  /// Confirm a manually cropped anatomical region
  void confirmCroppedRegion(
    Uint8List croppedBytes, {
    Rect? normalizedCropRect,
  }) {
    if (state.selectedImageBytes == null) {
      state = state.copyWith(
        errorMessage: 'Please select or capture a Tilapia image first.',
        errorCode: 'MISSING_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (state.selectedRegion == null) {
      state = state.copyWith(
        errorMessage: 'Please select an anatomical region (Eye or Gill) before confirming the crop.',
        errorCode: 'INVALID_REGION_TYPE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (croppedBytes.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Unable to generate cropped image region.',
        errorCode: 'EMPTY_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (croppedBytes.lengthInBytes > maxFileSizeBytes) {
      state = state.copyWith(
        errorMessage: 'Cropped image exceeds the 5 MB limit.',
        errorCode: 'IMAGE_TOO_LARGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    _activeRequestId++;

    state = state.copyWith(
      confirmedImageBytes: croppedBytes,
      isCropConfirmed: true,
      isFullImageConfirmed: false,
      isEditingCrop: false,
      lastCropNormalizedRect: normalizedCropRect,
      isClassifying: false,
      clearProcessingStage: true,
      clearError: true,
      clearSuccess: true,
      clearResult: true,
    );
  }

  /// Confirm the entire uploaded image when it is already a suitable Eye or Gill close-up
  void confirmFullImageAsCloseUp() {
    final bytes = state.selectedImageBytes;
    if (bytes == null) {
      state = state.copyWith(
        errorMessage: 'Please select or capture a Tilapia image first.',
        errorCode: 'MISSING_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (state.selectedRegion == null) {
      state = state.copyWith(
        errorMessage: 'Please select an anatomical region (Eye or Gill) before confirming the image.',
        errorCode: 'INVALID_REGION_TYPE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    _activeRequestId++;

    state = state.copyWith(
      confirmedImageBytes: bytes,
      isCropConfirmed: true,
      isFullImageConfirmed: true,
      isEditingCrop: false,
      lastCropNormalizedRect: const Rect.fromLTWH(0, 0, 1, 1),
      isClassifying: false,
      clearProcessingStage: true,
      clearError: true,
      clearSuccess: true,
      clearResult: true,
    );
  }

  /// Re-open the interactive crop editor to adjust framing or zoom
  void editCrop() {
    _activeRequestId++;
    state = state.copyWith(
      isClassifying: false,
      isCropConfirmed: false,
      isEditingCrop: true,
      clearProcessingStage: true,
      clearConfirmedImage: true,
      clearError: true,
      clearSuccess: true,
      clearResult: true,
    );
  }

  /// Alias used by guest session reset handlers
  Future<void> clearGuestCache() async {
    await _guestCache.clearCache();
    if (!mounted || isAuthenticated) return;
    clearSelection();
    state = state.copyWith(history: []);
  }

  /// Clear the currently selected image and reset workflow state
  void clearSelection() {
    _activeRequestId++;
    state = state.copyWith(
      isUploadingImage: false,
      isClassifying: false,
      isEditingCrop: false,
      clearProcessingStage: true,
      clearImage: true,
      clearRegion: true,
      clearConfirmedImage: true,
      clearCropRect: true,
      clearResult: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  /// Run MobileNetV3 classification against the Django backend
  Future<void> classify() async {
    // Prevent duplicate concurrent submissions
    if (state.isClassifying) return;

    if (state.selectedImageBytes == null) {
      state = state.copyWith(
        errorMessage: 'Please select or capture a Tilapia image first.',
        errorCode: 'MISSING_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (state.selectedRegion == null) {
      state = state.copyWith(
        errorMessage: 'Please select an anatomical region (Eye or Gill) before classifying.',
        errorCode: 'INVALID_REGION_TYPE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (!state.isCropConfirmed || state.confirmedImageBytes == null) {
      state = state.copyWith(
        errorMessage: 'Please confirm your selected anatomical region (crop the region or confirm full close-up) before classifying.',
        errorCode: 'CONFIRMATION_REQUIRED',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    final bytesToSubmit = state.confirmedImageBytes!;
    final region = state.selectedRegion!;
    final baseName = state.selectedImageName ?? 'tilapia_scan.jpg';
    final isPng =
        bytesToSubmit.length >= 8 &&
        bytesToSubmit[0] == 0x89 &&
        bytesToSubmit[1] == 0x50 &&
        bytesToSubmit[2] == 0x4E &&
        bytesToSubmit[3] == 0x47;
    final submitFilename = state.isFullImageConfirmed
        ? baseName
        : 'tilapia_${region.apiValue}_crop.${isPng ? 'png' : (isHeicHeader(bytesToSubmit) ? 'heic' : 'jpg')}';

    final requestId = ++_activeRequestId;

    state = state.copyWith(
      isClassifying: true,
      processingStage: 'Analyzing image...',
      clearResult: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final result = await _service.classifyImage(
        bytes: bytesToSubmit,
        filename: submitFilename,
        regionType: region.apiValue,
      );

      // Ignore stale response if image, region, or crop changed while in flight
      if (!mounted || requestId != _activeRequestId) return;

      final updatedHistory = isAuthenticated
          ? List<ClassificationResult>.from(state.history)
          : await _guestCache.addScan(result);
      if (!mounted || requestId != _activeRequestId) return;
      if (isAuthenticated && result.saved && result.scanId != null) {
        updatedHistory.insert(0, result);
      }

      state = state.copyWith(
        isClassifying: false,
        clearProcessingStage: true,
        latestResult: result,
        history: updatedHistory,
        successMessage: !isAuthenticated
            ? 'Analysis complete. Saved on this device only (latest 10 guest scans).'
            : result.saved
            ? 'Analysis complete. Result saved to your classification history.'
            : 'Analysis complete. Result was not saved to your account.',
      );
    } on ClassificationApiException catch (e) {
      if (!mounted || requestId != _activeRequestId) return;

      state = state.copyWith(
        isClassifying: false,
        clearProcessingStage: true,
        clearResult: true,
        errorCode: e.code,
        isInputRejection: e.isInputRejection,
        errorMessage: e.actionableMessage,
      );
    } catch (_) {
      if (!mounted || requestId != _activeRequestId) return;

      state = state.copyWith(
        isClassifying: false,
        clearProcessingStage: true,
        clearResult: true,
        errorCode: 'REQUEST_FAILED',
        isInputRejection: false,
        errorMessage: 'Unable to complete classification. Please try again.',
      );
    }
  }

  /// Load account history or device-only guest history.
  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      final list = isAuthenticated
          ? await _service.fetchHistory()
          : await _guestCache.getCachedHistory();
      if (!mounted) return;
      state = state.copyWith(history: list, isLoadingHistory: false);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoadingHistory: false);
    }
  }

  /// Delete a scan from user history
  Future<void> deleteScan(int scanId) async {
    state = state.copyWith(deletingScanId: scanId, clearError: true);
    try {
      if (isAuthenticated) {
        await _service.deleteScan(scanId);
      } else {
        await _guestCache.removeScan(scanId);
      }
      if (!mounted) return;
      final updated = state.history.where((s) => s.scanId != scanId).toList();
      state = state.copyWith(
        history: updated,
        clearDeleting: true,
        successMessage: 'Scan #$scanId permanently removed.',
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        clearDeleting: true,
        errorMessage: 'Could not delete scan record. Please try again.',
      );
    }
  }

  /// Delete multiple scans from user history in bulk
  Future<void> deleteMultipleScans(List<int> scanIds) async {
    if (scanIds.isEmpty) return;
    state = state.copyWith(clearError: true);
    try {
      if (isAuthenticated) {
        await Future.wait(scanIds.map((id) => _service.deleteScan(id)));
      } else {
        await Future.wait(scanIds.map((id) => _guestCache.removeScan(id)));
      }
      if (!mounted) return;
      final targetSet = scanIds.toSet();
      final updated =
          state.history.where((s) => !targetSet.contains(s.scanId)).toList();
      state = state.copyWith(
        history: updated,
        clearDeleting: true,
        successMessage: scanIds.length == 1
            ? 'Scan #${scanIds.first} permanently removed.'
            : '${scanIds.length} scan records permanently removed.',
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        clearDeleting: true,
        errorMessage:
            'Could not delete selected scan records. Please try again.',
      );
    }
  }
}

final classificationControllerProvider =
    StateNotifierProvider<ClassificationController, ClassificationState>((ref) {
      final service = ref.watch(classificationServiceProvider);
      final auth = ref.watch(authControllerProvider);
      return ClassificationController(
        service,
        isAuthenticated: auth.isAuthenticated,
        guestCache: ref.watch(guestHistoryCacheProvider),
      );
    });
