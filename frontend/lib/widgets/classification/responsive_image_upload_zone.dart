import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/timber_typography.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../services/upload/web_drag_drop_service.dart';

/// Production-ready responsive image upload component for SariwaBa?.
///
/// Features:
/// - Clickable/tappable upload surface (opens gallery on click/tap).
/// - Keyboard accessible on web (Enter and Space triggers file selection with visible focus ring).
/// - Web drag-and-drop with "Release to upload" feedback and browser navigation prevention.
/// - Adaptive layout: desktop footer row (Eye/Gill on left, Use Camera on right);
///   mobile vertical stack (full-width Take a Photo, full-width Eye/Gill selector).
/// - SVG-free, zero-dependency subtle dashed border painter.
/// - Accessible semantics and high contrast WCAG 2.1 AA compliant.
class ResponsiveImageUploadZone extends StatefulWidget {
  final ClassificationState state;
  final ClassificationController controller;

  const ResponsiveImageUploadZone({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  State<ResponsiveImageUploadZone> createState() =>
      _ResponsiveImageUploadZoneState();
}

class _ResponsiveImageUploadZoneState extends State<ResponsiveImageUploadZone> {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isDragOver = false;
  WebDragDropService? _webDragDropService;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _webDragDropService = WebDragDropService.create()
        ..initialize(
          onDragStateChanged: (isDragging) {
            if (mounted && _isDragOver != isDragging) {
              setState(() => _isDragOver = isDragging);
            }
          },
          onFileDropped: (Uint8List bytes, String filename) {
            if (mounted) {
              setState(() => _isDragOver = false);
              widget.controller.setSelectedImage(
                bytes: bytes,
                filename: filename,
              );
            }
          },
        );
    }
  }

  @override
  void dispose() {
    _webDragDropService?.dispose();
    super.dispose();
  }

  bool _isMobileLayout(BoxConstraints constraints) {
    return constraints.maxWidth < 560;
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final animDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = _isMobileLayout(constraints);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Primary Interactive Upload Zone
            _buildUploadSurface(context, isMobile, animDuration),

            const SizedBox(height: 16),

            // 2. Dedicated Controls Beneath Upload Zone
            if (isMobile)
              _buildMobileControls(context, animDuration)
            else
              _buildDesktopFooterRow(context, animDuration),
          ],
        );
      },
    );
  }

  Widget _buildUploadSurface(
    BuildContext context,
    bool isMobile,
    Duration animDuration,
  ) {
    final bool isHighlighted = _isDragOver || _isHovered;

    final Color surfaceBg = _isDragOver
        ? SariwaColors.brandPrimary.withValues(alpha: 0.08)
        : (_isHovered
            ? SariwaColors.brandPrimary.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65));

    final Color borderColor = _isDragOver
        ? SariwaColors.brandPrimary
        : (_isHovered
            ? SariwaColors.brandPrimary.withValues(alpha: 0.50)
            : (_isFocused
                ? SariwaColors.brandPrimary
                : const Color(0xFFCBD5E1)));

    final double strokeWidth = _isDragOver ? 2.0 : 1.5;

    final String instructionText = _isDragOver
        ? 'Release to upload image'
        : (isMobile
            ? 'Tap to select an image'
            : 'Drop an image here, or click to browse');

    final String semanticLabel = isMobile
        ? 'Fish specimen upload zone. Tap to select an image from your device.'
        : 'Fish specimen upload dropzone. Drop an image here or press Enter to browse files.';

    return FocusableActionDetector(
      enabled: !widget.state.isUploadingImage,
      autofocus: false,
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (val) {
        if (_isHovered != val) setState(() => _isHovered = val);
      },
      onShowFocusHighlight: (val) {
        if (_isFocused != val) setState(() => _isFocused = val);
      },
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (!widget.state.isUploadingImage) {
              widget.controller.pickImage(ImageSource.gallery);
            }
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        enabled: !widget.state.isUploadingImage,
        label: semanticLabel,
        excludeSemantics: true,
        onTap: widget.state.isUploadingImage
            ? null
            : () => widget.controller.pickImage(ImageSource.gallery),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: SariwaColors.brandPrimary.withValues(alpha: 0.25),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('empty_upload_dropzone'),
              borderRadius: BorderRadius.circular(20),
              onTap: widget.state.isUploadingImage
                  ? null
                  : () => widget.controller.pickImage(ImageSource.gallery),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: borderColor,
                  strokeWidth: strokeWidth,
                  dashLength: 7.0,
                  dashGap: 5.0,
                  borderRadius: 20.0,
                ),
                child: AnimatedContainer(
                  duration: animDuration,
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 32 : 44,
                    horizontal: isMobile ? 20 : 32,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Refined Upload Icon Container
                      AnimatedContainer(
                        duration: animDuration,
                        width: isMobile ? 48 : 52,
                        height: isMobile ? 48 : 52,
                        decoration: BoxDecoration(
                          color: isHighlighted
                              ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isHighlighted
                                ? SariwaColors.brandPrimary.withValues(
                                    alpha: 0.35,
                                  )
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isHighlighted
                                  ? SariwaColors.brandPrimary.withValues(
                                      alpha: 0.18,
                                    )
                                  : const Color(0x0A0F172A),
                              blurRadius: isHighlighted ? 14 : 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _isDragOver
                                ? CupertinoIcons.arrow_down_doc_fill
                                : CupertinoIcons.arrow_up_doc,
                            size: isMobile ? 22 : 24,
                            color: isHighlighted
                                ? SariwaColors.brandPrimary
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Primary Instructional Text
                      Text(
                        instructionText,
                        style: TextStyle(
                          fontFamily: TimberTypography.primarySansFamily,
                          fontSize: isMobile ? 14.5 : 15.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                          color: SariwaColors.textPrimaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Supporting Format and Constraint Metadata
                      Text(
                        'JPG, JPEG, PNG, HEIC · Max 5 MB',
                        style: TextStyle(
                          fontFamily: TimberTypography.primarySansFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.1,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Desktop / Tablet Wide Layout: Segmented Region Selector on Left, Use Camera on Right
  Widget _buildDesktopFooterRow(BuildContext context, Duration animDuration) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Eye | Gill Segmented Control with subtle label
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Inspection Region:',
                style: TextStyle(
                  fontFamily: TimberTypography.primarySansFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 10),
              _buildRegionSegmentedSelector(animDuration, isFullWidth: false),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right: Secondary Outlined Camera Action
        _buildDesktopCameraButton(animDuration),
      ],
    );
  }

  /// Mobile Layout: Full-width Take a Photo, then full-width Eye | Gill selector
  Widget _buildMobileControls(BuildContext context, Duration animDuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-width secondary Take a Photo button
        _buildMobilePhotoButton(),

        const SizedBox(height: 14),

        // Dedicated Inspection Region Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inspection Region',
              style: TextStyle(
                fontFamily: TimberTypography.primarySansFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            _buildRegionSegmentedSelector(animDuration, isFullWidth: true),
          ],
        ),
      ],
    );
  }

  /// Compact Segmented Control: Eye | Gill
  Widget _buildRegionSegmentedSelector(
    Duration animDuration, {
    required bool isFullWidth,
  }) {
    final selectedRegion =
        widget.state.selectedRegion ?? AnatomicalRegion.eye;

    final eyeSelected = selectedRegion == AnatomicalRegion.eye;
    final gillSelected = selectedRegion == AnatomicalRegion.gill;

    Widget eyeSegment = _buildSegmentOption(
      key: const Key('region_option_eye'),
      label: 'Eye',
      tagalogName: 'Mata',
      icon: CupertinoIcons.eye_fill,
      isSelected: eyeSelected,
      animDuration: animDuration,
      onTap: () => widget.controller.selectRegion(AnatomicalRegion.eye),
    );

    Widget gillSegment = _buildSegmentOption(
      key: const Key('region_option_gill'),
      label: 'Gill',
      tagalogName: 'Hasang',
      icon: CupertinoIcons.waveform_path,
      isSelected: gillSelected,
      animDuration: animDuration,
      onTap: () => widget.controller.selectRegion(AnatomicalRegion.gill),
    );

    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: isFullWidth
          ? Row(
              children: [
                Expanded(child: eyeSegment),
                const SizedBox(width: 4),
                Expanded(child: gillSegment),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                eyeSegment,
                const SizedBox(width: 4),
                gillSegment,
              ],
            ),
    );
  }

  Widget _buildSegmentOption({
    required Key key,
    required String label,
    required String tagalogName,
    required IconData icon,
    required bool isSelected,
    required Duration animDuration,
    required VoidCallback onTap,
  }) {
    return Semantics(
      selected: isSelected,
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      label: '$label ($tagalogName) region',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: animDuration,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              border: isSelected
                  ? Border.all(color: const Color(0xFFE2E8F0), width: 0.8)
                  : Border.all(color: Colors.transparent, width: 0.8),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x100F172A),
                        blurRadius: 4,
                        offset: Offset(0, 1.5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? SariwaColors.brandPrimary
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: TimberTypography.primarySansFamily,
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      letterSpacing: -0.1,
                      color: isSelected
                          ? SariwaColors.textPrimaryDark
                          : const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact Outlined "Use Camera" Button for Desktop / Tablet
  Widget _buildDesktopCameraButton(Duration animDuration) {
    return OutlinedButton.icon(
      key: const Key('use_camera_button'),
      onPressed: widget.state.isUploadingImage
          ? null
          : () => widget.controller.pickImage(ImageSource.camera),
      icon: const Icon(
        CupertinoIcons.camera,
        size: 15,
        color: Color(0xFF334155),
      ),
      label: const Text('Use Camera'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF334155),
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        backgroundColor: Colors.white.withValues(alpha: 0.90),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontFamily: TimberTypography.primarySansFamily,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  /// Full-width Outlined "Take a Photo" Button for Mobile
  Widget _buildMobilePhotoButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        key: const Key('use_camera_button'),
        onPressed: widget.state.isUploadingImage
            ? null
            : () => widget.controller.pickImage(ImageSource.camera),
        icon: const Icon(
          CupertinoIcons.camera_fill,
          size: 16,
          color: SariwaColors.brandPrimary,
        ),
        label: const Text('Take a Photo'),
        style: OutlinedButton.styleFrom(
          foregroundColor: SariwaColors.textPrimaryDark,
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          backgroundColor: Colors.white.withValues(alpha: 0.90),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: TimberTypography.primarySansFamily,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

/// Zero-dependency custom painter that renders a smooth dashed rounded rectangle border.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 7.0,
    this.dashGap = 5.0,
    this.borderRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashLength < metric.length)
            ? dashLength
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.borderRadius != borderRadius;
  }
}
