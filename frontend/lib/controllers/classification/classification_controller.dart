import 'dart:convert';
import 'dart:ui' as ui;

import '../auth/auth_controller.dart';
import '../../services/storage/guest_history_cache.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

enum BatchScanStatus {
  queued,
  checking,
  needsReview,
  rejected,
  failed,
  complete,
}

typedef BatchScanItem = ({
  XFile photo,
  BatchScanStatus status,
  String? message,
  ClassificationResult? result,
});

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
  final List<BatchScanItem> batchScans;
  final bool isBatchRunning;
  final List<EyeCropProposal> eyeProposals;
  final int? selectedEyeProposalIndex;
  final bool isFindingEyes;
  final bool alreadyCloseUpEye;
  final bool alreadyCloseUpGill;
  final Map<int, bool> eyeProposalFreshness;
  final Size? sourceImageSize;

  const ClassificationState({
    this.selectedImageBytes,
    this.selectedImageName,
    this.selectedRegion = AnatomicalRegion.auto,
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
    this.batchScans = const [],
    this.isBatchRunning = false,
    this.eyeProposals = const [],
    this.selectedEyeProposalIndex,
    this.isFindingEyes = false,
    this.alreadyCloseUpEye = false,
    this.alreadyCloseUpGill = false,
    this.eyeProposalFreshness = const {},
    this.sourceImageSize,
  });

  EyeCropProposal? get selectedEyeProposal {
    final idx = selectedEyeProposalIndex;
    if (idx == null || idx < 0 || idx >= eyeProposals.length) return null;
    return eyeProposals[idx];
  }

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
    List<BatchScanItem>? batchScans,
    bool? isBatchRunning,
    List<EyeCropProposal>? eyeProposals,
    int? selectedEyeProposalIndex,
    bool clearSelectedEyeProposal = false,
    bool clearEyeProposals = false,
    bool? isFindingEyes,
    bool? alreadyCloseUpEye,
    bool? alreadyCloseUpGill,
    Map<int, bool>? eyeProposalFreshness,
    Size? sourceImageSize,
    bool clearSourceImageSize = false,
  }) {
    return ClassificationState(
      selectedImageBytes: clearImage
          ? null
          : (selectedImageBytes ?? this.selectedImageBytes),
      selectedImageName: clearImage
          ? null
          : (selectedImageName ?? this.selectedImageName),
      selectedRegion: clearRegion
          ? AnatomicalRegion.auto
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
      batchScans: batchScans ?? this.batchScans,
      isBatchRunning: isBatchRunning ?? this.isBatchRunning,
      eyeProposals: clearImage || clearEyeProposals
          ? const []
          : (eyeProposals ?? this.eyeProposals),
      selectedEyeProposalIndex:
          clearImage || clearEyeProposals || clearSelectedEyeProposal
          ? null
          : (selectedEyeProposalIndex ?? this.selectedEyeProposalIndex),
      isFindingEyes: clearImage || clearEyeProposals
          ? false
          : (isFindingEyes ?? this.isFindingEyes),
      alreadyCloseUpEye: clearImage || clearEyeProposals
          ? false
          : (alreadyCloseUpEye ?? this.alreadyCloseUpEye),
      alreadyCloseUpGill: clearImage || clearEyeProposals
          ? false
          : (alreadyCloseUpGill ?? this.alreadyCloseUpGill),
      eyeProposalFreshness: clearImage || clearEyeProposals
          ? const {}
          : (eyeProposalFreshness ?? this.eyeProposalFreshness),
      sourceImageSize: clearImage || clearSourceImageSize
          ? null
          : (sourceImageSize ?? this.sourceImageSize),
    );
  }
}

class ClassificationController extends StateNotifier<ClassificationState> {
  final ClassificationService _service;
  final ImagePicker _picker;
  final GuestHistoryCache _guestCache;
  final bool isAuthenticated;
  int _activeRequestId = 0;
  int _eyeDetectRequestId = 0;
  Future<void> _eyeDetectQueue = Future.value();
  int? _reviewedBatchIndex;
  static const maxBatchPhotos = 10;

  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxSourceFileSizeBytes = 10 * 1024 * 1024;

  ClassificationController(
    this._service, {
    ImagePicker? picker,
    GuestHistoryCache? guestCache,
    this.isAuthenticated = true,
  }) : _guestCache = guestCache ?? GuestHistoryCache(),
       _picker = picker ?? ImagePicker(),
       super(const ClassificationState()) {
    loadHistory();
    retrieveLostCameraData();
  }

  /// Recover an image if Android killed the background Flutter activity while
  /// the native camera app was open.
  Future<void> retrieveLostCameraData() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final response = await _picker.retrieveLostData();
      if (!mounted || response.isEmpty) return;
      final file = response.file ??
          (response.files != null && response.files!.isNotEmpty
              ? response.files!.first
              : null);
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setSelectedImage(bytes: bytes, filename: file.name);
        }
      }
    } catch (_) {
      // Ignore platforms/test harnesses where retrieveLostData is unimplemented.
    }
  }

  /// Public convenience getter so widgets can check readiness after synchronous confirmation
  bool get isReadyToClassify => state.isReadyToClassify;

  static bool isHeicHeader(Uint8List bytes) =>
      ClassificationServiceImpl.isHeicBytes(bytes);

  static bool isWebpHeader(Uint8List bytes) {
    return bytes.length >= 12 &&
        bytes[0] == 0x52 && // R
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x46 && // F
        bytes[8] == 0x57 && // W
        bytes[9] == 0x45 && // E
        bytes[10] == 0x42 && // B
        bytes[11] == 0x50; // P
  }

  static bool isSupportedImageFormat(Uint8List bytes, String filename) {
    final lower = filename.trim().toLowerCase();
    final hasAllowedExtension =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
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

    // Require a valid JPEG/PNG/WebP/HEIC byte signature and (if an extension is present) a supported extension
    if (!isPngHeader &&
        !isJpegHeader &&
        !isWebpHeader(bytes) &&
        !isHeicHeader(bytes)) {
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

  /// Pick image from gallery or camera with an explicit loading state.
  /// Returns true when a photo was captured/selected.
  Future<bool> pickImage(ImageSource source) async {
    state = state.copyWith(isUploadingImage: true, clearError: true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setSelectedImage(bytes: bytes, filename: picked.name);
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      final isDenied = e.code.toLowerCase().contains('denied') ||
          e.code.toLowerCase().contains('permission');
      state = state.copyWith(
        errorMessage: isDenied
            ? 'Permission denied. Enable Camera or Photo access in device Settings.'
            : 'Unable to select image. Please try another photo.',
        errorCode: isDenied ? 'PERMISSION_DENIED' : 'INVALID_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Unable to select image. Please try another photo.',
        errorCode: 'INVALID_IMAGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return false;
    } finally {
      if (mounted) {
        state = state.copyWith(isUploadingImage: false);
      }
    }
  }

  Future<void> pickBatch() async {
    if (state.isBatchRunning ||
        state.isClassifying ||
        state.isFindingEyes ||
        state.isUploadingImage)
      return;
    state = state.copyWith(isUploadingImage: true, clearError: true);
    try {
      final photos = await _picker.pickMultiImage(
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
        limit: maxBatchPhotos,
      );
      if (mounted && photos.length == 1) {
        final single = photos.first;
        final bytes = await single.readAsBytes();
        if (mounted) {
          setSelectedImage(bytes: bytes, filename: single.name);
        }
      } else if (mounted && photos.length > 1) {
        await processBatch(photos);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isDenied = e.code.toLowerCase().contains('denied') ||
          e.code.toLowerCase().contains('permission');
      state = state.copyWith(
        errorMessage: isDenied
            ? 'Photo permission denied. Enable Photo access in device Settings.'
            : 'Could not open the photo picker.',
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: 'Could not open the photo picker.');
    } finally {
      if (mounted) state = state.copyWith(isUploadingImage: false);
    }
  }

  Future<void> processBatch(List<XFile> photos) async {
    if (photos.isEmpty ||
        state.isBatchRunning ||
        state.isClassifying ||
        state.isFindingEyes)
      return;
    if (photos.length > maxBatchPhotos) {
      state = state.copyWith(
        errorMessage: 'Select up to $maxBatchPhotos photos.',
      );
      return;
    }

    _reviewedBatchIndex = null;
    state = state.copyWith(
      isBatchRunning: true,
      isUploadingImage: false,
      clearError: true,
      batchScans: [
        for (final photo in photos)
          (
            photo: photo,
            status: BatchScanStatus.queued,
            message: null,
            result: null,
          ),
      ],
    );
    try {
      for (var i = 0; i < photos.length && mounted; i++) {
        final photo = photos[i];
        _updateBatchItem(i, BatchScanStatus.checking);
        try {
          final length = await photo.length();
          if (!mounted) return;
          if (length > maxSourceFileSizeBytes) {
            _updateBatchItem(
              i,
              BatchScanStatus.rejected,
              message: 'Photo exceeds 10 MB.',
            );
            continue;
          }
          final bytes = await photo.readAsBytes();
          if (!mounted) return;
          if (!isSupportedImageFormat(bytes, photo.name)) {
            _updateBatchItem(
              i,
              BatchScanStatus.rejected,
              message: 'Unsupported photo format.',
            );
            continue;
          }
          if (bytes.lengthInBytes > maxFileSizeBytes) {
            _updateBatchItem(
              i,
              BatchScanStatus.needsReview,
              message: 'Crop or resize this photo before checking.',
            );
            continue;
          }
          final effectiveRegion = state.selectedRegion ?? AnatomicalRegion.auto;
          final result = await _service.classifyImage(
            bytes: bytes,
            filename: photo.name,
            regionType: effectiveRegion.apiValue,
          );
          if (!mounted) return;
          final enrichedResult = await _attachThumbnailIfNeeded(result, bytes);
          if (!mounted) return;
          final history = await _historyWithResult(enrichedResult);
          if (!mounted) return;
          state = state.copyWith(history: history);
          _updateBatchItem(i, BatchScanStatus.complete, result: enrichedResult);
        } on ClassificationApiException catch (e) {
          if (!mounted) return;
          final effectiveRegion = state.selectedRegion ?? AnatomicalRegion.auto;
          const eyeFallbackCodes = {
            'WHOLE_TILAPIA_CLOSE_UP_REQUIRED',
            'CONTENT_UNCERTAIN',
            'UNSUPPORTED_IMAGE',
          };
          if (eyeFallbackCodes.contains(e.code) &&
              canFindEyes &&
              effectiveRegion != AnatomicalRegion.gill) {
            try {
              final wholeBytes = await photo.readAsBytes();
              if (!mounted) return;
              final eyeResult = await (_service as EyeProposalService).findEyes(
                wholeBytes,
                photo.name,
              );
              if (!mounted) return;
              if (eyeResult.proposals.isNotEmpty) {
                final eyeResultClass = await _service.classifyImage(
                  bytes: eyeResult.proposals.first.bytes,
                  filename: photo.name,
                  regionType: 'eye',
                );
                if (!mounted) return;
                final enrichedEyeResult = await _attachThumbnailIfNeeded(
                  eyeResultClass,
                  eyeResult.proposals.first.bytes,
                );
                if (!mounted) return;
                final history = await _historyWithResult(enrichedEyeResult);
                if (!mounted) return;
                state = state.copyWith(history: history);
                _updateBatchItem(
                  i,
                  BatchScanStatus.complete,
                  result: enrichedEyeResult,
                );
                continue;
              }
            } catch (_) {
              if (!mounted) return;
            }
          }

          final needsCrop = const {
            'WHOLE_TILAPIA_CLOSE_UP_REQUIRED',
            'CONTENT_UNCERTAIN',
            'UNSUPPORTED_IMAGE',
          }.contains(e.code);
          _updateBatchItem(
            i,
            needsCrop
                ? BatchScanStatus.needsReview
                : (e.isInputRejection
                      ? BatchScanStatus.rejected
                      : BatchScanStatus.failed),
            message: e.actionableMessage,
          );
        } catch (_) {
          if (!mounted) return;
          _updateBatchItem(
            i,
            BatchScanStatus.failed,
            message: 'Could not check this photo.',
          );
        }
      }
    } finally {
      if (mounted) {
        state = state.copyWith(isBatchRunning: false);
        if (state.batchScans.isNotEmpty) {
          await openBatchPhoto(0);
        }
      }
    }
  }

  Future<void> openBatchPhoto(int index) async {
    if (state.isBatchRunning || state.isClassifying || state.isUploadingImage)
      return;
    final item = state.batchScans[index];
    state = state.copyWith(isUploadingImage: true);
    try {
      final bytes = await item.photo.readAsBytes();
      if (!mounted ||
          index >= state.batchScans.length ||
          !identical(state.batchScans[index].photo, item.photo))
        return;
      selectRegion(AnatomicalRegion.auto);
      setSelectedImage(bytes: bytes, filename: item.photo.name);
      if (identical(state.selectedImageBytes, bytes))
        _reviewedBatchIndex = index;
    } catch (_) {
      if (!mounted) return;
      _updateBatchItem(
        index,
        BatchScanStatus.failed,
        message: 'Could not open this photo.',
      );
    } finally {
      if (mounted) state = state.copyWith(isUploadingImage: false);
    }
  }

  void _updateBatchItem(
    int index,
    BatchScanStatus status, {
    String? message,
    ClassificationResult? result,
  }) {
    final items = [...state.batchScans];
    items[index] = (
      photo: items[index].photo,
      status: status,
      message: message,
      result: result,
    );
    state = state.copyWith(batchScans: List.unmodifiable(items));
  }

  Future<ClassificationResult> _attachThumbnailIfNeeded(
    ClassificationResult result,
    Uint8List sourceBytes,
  ) async {
    if (result.thumbnailBase64 != null && result.thumbnailBase64!.isNotEmpty) {
      return result;
    }
    final encoded = await _encodeThumbnailBase64(sourceBytes);
    if (encoded == null) return result;
    return result.copyWith(thumbnailBase64: encoded);
  }

  /// Downscales scanned image bytes to a lightweight PNG thumbnail (<= 144px)
  /// so Guest and offline/local history rows display real thumbnails without
  /// bloating local storage.
  Future<String?> _encodeThumbnailBase64(Uint8List sourceBytes) async {
    if (sourceBytes.isEmpty) return null;
    ui.Codec? codec;
    ui.Image? image;
    try {
      codec = await ui.instantiateImageCodec(sourceBytes, targetWidth: 144);
      final frame = await codec.getNextFrame();
      image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return base64Encode(byteData.buffer.asUint8List());
    } catch (_) {
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  Future<List<ClassificationResult>> _historyWithResult(
    ClassificationResult result,
  ) async {
    if (!isAuthenticated) return _guestCache.addScan(result);
    return [
      if (result.saved && result.scanId != null) result,
      ...state.history,
    ];
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

    if (bytes.lengthInBytes > maxSourceFileSizeBytes) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'The original photo must be 10 MB or smaller.',
        errorCode: 'IMAGE_TOO_LARGE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    if (!isSupportedImageFormat(bytes, filename)) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Unsupported image format. Only JPG, JPEG, PNG, WebP, and HEIC images are allowed.',
        errorCode: 'UNSUPPORTED_IMAGE_TYPE',
        isInputRejection: true,
        clearSuccess: true,
      );
      return;
    }

    _reviewedBatchIndex = null;
    // Invalidate any in-flight classification or eye-detection request
    _activeRequestId++;
    _eyeDetectRequestId++;

    final effectiveRegion = state.selectedRegion ?? AnatomicalRegion.auto;

    state = state.copyWith(
      selectedImageBytes: bytes,
      selectedImageName: filename,
      selectedRegion: effectiveRegion,
      isUploadingImage: false,
      isClassifying: false,
      isEditingCrop: false,
      clearProcessingStage: true,
      clearConfirmedImage: true,
      clearCropRect: true,
      clearEyeProposals: true,
      clearError: true,
      clearSuccess: true,
      clearResult: true,
    );

    if (canFindEyes && effectiveRegion != AnatomicalRegion.gill) {
      detectEyesForCurrentImage();
    }
  }

  /// Select the target Tilapia anatomical region (Eye or Gill)
  void selectRegion(AnatomicalRegion region) {
    final regionChanged = state.selectedRegion != region;
    if (regionChanged) {
      _activeRequestId++;
      _eyeDetectRequestId++;
    }
    state = state.copyWith(
      selectedRegion: region,
      isClassifying: regionChanged ? false : state.isClassifying,
      isEditingCrop: false,
      clearProcessingStage: regionChanged,
      clearConfirmedImage: regionChanged,
      clearEyeProposals: regionChanged,
      clearError: true,
      clearSuccess: true,
      clearResult: regionChanged,
    );

    if (regionChanged &&
        state.selectedImageBytes != null &&
        canFindEyes &&
        region != AnatomicalRegion.gill) {
      detectEyesForCurrentImage();
    }
  }

  /// Switch to the alternate anatomical region (Eye <-> Gill) during rejection recovery
  void changeRegion() {
    final msg = (state.errorMessage ?? '').toLowerCase();
    final AnatomicalRegion nextRegion;
    if (state.selectedRegion == AnatomicalRegion.auto) {
      nextRegion = msg.contains('gill')
          ? AnatomicalRegion.gill
          : AnatomicalRegion.eye;
    } else {
      nextRegion = state.selectedRegion == AnatomicalRegion.eye
          ? AnatomicalRegion.gill
          : AnatomicalRegion.eye;
    }
    selectRegion(nextRegion);
  }

  bool get canFindEyes =>
      const bool.fromEnvironment('ENABLE_EYE_PROPOSALS', defaultValue: true) &&
      _service is EyeProposalService;

  Future<EyeProposalResult> findEyes() {
    final bytes = state.selectedImageBytes;
    if (state.isBatchRunning || !canFindEyes || bytes == null) {
      return Future.value((alreadyEye: false, proposals: <EyeCropProposal>[]));
    }
    return (_service as EyeProposalService).findEyes(
      bytes,
      state.selectedImageName ?? 'tilapia.jpg',
    );
  }

  /// Auto-detect or manually trigger eye proposals with stale-request guards.
  Future<void> detectEyesForCurrentImage() async {
    final bytes = state.selectedImageBytes;
    final region = state.selectedRegion;
    if (state.isBatchRunning ||
        !canFindEyes ||
        bytes == null ||
        region == AnatomicalRegion.gill) {
      return;
    }

    final reqId = ++_eyeDetectRequestId;
    state = state.copyWith(
      isFindingEyes: true,
      alreadyCloseUpEye: false,
      alreadyCloseUpGill: false,
      eyeProposals: const [],
      clearSelectedEyeProposal: true,
      eyeProposalFreshness: const {},
    );

    final queuedTask = _eyeDetectQueue.catchError((_) {}).then((_) async {
      if (!mounted ||
          reqId != _eyeDetectRequestId ||
          !identical(state.selectedImageBytes, bytes) ||
          state.selectedRegion != region) {
        return;
      }

      try {
        final svc = _service;
        final ({
          bool alreadyEye,
          List<EyeCropProposal> proposals,
          Size? imageSize,
        })
        result;
        if (svc is ClassificationServiceImpl) {
          result = await svc.findEyesDetailed(
            bytes,
            state.selectedImageName ?? 'tilapia.jpg',
          );
        } else {
          final basic = await (svc as EyeProposalService).findEyes(
            bytes,
            state.selectedImageName ?? 'tilapia.jpg',
          );
          result = (
            alreadyEye: basic.alreadyEye,
            proposals: basic.proposals,
            imageSize: null,
          );
        }
        if (!mounted ||
            reqId != _eyeDetectRequestId ||
            !identical(state.selectedImageBytes, bytes) ||
            state.selectedRegion != region) {
          return;
        }

        if (result.alreadyEye) {
          state = state.copyWith(
            selectedRegion: region == AnatomicalRegion.auto
                ? AnatomicalRegion.eye
                : region,
            isFindingEyes: false,
            alreadyCloseUpEye: true,
            alreadyCloseUpGill: false,
            eyeProposals: const [],
            clearSelectedEyeProposal: true,
            sourceImageSize: result.imageSize,
          );
          confirmFullImageAsCloseUp();
          return;
        }

        if (result.proposals.isNotEmpty) {
          final first = result.proposals.first;
          state = state.copyWith(
            isFindingEyes: false,
            alreadyCloseUpEye: false,
            eyeProposals: result.proposals,
            selectedEyeProposalIndex: 0,
            confirmedImageBytes: first.bytes,
            isCropConfirmed: true,
            isFullImageConfirmed: false,
            lastCropNormalizedRect: first.rect,
            sourceImageSize: result.imageSize,
            clearError: true,
            clearResult: true,
          );
          return;
        }

        state = state.copyWith(
          isFindingEyes: false,
          alreadyCloseUpEye: false,
          eyeProposals: result.proposals,
          clearSelectedEyeProposal: true,
          sourceImageSize: result.imageSize,
        );
      } on ClassificationApiException catch (e) {
        if (!mounted || reqId != _eyeDetectRequestId) return;
        // In Auto mode, eye-proposals returns REGION_MISMATCH when Model A
        // detects a valid exposed gill close-up. Automatically switch to Gill
        // and confirm the close-up rather than surfacing a false mismatch error.
        if (e.code == 'REGION_MISMATCH' && region == AnatomicalRegion.auto) {
          final isGill = e.message.toLowerCase().contains('gill');
          state = state.copyWith(
            selectedRegion: isGill
                ? AnatomicalRegion.gill
                : AnatomicalRegion.eye,
            isFindingEyes: false,
            alreadyCloseUpEye: !isGill,
            alreadyCloseUpGill: isGill,
            eyeProposals: const [],
            clearSelectedEyeProposal: true,
            clearError: true,
          );
          confirmFullImageAsCloseUp();
          return;
        }
        state = state.copyWith(isFindingEyes: false);
        if (e.isInputRejection) {
          showEyeProposalRejection(e);
        }
      } catch (_) {
        if (!mounted || reqId != _eyeDetectRequestId) return;
        state = state.copyWith(isFindingEyes: false);
      }
    });

    _eyeDetectQueue = queuedTask;
    return queuedTask;
  }

  /// Select one detected eye proposal from the gallery or image marker.
  /// Clears any previous live result so switching eyes never shows stale data.
  void selectEyeProposal(int index) {
    if (index < 0 || index >= state.eyeProposals.length) return;
    final proposal = state.eyeProposals[index];
    _activeRequestId++;
    state = state.copyWith(
      selectedEyeProposalIndex: index,
      confirmedImageBytes: proposal.bytes,
      isCropConfirmed: true,
      isFullImageConfirmed: false,
      lastCropNormalizedRect: proposal.rect,
      isClassifying: false,
      clearProcessingStage: true,
      clearError: true,
      clearResult: true,
      clearSuccess: true,
    );
  }

  void showEyeProposalRejection(ClassificationApiException error) {
    state = state.copyWith(
      errorCode: error.code,
      errorMessage: error.actionableMessage,
      isInputRejection: error.isInputRejection,
      clearResult: true,
      clearSuccess: true,
    );
  }

  /// Confirm a cropped anatomical region
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
      final isHeic = isHeicHeader(state.selectedImageBytes!);
      _activeRequestId++;
      state = state.copyWith(
        errorMessage: isHeic
            ? 'This HEIC photo could not be cropped. Use a JPG or PNG, or choose Full Close-Up if the original already frames the eye or gill.'
            : 'Unable to create the crop. Try again or choose another photo.',
        errorCode: 'CROP_FAILED',
        isInputRejection: true,
        clearConfirmedImage: true,
        clearCropRect: true,
        clearSelectedEyeProposal: true,
        isCropConfirmed: false,
        isFullImageConfirmed: false,
        isEditingCrop: true,
        isClassifying: false,
        clearProcessingStage: true,
        clearSuccess: true,
        clearResult: true,
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
      clearSelectedEyeProposal: true,
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

    if (bytes.lengthInBytes > maxFileSizeBytes) {
      state = state.copyWith(
        errorCode: 'IMAGE_TOO_LARGE',
        errorMessage: 'Use Edit Crop to make the close-up 5 MB or smaller.',
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
      clearSelectedEyeProposal: true,
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
      clearSelectedEyeProposal: true,
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

  /// Clear error or success notification banner
  void clearNotification() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Convenience alias to reset workflow
  void resetWorkflow() => clearSelection();

  /// Clear the currently selected image and reset workflow state
  void clearSelection() {
    _reviewedBatchIndex = null;
    _activeRequestId++;
    _eyeDetectRequestId++;
    state = state.copyWith(
      isUploadingImage: false,
      isClassifying: false,
      isEditingCrop: false,
      isBatchRunning: false,
      batchScans: const [],
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
    if (state.isClassifying || state.isBatchRunning) return;

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
    final region = state.selectedEyeProposal != null
        ? AnatomicalRegion.eye
        : state.selectedRegion!;
    final baseName = state.selectedImageName ?? 'tilapia_scan.jpg';
    final isPng =
        bytesToSubmit.length >= 8 &&
        bytesToSubmit[0] == 0x89 &&
        bytesToSubmit[1] == 0x50 &&
        bytesToSubmit[2] == 0x4E &&
        bytesToSubmit[3] == 0x47;
    final submitFilename = state.isFullImageConfirmed
        ? baseName
        : 'tilapia_${region.apiValue}_crop.${isPng ? 'png' : (isWebpHeader(bytesToSubmit) ? 'webp' : (isHeicHeader(bytesToSubmit) ? 'heic' : 'jpg'))}';

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

      final enrichedResult = await _attachThumbnailIfNeeded(
        result,
        bytesToSubmit,
      );
      if (!mounted || requestId != _activeRequestId) return;

      final updatedHistory = await _historyWithResult(enrichedResult);
      if (!mounted || requestId != _activeRequestId) return;
      final batchIndex = _reviewedBatchIndex;
      if (batchIndex != null) {
        _updateBatchItem(
          batchIndex,
          BatchScanStatus.complete,
          result: enrichedResult,
        );
      }

      final updatedEyeFreshness = Map<int, bool>.from(
        state.eyeProposalFreshness,
      );
      if (state.selectedEyeProposalIndex != null) {
        updatedEyeFreshness[state.selectedEyeProposalIndex!] =
            enrichedResult.isFresh;
      }

      state = state.copyWith(
        isClassifying: false,
        clearProcessingStage: true,
        latestResult: enrichedResult,
        history: updatedHistory,
        eyeProposalFreshness: updatedEyeFreshness,
        successMessage: !isAuthenticated
            ? 'Analysis complete. Saved on this device only (latest 10 guest scans).'
            : enrichedResult.saved
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
        await _service.bulkDeleteScans(scanIds);
      } else {
        await Future.wait(scanIds.map((id) => _guestCache.removeScan(id)));
      }
      if (!mounted) return;
      final targetSet = scanIds.toSet();
      final updated = state.history
          .where((s) => !targetSet.contains(s.scanId))
          .toList();
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

  /// Clear all scans from user history (or guest cache)
  Future<void> clearAllHistory() async {
    state = state.copyWith(clearError: true);
    try {
      if (isAuthenticated) {
        await _service.clearAllHistory();
      } else {
        await _guestCache.clearCache();
      }
      if (!mounted) return;
      state = state.copyWith(
        history: const [],
        clearDeleting: true,
        successMessage: 'All classification history has been cleared.',
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        clearDeleting: true,
        errorMessage:
            'Could not clear classification history. Please try again.',
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
