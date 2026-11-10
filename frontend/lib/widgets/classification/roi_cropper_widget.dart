import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../common/app_button.dart';

/// Interactive Region-of-Interest (ROI) Selection & Cropping Widget
/// Supports both a dedicated Modal Dialog (`isModal: true`) for conflict-free
/// pan/zoom cropping + 1-click classification, and a compact inline Dashboard
/// summary card (`isModal: false`).
class RoiCropperWidget extends StatefulWidget {
  final ClassificationState state;
  final ClassificationController controller;
  final bool isModal;
  final VoidCallback? onOpenModal;
  final VoidCallback? onCloseModal;

  static const double defaultCropWindowFraction = 0.76;

  const RoiCropperWidget({
    super.key,
    required this.state,
    required this.controller,
    this.isModal = false,
    this.onOpenModal,
    this.onCloseModal,
  });

  /// Pure geometric helper that computes the normalized (0.0..1.0) image rectangle
  /// framed inside the center ROI reticle window for any viewport size, image aspect
  /// ratio (portrait, landscape, or square), zoom scale, and pan translation.
  static Rect computeNormalizedCropRect({
    required Size viewportSize,
    required Size imageSize,
    required Matrix4 transform,
    double cropWindowFraction = defaultCropWindowFraction,
  }) {
    if (viewportSize.width <= 0 ||
        viewportSize.height <= 0 ||
        imageSize.width <= 0 ||
        imageSize.height <= 0) {
      return const Rect.fromLTWH(0, 0, 1, 1);
    }

    final cropSide =
        math.min(viewportSize.width, viewportSize.height) * cropWindowFraction;
    final cropRectInViewport = Rect.fromCenter(
      center: Offset(viewportSize.width / 2, viewportSize.height / 2),
      width: cropSide,
      height: cropSide,
    );

    // Transform viewport crop window back into untransformed child coordinates
    final inverse = Matrix4.inverted(transform);
    final topLeftChild = MatrixUtils.transformPoint(
      inverse,
      cropRectInViewport.topLeft,
    );
    final bottomRightChild = MatrixUtils.transformPoint(
      inverse,
      cropRectInViewport.bottomRight,
    );

    // Determine how BoxFit.contain places the image inside viewportSize
    final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, viewportSize);
    final destSize = fittedSizes.destination;
    final imageDisplayRect = Rect.fromCenter(
      center: Offset(viewportSize.width / 2, viewportSize.height / 2),
      width: destSize.width,
      height: destSize.height,
    );

    final normLeft = ((topLeftChild.dx - imageDisplayRect.left) /
            imageDisplayRect.width)
        .clamp(0.0, 0.95);
    final normTop = ((topLeftChild.dy - imageDisplayRect.top) /
            imageDisplayRect.height)
        .clamp(0.0, 0.95);
    final normRight = ((bottomRightChild.dx - imageDisplayRect.left) /
            imageDisplayRect.width)
        .clamp(normLeft + 0.05, 1.0);
    final normBottom = ((bottomRightChild.dy - imageDisplayRect.top) /
            imageDisplayRect.height)
        .clamp(normTop + 0.05, 1.0);

    return Rect.fromLTRB(normLeft, normTop, normRight, normBottom);
  }

  /// Computes the pixel source rectangle on the original image corresponding
  /// to the ROI crop window.
  static Rect computeSourceCropRect({
    required Size viewportSize,
    required Size imageSize,
    required Matrix4 transform,
    double cropWindowFraction = defaultCropWindowFraction,
  }) {
    final normalized = computeNormalizedCropRect(
      viewportSize: viewportSize,
      imageSize: imageSize,
      transform: transform,
      cropWindowFraction: cropWindowFraction,
    );
    return Rect.fromLTRB(
      normalized.left * imageSize.width,
      normalized.top * imageSize.height,
      normalized.right * imageSize.width,
      normalized.bottom * imageSize.height,
    );
  }

  @override
  State<RoiCropperWidget> createState() => _RoiCropperWidgetState();
}

class _RoiCropperWidgetState extends State<RoiCropperWidget> {
  final TransformationController _transformController =
      TransformationController();

  ui.Image? _decodedImage;
  Uint8List? _decodedForBytes;
  bool _isCropping = false;
  double _currentScale = 1.0;

  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;
  static const double _cropWindowFraction = 0.76;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
    _decodeSelectedImageInBackground();
  }

  @override
  void didUpdateWidget(covariant RoiCropperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.selectedImageBytes != oldWidget.state.selectedImageBytes) {
      _resetTransform();
      _decodeSelectedImageInBackground();
    }
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    _decodedImage?.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis().clamp(
          _minScale,
          _maxScale,
        );
    if ((scale - _currentScale).abs() > 0.01 && mounted) {
      setState(() => _currentScale = scale);
    }
  }

  void _resetTransform() {
    _transformController.value = Matrix4.identity();
    if (mounted) {
      setState(() => _currentScale = 1.0);
    }
  }

  void _setZoomScale(double targetScale, Size viewportSize) {
    final clamped = targetScale.clamp(_minScale, _maxScale);
    final currentMatrix = _transformController.value.clone();
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale <= 0) return;

    final focalPoint = Offset(viewportSize.width / 2, viewportSize.height / 2);
    final scaleFactor = clamped / currentScale;

    final nextMatrix = Matrix4.identity()
      ..translateByDouble(focalPoint.dx, focalPoint.dy, 0.0, 1.0)
      ..scaleByDouble(scaleFactor, scaleFactor, 1.0, 1.0)
      ..translateByDouble(-focalPoint.dx, -focalPoint.dy, 0.0, 1.0)
      ..multiply(currentMatrix);

    _transformController.value = nextMatrix;
    setState(() => _currentScale = clamped);
  }

  Future<void> _decodeSelectedImageInBackground() async {
    final bytes = widget.state.selectedImageBytes;
    if (bytes == null) {
      _decodedImage?.dispose();
      _decodedImage = null;
      _decodedForBytes = null;
      return;
    }
    if (identical(bytes, _decodedForBytes) && _decodedImage != null) {
      return;
    }

    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      _decodedImage?.dispose();
      _decodedImage = frame.image;
      _decodedForBytes = bytes;
    } catch (_) {
      _decodedImage = null;
      _decodedForBytes = bytes;
    }
  }

  /// Calculates the normalized (0..1) and pixel source rectangle of the image
  /// currently framed inside the center ROI reticle window.
  Rect _computeNormalizedCropRect(Size viewportSize, Size imageSize) {
    return RoiCropperWidget.computeNormalizedCropRect(
      viewportSize: viewportSize,
      imageSize: imageSize,
      transform: _transformController.value,
      cropWindowFraction: _cropWindowFraction,
    );
  }

  Future<void> _completeConfirmation({
    required bool classifyImmediately,
  }) async {
    if (!widget.controller.isReadyToClassify) return;
    widget.onCloseModal?.call();
    if (classifyImmediately) {
      await widget.controller.classify();
    }
  }

  Future<void> _handleConfirmFullCloseUp({
    bool classifyImmediately = false,
  }) async {
    widget.controller.confirmFullImageAsCloseUp();
    await _completeConfirmation(classifyImmediately: classifyImmediately);
  }

  Future<void> _handleConfirmCrop(
    Size viewportSize, {
    bool classifyImmediately = false,
  }) async {
    if (widget.state.selectedRegion == null) {
      widget.controller.confirmCroppedRegion(Uint8List(0));
      return;
    }

    final rawBytes = widget.state.selectedImageBytes;
    if (rawBytes == null) return;

    final uiImg = _decodedImage;
    if (uiImg == null) {
      final normalizedRect = _computeNormalizedCropRect(
        viewportSize,
        viewportSize,
      );
      widget.controller.confirmCroppedRegion(
        rawBytes,
        normalizedCropRect: normalizedRect,
      );
      await _completeConfirmation(classifyImmediately: classifyImmediately);
      return;
    }

    setState(() => _isCropping = true);
    try {
      final imageSize = Size(
        uiImg.width.toDouble(),
        uiImg.height.toDouble(),
      );
      final normalizedRect = _computeNormalizedCropRect(
        viewportSize,
        imageSize,
      );

      final srcRect = Rect.fromLTRB(
        normalizedRect.left * imageSize.width,
        normalizedRect.top * imageSize.height,
        normalizedRect.right * imageSize.width,
        normalizedRect.bottom * imageSize.height,
      );

      // Keep high visual fidelity (at least 64px, up to 1024px) for MobileNetV3 (224x224)
      final outWidth = srcRect.width.round().clamp(64, 1024);
      final outHeight = srcRect.height.round().clamp(64, 1024);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final dstRect = Rect.fromLTWH(
        0,
        0,
        outWidth.toDouble(),
        outHeight.toDouble(),
      );

      canvas.drawImageRect(
        uiImg,
        srcRect,
        dstRect,
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final croppedUiImage = await picture.toImage(outWidth, outHeight);
      picture.dispose();

      final byteData = await croppedUiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      croppedUiImage.dispose();

      if (!mounted) return;
      setState(() => _isCropping = false);

      if (byteData != null && byteData.lengthInBytes > 0) {
        widget.controller.confirmCroppedRegion(
          byteData.buffer.asUint8List(),
          normalizedCropRect: normalizedRect,
        );
      } else {
        widget.controller.confirmCroppedRegion(
          rawBytes,
          normalizedCropRect: normalizedRect,
        );
      }
      await _completeConfirmation(classifyImmediately: classifyImmediately);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCropping = false);
      widget.controller.confirmCroppedRegion(
        rawBytes,
        normalizedCropRect: const Rect.fromLTWH(0.12, 0.12, 0.76, 0.76),
      );
      await _completeConfirmation(classifyImmediately: classifyImmediately);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;

    if (widget.isModal) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SariwaColors.borderLightTeal, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28061419),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalHeader(state),
              const Divider(height: 1, color: SariwaColors.borderLightTeal),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.errorMessage != null) ...[
                        _buildModalErrorBanner(state.errorMessage!),
                        const SizedBox(height: 14),
                      ],
                      _buildTopFileBar(state, controller),
                      const SizedBox(height: 14),
                      _buildRegionSelectionSection(state, controller),
                      const SizedBox(height: 14),
                      _buildInteractiveCropWorkspace(state, controller),
                      const SizedBox(height: 14),
                      _buildModalStep4GuardBar(state, controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Uploaded Image Summary & Replace Action
          _buildTopFileBar(state, controller),
          const SizedBox(height: 16),

          // Step 2: Anatomical Region Selector (Eye or Gill)
          _buildRegionSelectionSection(state, controller),
          const SizedBox(height: 16),

          // Step 3: Confirmed Region Preview OR Open Modal / Interactive Workspace
          if (state.isCropConfirmed && state.confirmedImageBytes != null)
            _buildConfirmedRegionPreview(state, controller)
          else if (widget.onOpenModal != null)
            _buildPendingModalTriggerCard(state)
          else
            _buildInteractiveCropWorkspace(state, controller),
        ],
      ),
    );
  }

  Widget _buildModalHeader(ClassificationState state) {
    final region = state.selectedRegion;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      color: SariwaColors.bgDashboard,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.crop_free_rounded,
              size: 19,
              color: SariwaColors.brandPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region != null
                      ? 'Prepare ${region.displayName} Region (ROI)'
                      : 'Prepare Anatomical Region (Eye / Gill)',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Select Eye or Gill, frame the region, and classify in one click or confirm preview first.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: SariwaColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: const Key('close_crop_modal_button'),
            tooltip: 'Close Crop Modal',
            onPressed: widget.onCloseModal,
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalErrorBanner(String message) {
    return Container(
      key: const Key('modal_error_banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SariwaColors.statusModerate.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: SariwaColors.statusModerate.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: SariwaColors.statusModerate,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingModalTriggerCard(ClassificationState state) {
    final region = state.selectedRegion;
    return Container(
      key: const Key('pending_crop_modal_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'STEP 3',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Crop or Confirm Anatomical Region',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            region != null
                ? 'Open the ROI Cropper Modal to frame the ${region.displayName.toLowerCase()} or confirm the full close-up image.'
                : 'Select Eye or Gill above, then open the ROI Cropper Modal to frame and confirm the image.',
            style: const TextStyle(
              fontSize: 12,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                key: const Key('open_crop_modal_button'),
                onPressed: widget.onOpenModal,
                icon: const Icon(Icons.crop_free_rounded, size: 17),
                label: const Text('Open Crop & Region Modal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SariwaColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              OutlinedButton.icon(
                key: const Key('confirm_full_image_button'),
                onPressed: () => _handleConfirmFullCloseUp(),
                icon: const Icon(Icons.fullscreen_rounded, size: 17),
                label: const Text('Use Full Image (Close-Up)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.brandPrimary,
                  side: const BorderSide(color: SariwaColors.brandPrimary),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalStep4GuardBar(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final isReady = state.isReadyToClassify;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboardSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tip: Use "Crop & Classify Freshness" above to confirm your framed region and start MobileNetV3 classification in a single click.',
            style: TextStyle(
              fontSize: 11.5,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: !isReady && !state.isClassifying
                ? () => controller.classify()
                : null,
            child: AppButton.primary(
              key: const Key('validate_and_classify_button'),
              label: state.isClassifying
                  ? (state.processingStage ?? 'Analyzing image...')
                  : 'Validate & Classify Freshness',
              isLoading: state.isClassifying,
              height: 44,
              borderRadius: 12,
              icon: const Icon(
                Icons.auto_awesome,
                size: 17,
                color: Colors.white,
              ),
              onPressed: isReady && !state.isClassifying
                  ? () async {
                      widget.onCloseModal?.call();
                      await controller.classify();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopFileBar(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final fileInfo = Row(
      children: [
        if (state.selectedImageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              color: SariwaColors.bgAbyssDark,
              child: Image.memory(
                state.selectedImageBytes!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_outlined,
                  size: 18,
                  color: Colors.white70,
                ),
              ),
            ),
          )
        else
          const Icon(
            Icons.image_outlined,
            size: 18,
            color: SariwaColors.brandPrimary,
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.brandPrimary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'STEP 1',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      state.selectedImageName ?? 'tilapia_scan.jpg',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Uploaded source image · Supported formats: JPG, JPEG, PNG (max 5 MB)',
                style: TextStyle(
                  fontSize: 11,
                  color: SariwaColors.textSecondaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final replaceBtn = TextButton.icon(
      key: const Key('replace_image_button'),
      onPressed:
          state.isClassifying ? null : () => controller.clearSelection(),
      icon: const Icon(
        Icons.swap_horiz_rounded,
        size: 16,
        color: SariwaColors.statusSpoiled,
      ),
      label: const Text(
        'Replace Image',
        style: TextStyle(
          color: SariwaColors.statusSpoiled,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fileInfo,
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: replaceBtn,
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: fileInfo),
              replaceBtn,
            ],
          );
        },
      ),
    );
  }

  Widget _buildRegionSelectionSection(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final selected = state.selectedRegion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'STEP 2',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Select Anatomical Region (Required)',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final eyeCard = _buildRegionOptionCard(
              key: const Key('region_option_eye'),
              region: AnatomicalRegion.eye,
              icon: Icons.visibility_outlined,
              isSelected: selected == AnatomicalRegion.eye,
              isDisabled: state.isClassifying,
              onTap: state.isClassifying
                  ? null
                  : () => controller.selectRegion(AnatomicalRegion.eye),
            );
            final gillCard = _buildRegionOptionCard(
              key: const Key('region_option_gill'),
              region: AnatomicalRegion.gill,
              icon: Icons.waves_rounded,
              isSelected: selected == AnatomicalRegion.gill,
              isDisabled: state.isClassifying,
              onTap: state.isClassifying
                  ? null
                  : () => controller.selectRegion(AnatomicalRegion.gill),
            );

            if (isNarrow) {
              return Column(
                children: [
                  eyeCard,
                  const SizedBox(height: 8),
                  gillCard,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: eyeCard),
                const SizedBox(width: 10),
                Expanded(child: gillCard),
              ],
            );
          },
        ),
        const SizedBox(height: 10),

        // Concise Anatomical Guidance Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SariwaColors.borderLightTeal),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 16,
                    color: SariwaColors.brandPrimary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Eye: Select the fish's visible eye and surrounding area.",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Gill: Select exposed gill tissue, not the external gill cover.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Note: Selecting Eye or Gill specifies which region you are submitting; it does not automatically verify that the image contains Tilapia or that anatomical part.',
                style: TextStyle(
                  fontSize: 11,
                  color: SariwaColors.textMutedDark,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegionOptionCard({
    required Key key,
    required AnatomicalRegion region,
    required IconData icon,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.55 : 1.0,
      child: Material(
        color: isSelected
            ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: key,
          onTap: onTap,
          hoverColor: SariwaColors.brandPrimary.withValues(alpha: 0.06),
          focusColor: SariwaColors.brandPrimary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? SariwaColors.brandPrimary
                    : SariwaColors.borderLightTeal,
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SariwaColors.brandPrimary
                        : SariwaColors.bgDashboardSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 17,
                    color: isSelected
                        ? Colors.white
                        : SariwaColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.displayName,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? SariwaColors.brandPrimary
                              : SariwaColors.textPrimaryDark,
                        ),
                      ),
                      Text(
                        region.tagalogName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: SariwaColors.textSecondaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isSelected
                      ? SariwaColors.brandPrimary
                      : SariwaColors.textMutedDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCropWorkspace(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final region = state.selectedRegion;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = viewportWidth.clamp(240.0, 310.0);
        final viewportSize = Size(viewportWidth, viewportHeight);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: SariwaColors.brandPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'STEP 3',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Crop Region of Interest or Confirm Close-Up',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: SariwaColors.textPrimaryDark,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _resetTransform,
                  icon: const Icon(Icons.restart_alt_rounded, size: 15),
                  label: const Text(
                    'Reset Zoom',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Drag to reposition and pinch or slide to zoom the ${region?.displayName.toLowerCase() ?? 'target'} inside the frame, or retain the full image if it is already a close-up.',
              style: const TextStyle(
                fontSize: 11.5,
                color: SariwaColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 10),

            // Interactive Cropping Viewport
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                key: const Key('interactive_crop_viewport'),
                width: viewportWidth,
                height: viewportHeight,
                color: SariwaColors.bgAbyssDark,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InteractiveViewer(
                      transformationController: _transformController,
                      minScale: _minScale,
                      maxScale: _maxScale,
                      boundaryMargin: const EdgeInsets.all(120),
                      panEnabled: true,
                      scaleEnabled: true,
                      child: SizedBox(
                        width: viewportWidth,
                        height: viewportHeight,
                        child: Image.memory(
                          state.selectedImageBytes!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Center(
                            child: Text(
                              'Image preview unavailable',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Non-interactive Reticle & Mask Overlay
                    const IgnorePointer(
                      child: CustomPaint(
                        painter: _RoiCropReticlePainter(
                          cropWindowFraction: _cropWindowFraction,
                          accentColor: SariwaColors.brandLight,
                        ),
                      ),
                    ),

                    // Top-left Target Badge inside viewport
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: SariwaColors.bgAbyssDark
                                .withValues(alpha: 0.80),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: SariwaColors.borderGlass,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.crop_free_rounded,
                                size: 13,
                                color: SariwaColors.brandLight,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                region != null
                                    ? 'Target: Tilapia ${region.displayName}'
                                    : 'Select Eye or Gill above',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (_isCropping)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: SariwaColors.brandLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Zoom Slider & Buttons Row
            Row(
              children: [
                IconButton(
                  tooltip: 'Zoom Out',
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _setZoomScale(_currentScale - 0.5, viewportSize),
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 20,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: SariwaColors.brandPrimary,
                      inactiveTrackColor: SariwaColors.borderLightTeal,
                      thumbColor: SariwaColors.brandPrimary,
                      overlayColor:
                          SariwaColors.brandPrimary.withValues(alpha: 0.12),
                      trackHeight: 3.5,
                    ),
                    child: Slider(
                      key: const Key('crop_zoom_slider'),
                      value: _currentScale.clamp(_minScale, _maxScale),
                      min: _minScale,
                      max: _maxScale,
                      onChanged: (val) => _setZoomScale(val, viewportSize),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Zoom In',
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _setZoomScale(_currentScale + 0.5, viewportSize),
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currentScale.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Primary 1-Click Actions: Crop & Classify OR Full Close-Up & Classify
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  key: const Key('crop_and_classify_button'),
                  onPressed: _isCropping || state.isClassifying
                      ? null
                      : () => _handleConfirmCrop(
                            viewportSize,
                            classifyImmediately: true,
                          ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                  label: const Text('Crop & Classify Freshness'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('full_image_and_classify_button'),
                  onPressed: _isCropping || state.isClassifying
                      ? null
                      : () => _handleConfirmFullCloseUp(
                            classifyImmediately: true,
                          ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Full Close-Up & Classify'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    side: const BorderSide(
                      color: SariwaColors.brandPrimary,
                      width: 1.4,
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Secondary Review-First Confirmation Buttons: Confirm Crop OR Confirm Full Close-Up
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('confirm_crop_button'),
                  onPressed: _isCropping
                      ? null
                      : () => _handleConfirmCrop(viewportSize),
                  icon: const Icon(Icons.crop_rounded, size: 16),
                  label: const Text('Confirm Cropped Region'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.textPrimaryDark,
                    side: const BorderSide(color: SariwaColors.borderLightTeal),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('confirm_full_image_button'),
                  onPressed: _isCropping
                      ? null
                      : () => _handleConfirmFullCloseUp(),
                  icon: const Icon(Icons.fullscreen_rounded, size: 17),
                  label: const Text('Use Full Image (Close-Up)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.textPrimaryDark,
                    side: const BorderSide(color: SariwaColors.borderLightTeal),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmedRegionPreview(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final region = state.selectedRegion;

    return Container(
      key: const Key('confirmed_region_preview'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: SariwaColors.brandPrimary.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.brandPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'STEP 3',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Confirmed ${region?.displayName ?? ''} Region Ready',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.isFullImageConfirmed
                      ? 'Full Close-Up'
                      : 'Cropped ROI',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 190,
              width: double.infinity,
              color: SariwaColors.bgAbyssDark,
              child: Image.memory(
                state.confirmedImageBytes!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Exact image to be submitted · Selected region: ${region?.displayName ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('edit_crop_button'),
                onPressed: state.isClassifying
                    ? null
                    : () {
                        controller.editCrop();
                        widget.onOpenModal?.call();
                      },
                icon: const Icon(Icons.crop_rotate_rounded, size: 15),
                label: const Text('Edit Crop'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.brandPrimary,
                  side: const BorderSide(color: SariwaColors.borderLightTeal),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoiCropReticlePainter extends CustomPainter {
  final double cropWindowFraction;
  final Color accentColor;

  const _RoiCropReticlePainter({
    required this.cropWindowFraction,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cropSide =
        math.min(size.width, size.height) * cropWindowFraction;
    final cropRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropSide,
      height: cropSide,
    );

    // Darken exterior outside the ROI crop window
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cropRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = const Color(0x88061419),
    );

    // Subtle border around crop window
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cropRect, const Radius.circular(12)),
      borderPaint,
    );

    // Rule-of-thirds guide lines inside crop window
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 1; i <= 2; i++) {
      final dx = cropRect.left + (cropRect.width * i / 3);
      final dy = cropRect.top + (cropRect.height * i / 3);
      canvas.drawLine(
        Offset(dx, cropRect.top),
        Offset(dx, cropRect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(cropRect.left, dy),
        Offset(cropRect.right, dy),
        gridPaint,
      );
    }

    // Glowing SariwaBa corner brackets
    final cornerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 22.0;
    final l = cropRect.left;
    final t = cropRect.top;
    final r = cropRect.right;
    final b = cropRect.bottom;

    // Top-left
    canvas.drawLine(Offset(l, t + cornerLen), Offset(l, t), cornerPaint);
    canvas.drawLine(Offset(l, t), Offset(l + cornerLen, t), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(r - cornerLen, t), Offset(r, t), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLen), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(l, b - cornerLen), Offset(l, b), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l + cornerLen, b), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(r - cornerLen, b), Offset(r, b), cornerPaint);
    canvas.drawLine(Offset(r, b - cornerLen), Offset(r, b), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _RoiCropReticlePainter oldDelegate) {
    return oldDelegate.cropWindowFraction != cropWindowFraction ||
        oldDelegate.accentColor != accentColor;
  }
}
