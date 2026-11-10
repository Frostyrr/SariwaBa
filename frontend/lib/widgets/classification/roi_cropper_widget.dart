import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';

/// iOS Cupertino-inspired Interactive Region-of-Interest (ROI) Selection & Cropping Widget.
/// Uses progressive disclosure (hover/tap frosted-glass HUD over the image) to eliminate
/// visual overload, and automatically accepts the live crop or close-up frame when
/// the user presses "Validate & Classify Freshness".
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
  bool _isHoveringViewport = false;
  bool _pinGuidanceOverlay = false;
  bool _useFullCloseUpMode = false;
  Size _lastViewportSize = const Size(320, 280);

  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;
  static const double _cropWindowFraction = 0.76;

  @override
  void initState() {
    super.initState();
    _useFullCloseUpMode = widget.state.isFullImageConfirmed;
    _transformController.addListener(_onTransformChanged);
    _decodeSelectedImageInBackground();
  }

  @override
  void didUpdateWidget(covariant RoiCropperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.selectedImageBytes != oldWidget.state.selectedImageBytes) {
      _useFullCloseUpMode = false;
      _resetTransform();
      _decodeSelectedImageInBackground();
    } else if (widget.state.isFullImageConfirmed !=
        oldWidget.state.isFullImageConfirmed) {
      _useFullCloseUpMode = widget.state.isFullImageConfirmed;
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
    if (ClassificationController.isHeicHeader(bytes)) {
      _decodedImage?.dispose();
      _decodedImage = null;
      _decodedForBytes = bytes;
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
    if (classifyImmediately) {
      // Keep modal open so the modal can show the loading state and the freshness results!
      await widget.controller.classify();
    } else if (widget.isModal) {
      widget.onCloseModal?.call();
    }
  }

  Future<void> _handleConfirmFullCloseUp({
    bool classifyImmediately = false,
  }) async {
    setState(() => _useFullCloseUpMode = true);
    widget.controller.confirmFullImageAsCloseUp();
    await _completeConfirmation(classifyImmediately: classifyImmediately);
  }

  Future<void> _handleConfirmCrop(
    Size viewportSize, {
    bool classifyImmediately = false,
  }) async {
    setState(() => _useFullCloseUpMode = false);
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

  /// Automatically accepts the current crop position (or full close-up mode)
  /// and runs classification when the user presses "Validate & Classify Freshness".
  Future<void> _handleValidateAndClassifyPressed() async {
    final state = widget.state;
    final controller = widget.controller;

    if (state.isClassifying || _isCropping) return;

    // 1. If no region is selected yet, trigger the controller's region guard
    if (state.selectedRegion == null) {
      await controller.classify();
      return;
    }

    // 2. If crop/close-up hasn't been confirmed yet, automatically accept current frame
    if (!state.isCropConfirmed || state.confirmedImageBytes == null) {
      if (_useFullCloseUpMode) {
        await _handleConfirmFullCloseUp(classifyImmediately: true);
      } else {
        await _handleConfirmCrop(_lastViewportSize, classifyImmediately: true);
      }
      return;
    }

    // 3. Already confirmed -> keep modal open and classify immediately
    await controller.classify();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;

    if (widget.isModal) {
      return DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: 'Geist',
          letterSpacing: AppTypography.defaultLetterSpacing,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0x18000000),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 40,
                spreadRadius: -4,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: ColoredBox(
                color: const Color(0xEBFFFFFF),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIosModalHeader(state),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.errorMessage != null) ...[
                              _buildModalErrorBanner(state.errorMessage!),
                              const SizedBox(height: 14),
                            ],
                            if (state.latestResult != null) ...[
                              _buildModalResultView(state.latestResult!, state, controller),
                            ] else ...[
                              _buildRegionSelectionSection(state, controller),
                              const SizedBox(height: 14),
                              _buildInteractiveCropWorkspace(state, controller),
                              const SizedBox(height: 16),
                              if (state.isClassifying) ...[
                                _buildModalClassifyingStatus(state),
                                const SizedBox(height: 14),
                              ],
                              _buildPrimaryClassifyAction(state),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontFamily: 'Geist',
        letterSpacing: AppTypography.defaultLetterSpacing,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xD9F8FAFC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xCCFFFFFF), width: 1.0),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRegionSelectionSection(state, controller),
                const SizedBox(height: 14),
                if (state.isCropConfirmed && state.confirmedImageBytes != null)
                  _buildConfirmedRegionPreview(state, controller)
                else if (widget.onOpenModal != null)
                  _buildPendingModalTriggerCard(state, controller)
                else
                  _buildInteractiveCropWorkspace(state, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIosModalHeader(ClassificationState state) {
    final region = state.selectedRegion;
    final isResult = state.latestResult != null;
    final isClassifying = state.isClassifying;

    String title;
    String subtitle;
    IconData headerIcon;
    Color headerIconColor;

    if (isResult) {
      title = 'Freshness Assessment · ${region?.displayName ?? 'Tilapia'}';
      subtitle = 'Evaluation complete · Inspect results and confidence metrics below';
      headerIcon = state.latestResult!.isFresh
          ? CupertinoIcons.checkmark_seal_fill
          : CupertinoIcons.exclamationmark_triangle_fill;
      headerIconColor = state.latestResult!.statusColor;
    } else if (isClassifying) {
      title = 'Analyzing Tilapia Freshness...';
      subtitle = 'Checking anatomical cornea/gill features with MobileNetV3';
      headerIcon = CupertinoIcons.sparkles;
      headerIconColor = SariwaColors.brandPrimary;
    } else {
      title = region != null
          ? 'Frame Tilapia ${region.displayName}'
          : 'Select & Frame Region';
      subtitle = 'Hover over photo for details · Position crop and classify in one tap';
      headerIcon = CupertinoIcons.viewfinder;
      headerIconColor = SariwaColors.brandPrimary;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 14, 12),
      color: Colors.white,
      child: Column(
        children: [
          // iOS Sheet Grabber Handle
          Center(
            child: Container(
              width: 36,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: headerIconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  headerIcon,
                  size: 19,
                  color: headerIconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: AppTypography.defaultLetterSpacing,
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
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F2F7),
                  shape: const CircleBorder(),
                ),
                icon: const Icon(
                  CupertinoIcons.xmark,
                  size: 16,
                  color: Color(0xFF3C3C43),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalErrorBanner(String message) {
    return Container(
      key: const Key('modal_error_banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: SariwaColors.statusModerate.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 18,
            color: SariwaColors.statusModerate,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                letterSpacing: -0.25,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
          ),
        ],
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Anatomical Region',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                  color: SariwaColors.textPrimaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                selected != null
                    ? '${selected.displayName} (${selected.tagalogName})'
                    : 'Required',
                style: TextStyle(
                  letterSpacing: -0.25,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected != null
                      ? SariwaColors.brandPrimary
                      : SariwaColors.textMutedDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // iOS Sliding Segmented Control Track
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEF2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 300;
              final eyeSegment = _buildIosSegmentedRegionOption(
                key: const Key('region_option_eye'),
                region: AnatomicalRegion.eye,
                icon: CupertinoIcons.eye_fill,
                isSelected: selected == AnatomicalRegion.eye,
                isDisabled: state.isClassifying,
                onTap: state.isClassifying
                    ? null
                    : () => controller.selectRegion(AnatomicalRegion.eye),
              );
              final gillSegment = _buildIosSegmentedRegionOption(
                key: const Key('region_option_gill'),
                region: AnatomicalRegion.gill,
                icon: CupertinoIcons.waveform_path,
                isSelected: selected == AnatomicalRegion.gill,
                isDisabled: state.isClassifying,
                onTap: state.isClassifying
                    ? null
                    : () => controller.selectRegion(AnatomicalRegion.gill),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    eyeSegment,
                    const SizedBox(height: 4),
                    gillSegment,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: eyeSegment),
                  const SizedBox(width: 4),
                  Expanded(child: gillSegment),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIosSegmentedRegionOption({
    required Key key,
    required AnatomicalRegion region,
    required IconData icon,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.55 : 1.0,
      child: GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? SariwaColors.brandPrimary
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  '${region.displayName} · ${region.tagalogName}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.25,
                    color: isSelected
                        ? SariwaColors.textPrimaryDark
                        : const Color(0xFF4B5563),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
    final showGuidanceHud = _isHoveringViewport || _pinGuidanceOverlay;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = viewportWidth.clamp(250.0, 320.0);
        final viewportSize = Size(viewportWidth, viewportHeight);
        _lastViewportSize = viewportSize;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive Viewport with Hover Frosted-Glass Overlay
            MouseRegion(
              onEnter: (_) => setState(() => _isHoveringViewport = true),
              onExit: (_) => setState(() => _isHoveringViewport = false),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  key: const Key('interactive_crop_viewport'),
                  width: viewportWidth,
                  height: viewportHeight,
                  color: const Color(0xFF0B1317),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InteractiveViewer(
                        transformationController: _transformController,
                        minScale: _minScale,
                        maxScale: _maxScale,
                        boundaryMargin: const EdgeInsets.all(120),
                        panEnabled: !_useFullCloseUpMode,
                        scaleEnabled: !_useFullCloseUpMode,
                        child: SizedBox(
                          width: viewportWidth,
                          height: viewportHeight,
                          child: _buildSafeMemoryImage(
                            state.selectedImageBytes!,
                            state.selectedImageName,
                          ),
                        ),
                      ),

                      // iOS Photos-style Crop Reticle (hidden when Full Close-Up mode is active)
                      if (!_useFullCloseUpMode)
                        const IgnorePointer(
                          child: CustomPaint(
                            painter: _RoiCropReticlePainter(
                              cropWindowFraction: _cropWindowFraction,
                              accentColor: Colors.white,
                            ),
                          ),
                        ),

                      // Top Floating iOS Frosted-Glass Bar (Filename + Info Toggle + Replace Image)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _isHoveringViewport ? 1.0 : 0.90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 14,
                                      sigmaY: 14,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x991C1C1E),
                                        borderRadius: BorderRadius.circular(99),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.16),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            CupertinoIcons.photo,
                                            size: 13,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              state.selectedImageName ??
                                                  'tilapia_scan.jpg',
                                              style: const TextStyle(
                                                letterSpacing: -0.25,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Info toggle pill for touch devices
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _pinGuidanceOverlay =
                                          !_pinGuidanceOverlay,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(
                                          sigmaX: 4,
                                          sigmaY: 4,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(6.5),
                                          decoration: BoxDecoration(
                                            color: showGuidanceHud
                                                ? SariwaColors.brandPrimary
                                                : const Color(0x991C1C1E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.18),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.info,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Frosted-Glass Replace Image Pill
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(
                                        sigmaX: 4,
                                        sigmaY: 4,
                                      ),
                                      child: Material(
                                        color: const Color(0x991C1C1E),
                                        child: InkWell(
                                          key: const Key('replace_image_button'),
                                          onTap: state.isClassifying
                                              ? null
                                              : () =>
                                                  controller.clearSelection(),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 11,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(99),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.16),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .arrow_2_squarepath,
                                                  size: 13,
                                                  color: Color(0xFFFF6B6B),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Replace Image',
                                                  style: TextStyle(
                                                    letterSpacing: -0.25,
                                                    color: Colors.white,
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Hover-Revealed Bottom Frosted-Glass Guidance HUD
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: IgnorePointer(
                          ignoring: !showGuidanceHud,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            opacity: showGuidanceHud ? 1.0 : 0.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC1C1C1E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.16),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Eye: Select the fish's visible eye and surrounding area.",
                                        style: TextStyle(
                                          letterSpacing: -0.25,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Gill: Select exposed gill tissue, not the external gill cover.',
                                        style: TextStyle(
                                          letterSpacing: -0.25,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Drag to reposition and pinch or slide to zoom the ${region?.displayName.toLowerCase() ?? 'target'} inside the frame, or switch to Full Close-Up.',
                                        style: const TextStyle(
                                          letterSpacing: -0.25,
                                          fontSize: 10.5,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Note: Selecting Eye or Gill specifies which region you are submitting; it does not automatically verify that the image contains Tilapia or that anatomical part.',
                                        style: TextStyle(
                                          letterSpacing: -0.25,
                                          fontSize: 10,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (_isCropping)
                        Container(
                          color: Colors.black45,
                          child: const Center(
                            child: CupertinoActivityIndicator(
                              radius: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Unified iOS Framing Mode Toggle + Smooth Zoom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  // Framing Mode Pill Switch: Frame Region vs Full Close-Up
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            key: const Key('confirm_crop_button'),
                            behavior: HitTestBehavior.opaque,
                            onTap: _isCropping
                                ? null
                                : () {
                                    setState(() => _useFullCloseUpMode = false);
                                    if (state.selectedRegion != null) {
                                      _handleConfirmCrop(viewportSize);
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: !_useFullCloseUpMode
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: !_useFullCloseUpMode
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x12000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.crop,
                                    size: 14,
                                    color: !_useFullCloseUpMode
                                        ? SariwaColors.brandPrimary
                                        : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Frame Region',
                                      style: TextStyle(
                                        letterSpacing: -0.25,
                                        fontSize: 12,
                                        fontWeight: !_useFullCloseUpMode
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: !_useFullCloseUpMode
                                            ? SariwaColors.textPrimaryDark
                                            : const Color(0xFF6B7280),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            key: const Key('confirm_full_image_button'),
                            behavior: HitTestBehavior.opaque,
                            onTap: _isCropping
                                ? null
                                : () {
                                    setState(() => _useFullCloseUpMode = true);
                                    if (state.selectedRegion != null) {
                                      _handleConfirmFullCloseUp();
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _useFullCloseUpMode
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: _useFullCloseUpMode
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x12000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.fullscreen,
                                    size: 14,
                                    color: _useFullCloseUpMode
                                        ? SariwaColors.brandPrimary
                                        : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Full Close-Up',
                                      style: TextStyle(
                                        letterSpacing: -0.25,
                                        fontSize: 12,
                                        fontWeight: _useFullCloseUpMode
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _useFullCloseUpMode
                                            ? SariwaColors.textPrimaryDark
                                            : const Color(0xFF6B7280),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!_useFullCloseUpMode) ...[
                    const SizedBox(height: 6),
                    // iOS-style Thin Zoom Slider Row
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Zoom Out',
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              _setZoomScale(_currentScale - 0.5, viewportSize),
                          icon: const Icon(
                            CupertinoIcons.minus_circle,
                            size: 18,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: SariwaColors.brandPrimary,
                              inactiveTrackColor: const Color(0xFFE5E7EB),
                              thumbColor: Colors.white,
                              overlayColor: SariwaColors.brandPrimary
                                  .withValues(alpha: 0.10),
                              trackHeight: 3.0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                                elevation: 2,
                              ),
                            ),
                            child: Slider(
                              key: const Key('crop_zoom_slider'),
                              value: _currentScale.clamp(_minScale, _maxScale),
                              min: _minScale,
                              max: _maxScale,
                              onChanged: (val) =>
                                  _setZoomScale(val, viewportSize),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Zoom In',
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              _setZoomScale(_currentScale + 0.5, viewportSize),
                          icon: const Icon(
                            CupertinoIcons.plus_circle,
                            size: 18,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        GestureDetector(
                          onTap: _resetTransform,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${_currentScale.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                letterSpacing: -0.25,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: SariwaColors.textPrimaryDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Dedicated Classification Loading Status Card inside the Modal
  Widget _buildModalClassifyingStatus(ClassificationState state) {
    final stageText = state.processingStage ?? 'Analyzing Tilapia freshness...';
    return Container(
      key: const Key('modal_classifying_status'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SariwaColors.brandPrimary.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const CupertinoActivityIndicator(radius: 8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evaluating Tilapia Freshness...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stageText,
                      style: const TextStyle(
                        fontSize: 11.5,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              minHeight: 5,
              backgroundColor: Color(0xFFE2E8F0),
              color: SariwaColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Freshness Result View displayed directly inside the iOS ROI Modal
  Widget _buildModalResultView(
    ClassificationResult result,
    ClassificationState state,
    ClassificationController controller,
  ) {
    final isFresh = result.isFresh;
    final statusColor = result.statusColor;

    return Container(
      key: const Key('modal_classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Confirmed / Framed Image Thumbnail
          if (state.confirmedImageBytes != null ||
              state.selectedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: _buildSafeMemoryImage(
                  state.confirmedImageBytes ?? state.selectedImageBytes!,
                  state.selectedImageName,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 2. SlothUI-style Result Breakdown Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.30),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        isFresh
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.exclamationmark_triangle,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      result.label,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: statusColor,
                                      ),
                                    ),
                                    if (result.selectedRegionLabel != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          result.selectedRegionLabel!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: AppTypography.defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                isFresh
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons.exclamationmark_circle_fill,
                                color: statusColor,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Model Confidence: ${result.formattedConfidence}',
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing:
                                        AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.textPrimaryDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                result.formattedConfidence,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          if (result.modelVersion != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Model: ${result.modelVersion}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Save Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.saved
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.info_circle,
                  size: 16,
                  color: result.saved
                      ? SariwaColors.brandPrimary
                      : SariwaColors.textSecondaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.saveStatusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: result.saved
                          ? SariwaColors.brandPrimary
                          : SariwaColors.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Preliminary Disclaimer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Text(
              result.disclaimer,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
                letterSpacing: AppTypography.defaultLetterSpacing,
                color: SariwaColors.textSecondaryDark,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Modal Action Buttons (Done, Adjust Crop)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    key: const Key('modal_result_done_button'),
                    onPressed: widget.onCloseModal,
                    icon: const Icon(CupertinoIcons.checkmark_alt, size: 16),
                    label: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SariwaColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    key: const Key('modal_result_edit_crop_button'),
                    onPressed: () => controller.editCrop(),
                    icon: const Icon(CupertinoIcons.crop, size: 14),
                    label: const Text(
                      'Adjust Crop',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SariwaColors.brandPrimary,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Single Primary iOS Action Button: pressing "Validate & Classify Freshness"
  /// immediately accepts the current crop position (or Full Close-Up mode) and classifies.
  Widget _buildPrimaryClassifyAction(ClassificationState state) {
    final statusText = state.processingStage ?? 'Analyzing image...';

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        key: const Key('validate_and_classify_button'),
        onPressed: state.isClassifying || _isCropping
            ? null
            : _handleValidateAndClassifyPressed,
        icon: state.isClassifying
            ? const CupertinoActivityIndicator(radius: 9, color: Colors.white)
            : const Icon(CupertinoIcons.sparkles, size: 18),
        label: Text(
          state.isClassifying ? statusText : 'Validate & Classify Freshness',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: SariwaColors.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingModalTriggerCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return Container(
      key: const Key('pending_crop_modal_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.photo,
                      size: 16,
                      color: SariwaColors.brandPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.selectedImageName ?? 'tilapia_scan.jpg',
                        style: const TextStyle(
                          letterSpacing: -0.25,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: SariwaColors.textPrimaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                key: const Key('replace_image_button'),
                onPressed: state.isClassifying
                    ? null
                    : () => controller.clearSelection(),
                icon: const Icon(
                  CupertinoIcons.arrow_2_squarepath,
                  size: 14,
                  color: SariwaColors.statusSpoiled,
                ),
                label: const Text(
                  'Replace Image',
                  style: TextStyle(
                    letterSpacing: -0.25,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.statusSpoiled,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                key: const Key('open_crop_modal_button'),
                onPressed: widget.onOpenModal,
                icon: const Icon(CupertinoIcons.crop, size: 16),
                label: const Text('Adjust Crop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SariwaColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              OutlinedButton.icon(
                key: const Key('confirm_full_image_button'),
                onPressed: () => _handleConfirmFullCloseUp(),
                icon: const Icon(CupertinoIcons.fullscreen, size: 15),
                label: const Text('Full Close-Up'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.textPrimaryDark,
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
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
                  const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    size: 16,
                    color: SariwaColors.brandPrimary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Confirmed ${region?.displayName ?? ''} Region Ready',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  state.isFullImageConfirmed
                      ? 'Full Close-Up'
                      : 'Cropped Photo',
                  style: const TextStyle(
                    letterSpacing: -0.25,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preview Viewport with Floating iOS Glass Controls on Hover
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringViewport = true),
            onExit: (_) => setState(() => _isHoveringViewport = false),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                width: double.infinity,
                color: const Color(0xFF0B1317),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSafeMemoryImage(
                      state.confirmedImageBytes!,
                      state.selectedImageName,
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _isHoveringViewport ? 1.0 : 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(
                                    sigmaX: 4,
                                    sigmaY: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x991C1C1E),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      state.selectedImageName ??
                                          'tilapia_scan.jpg',
                                      style: const TextStyle(
                                        letterSpacing: -0.25,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 4,
                                  sigmaY: 4,
                                ),
                                child: Material(
                                  color: const Color(0x991C1C1E),
                                  child: InkWell(
                                    key: const Key('replace_image_button'),
                                    onTap: state.isClassifying
                                        ? null
                                        : () => controller.clearSelection(),
                                    borderRadius: BorderRadius.circular(99),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.arrow_2_squarepath,
                                            size: 12,
                                            color: Color(0xFFFF6B6B),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Replace Image',
                                            style: TextStyle(
                                              letterSpacing: -0.25,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                  'Region: ${region?.displayName ?? ''} (${region?.tagalogName ?? ''})',
                  style: const TextStyle(
                    letterSpacing: -0.25,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
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
                icon: const Icon(CupertinoIcons.crop, size: 14),
                label: const Text('Edit Crop'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.brandPrimary,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  backgroundColor: const Color(0xFFF9FAFB),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafeMemoryImage(Uint8List bytes, String? filename) {
    if (ClassificationController.isHeicHeader(bytes)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.photo_on_rectangle,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              filename ?? 'iOS HEIC Photo Ready',
              style: const TextStyle(
                letterSpacing: -0.25,
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ready to frame and classify',
              style: TextStyle(
                letterSpacing: -0.25,
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }
    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.photo_on_rectangle,
              color: Colors.white70,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              filename ?? 'HEIC / Image Ready',
              style: const TextStyle(
                letterSpacing: -0.25,
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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

    // iOS Photos-style translucent scrim outside the crop window
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cropRect, const Radius.circular(18)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = const Color(0x80000000),
    );

    // Hairline white border around crop window
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cropRect, const Radius.circular(18)),
      borderPaint,
    );

    // Ultra-fine iOS rule-of-thirds grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (var i = 1; i <= 2; i++) {
      final dx = cropRect.left + (cropRect.width * i / 3);
      final dy = cropRect.top + (cropRect.height * i / 3);
      canvas.drawLine(
        Offset(dx, cropRect.top + 4),
        Offset(dx, cropRect.bottom - 4),
        gridPaint,
      );
      canvas.drawLine(
        Offset(cropRect.left + 4, dy),
        Offset(cropRect.right - 4, dy),
        gridPaint,
      );
    }

    // Clean iOS corner handles
    final cornerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 20.0;
    final l = cropRect.left;
    final t = cropRect.top;
    final r = cropRect.right;
    final b = cropRect.bottom;

    canvas.drawLine(Offset(l, t + cornerLen), Offset(l, t + 6), cornerPaint);
    canvas.drawLine(Offset(l + 6, t), Offset(l + cornerLen, t), cornerPaint);

    canvas.drawLine(Offset(r - cornerLen, t), Offset(r - 6, t), cornerPaint);
    canvas.drawLine(Offset(r, t + 6), Offset(r, t + cornerLen), cornerPaint);

    canvas.drawLine(Offset(l, b - cornerLen), Offset(l, b - 6), cornerPaint);
    canvas.drawLine(Offset(l + 6, b), Offset(l + cornerLen, b), cornerPaint);

    canvas.drawLine(Offset(r - cornerLen, b), Offset(r - 6, b), cornerPaint);
    canvas.drawLine(Offset(r, b - cornerLen), Offset(r, b - 6), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _RoiCropReticlePainter oldDelegate) {
    return oldDelegate.cropWindowFraction != cropWindowFraction ||
        oldDelegate.accentColor != accentColor;
  }
}
