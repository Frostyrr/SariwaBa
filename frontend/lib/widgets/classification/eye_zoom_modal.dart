import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Reusable thumbnail wrapper that reveals a smooth magnifier overlay on hover
/// (and a subtle corner badge for touch devices) and opens [EyeZoomModal] on click/tap.
class HoverZoomEyePreview extends StatefulWidget {
  final Uint8List imageBytes;
  final double width;
  final double height;
  final double borderRadius;
  final String semanticLabel;
  final String tooltip;
  final VoidCallback onTapZoom;

  const HoverZoomEyePreview({
    super.key,
    required this.imageBytes,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.semanticLabel = 'Zoom selected eye preview',
    this.tooltip = 'Click to zoom selected eye',
    required this.onTapZoom,
  });

  @override
  State<HoverZoomEyePreview> createState() => _HoverZoomEyePreviewState();
}

class _HoverZoomEyePreviewState extends State<HoverZoomEyePreview> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      image: true,
      label: widget.semanticLabel,
      child: Tooltip(
        message: widget.tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTapZoom();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: _isHovered
                      ? SariwaColors.brandPrimary
                      : SariwaColors.borderLightTeal,
                  width: _isHovered ? 1.8 : 1.0,
                ),
                boxShadow: _isHovered
                    ? const [
                        BoxShadow(
                          color: Color(0x24168077),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  (widget.borderRadius - 1.5).clamp(4.0, 32.0),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      widget.imageBytes,
                      fit: BoxFit.cover,
                    ),
                    // Subtle corner indicator when idle so touch users see it is zoomable
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: AnimatedOpacity(
                        opacity: _isHovered ? 0.0 : 0.92,
                        duration: const Duration(milliseconds: 160),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xBF0A1926),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                              width: 0.8,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.zoom_in,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Full hover scrim with crisp zoom icon
                    IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          color: const Color(0x8C0A1926),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.zoom_in,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive lightbox / zoom modal for inspecting selected Tilapia eye crops up close.
/// Styled with an elevated gallery stage, floating side carousel arrows, and a bottom
/// counter pill inspired by the reference design.
class EyeZoomModal extends StatefulWidget {
  final List<Uint8List> images;
  final int initialIndex;
  final String Function(int index, int total)? titleBuilder;
  final ValueChanged<int>? onIndexChanged;

  const EyeZoomModal({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.titleBuilder,
    this.onIndexChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Uint8List> images,
    int initialIndex = 0,
    String Function(int index, int total)? titleBuilder,
    ValueChanged<int>? onIndexChanged,
  }) {
    if (images.isEmpty) return Future.value();
    final safeInitial = initialIndex.clamp(0, images.length - 1);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x660A1926),
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: EyeZoomModal(
          images: images,
          initialIndex: safeInitial,
          titleBuilder: titleBuilder,
          onIndexChanged: onIndexChanged,
        ),
      ),
    );
  }

  @override
  State<EyeZoomModal> createState() => _EyeZoomModalState();
}

class _EyeZoomModalState extends State<EyeZoomModal> {
  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;

  late int _currentIndex;
  late final TransformationController _transformController;
  final FocusNode _focusNode = FocusNode();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _transformController = TransformationController()
      ..addListener(_handleTransformChanged);
  }

  @override
  void dispose() {
    _transformController.removeListener(_handleTransformChanged);
    _transformController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01 && mounted) {
      setState(() => _currentScale = scale.clamp(_minScale, _maxScale));
    }
  }

  void _setZoom(double targetScale) {
    final clamped = targetScale.clamp(_minScale, _maxScale);
    if ((clamped - 1.0).abs() < 0.02) {
      _transformController.value = Matrix4.identity();
    } else {
      // Scale around viewport origin
      _transformController.value = Matrix4.diagonal3Values(
        clamped,
        clamped,
        1.0,
      );
    }
    setState(() => _currentScale = clamped);
  }

  void _stepZoom(double delta) {
    HapticFeedback.selectionClick();
    _setZoom(_currentScale + delta);
  }

  void _resetZoom() {
    HapticFeedback.selectionClick();
    _transformController.value = Matrix4.identity();
    setState(() => _currentScale = 1.0);
  }

  void _goToIndex(int nextIndex) {
    if (widget.images.length <= 1) return;
    final wrapped =
        (nextIndex + widget.images.length) % widget.images.length;
    HapticFeedback.selectionClick();
    _transformController.value = Matrix4.identity();
    setState(() {
      _currentIndex = wrapped;
      _currentScale = 1.0;
    });
    widget.onIndexChanged?.call(wrapped);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft && widget.images.length > 1) {
      _goToIndex(_currentIndex - 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight && widget.images.length > 1) {
      _goToIndex(_currentIndex + 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.numpadAdd) {
      _stepZoom(0.5);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract) {
      _stepZoom(-0.5);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.digit0) {
      _resetZoom();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isCompact = screen.width < 600;
    final hasMultiple = widget.images.length > 1;
    final title = widget.titleBuilder != null
        ? widget.titleBuilder!(_currentIndex, widget.images.length)
        : (hasMultiple
              ? 'Selected Eye #${_currentIndex + 1}'
              : 'Selected Eye Close-Up');
    final zoomPct = (_currentScale * 100).round();

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        key: const Key('eye_zoom_modal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isCompact ? 14 : 28,
          vertical: isCompact ? 20 : 28,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Elevated white gallery card frame
                    Container(
                      padding: EdgeInsets.all(isCompact ? 14 : 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.95),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x330A1926),
                            blurRadius: 40,
                            offset: Offset(0, 18),
                            spreadRadius: -6,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Modal header with title + zoom controls + close
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: SariwaColors.brandPrimary
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.eye_fill,
                                      size: 16,
                                      color: SariwaColors.brandPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing:
                                          AppTypography.defaultLetterSpacing,
                                      color: SariwaColors.textPrimaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildControlIconButton(
                                    key: const Key('eye_zoom_out_button'),
                                    icon: CupertinoIcons.zoom_out,
                                    tooltip: 'Zoom out',
                                    enabled: _currentScale > _minScale + 0.05,
                                    onTap: () => _stepZoom(-0.5),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    key: const Key('eye_zoom_reset_pill'),
                                    onTap: _currentScale > 1.02
                                        ? _resetZoom
                                        : null,
                                    child: MouseRegion(
                                      cursor: _currentScale > 1.02
                                          ? SystemMouseCursors.click
                                          : SystemMouseCursors.basic,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(99),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Text(
                                          '$zoomPct%',
                                          key: const Key(
                                            'eye_zoom_scale_label',
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Geist',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: SariwaColors.textPrimaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildControlIconButton(
                                    key: const Key('eye_zoom_in_button'),
                                    icon: CupertinoIcons.zoom_in,
                                    tooltip: 'Zoom in',
                                    enabled: _currentScale < _maxScale - 0.05,
                                    onTap: () => _stepZoom(0.5),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildControlIconButton(
                                    key: const Key('eye_zoom_close_button'),
                                    icon: CupertinoIcons.xmark,
                                    tooltip: 'Close zoom preview',
                                    enabled: true,
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Dark studio inspection viewport with InteractiveViewer
                          Flexible(
                            child: AspectRatio(
                              aspectRatio: isCompact ? 1.05 : 1.32,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  color: const Color(0xFF0B1620),
                                  child: GestureDetector(
                                    onDoubleTap: () {
                                      HapticFeedback.selectionClick();
                                      if (_currentScale > 1.2) {
                                        _resetZoom();
                                      } else {
                                        _setZoom(2.5);
                                      }
                                    },
                                    child: InteractiveViewer(
                                      key: const Key(
                                        'eye_zoom_interactive_viewer',
                                      ),
                                      transformationController:
                                          _transformController,
                                      minScale: _minScale,
                                      maxScale: _maxScale,
                                      panEnabled: true,
                                      scaleEnabled: true,
                                      clipBehavior: Clip.hardEdge,
                                      child: Center(
                                        child: Image.memory(
                                          widget.images[_currentIndex],
                                          key: ValueKey(
                                            'zoom_eye_img_$_currentIndex',
                                          ),
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Scroll, pinch, or double-tap to zoom in up to 500% and drag to pan.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Reference-style floating circular Left / Right navigation arrows
                    if (hasMultiple) ...[
                      Positioned(
                        left: isCompact ? 6 : -18,
                        child: _buildFloatingCarouselArrow(
                          key: const Key('eye_zoom_prev_button'),
                          icon: CupertinoIcons.arrow_left,
                          tooltip: 'Previous eye',
                          onTap: () => _goToIndex(_currentIndex - 1),
                        ),
                      ),
                      Positioned(
                        right: isCompact ? 6 : -18,
                        child: _buildFloatingCarouselArrow(
                          key: const Key('eye_zoom_next_button'),
                          icon: CupertinoIcons.arrow_right,
                          tooltip: 'Next eye',
                          onTap: () => _goToIndex(_currentIndex + 1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Reference-style centered bottom pill ("Eye 1 of 2")
              Container(
                key: const Key('eye_zoom_counter_pill'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x260A1926),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  hasMultiple
                      ? 'Eye ${_currentIndex + 1} of ${widget.images.length}'
                      : 'Eye 1 of 1',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlIconButton({
    Key? key,
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: MouseRegion(
          cursor: enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: key,
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: enabled
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: enabled
                      ? SariwaColors.textPrimaryDark
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCarouselArrow({
    Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            shadowColor: const Color(0x330A1926),
            child: InkWell(
              key: key,
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
