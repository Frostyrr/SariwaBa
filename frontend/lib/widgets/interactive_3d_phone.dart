import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../constants/theme/app_colors.dart';
import '../constants/theme/app_typography.dart';

/// Displays a pre-rendered transparent 3D phone mockup on a minimalist dot-grid stage
/// with resting tilt, straighten + cursor-tracking 3D tilt on hover, opposite-moving
/// ambient shadow, and parting glassmorphic floating chips.
class Interactive3DPhone extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double height;
  final double imageScale;
  final double maxTiltRadians;
  final double restingRotateZ;
  final double hoverScale;
  final bool showFloatingChips;
  final String semanticLabel;

  const Interactive3DPhone({
    super.key,
    this.assetPath = 'assets/images/hero_phone_mockup.png',
    this.width,
    this.height = 590.0,
    this.imageScale = 1.12,
    this.maxTiltRadians = 0.08,
    this.restingRotateZ = -0.05,
    this.hoverScale = 1.03,
    this.showFloatingChips = true,
    this.semanticLabel = 'SariwaBa mobile freshness scanner preview',
  });

  @override
  State<Interactive3DPhone> createState() => _Interactive3DPhoneState();
}

class _Interactive3DPhoneState extends State<Interactive3DPhone>
    with SingleTickerProviderStateMixin {
  static const Cubic _glideCurve = Cubic(0.22, 1, 0.36, 1);
  static const Duration _glideDuration = Duration(milliseconds: 300);

  late final AnimationController _floatController;
  late final Animation<double> _floatOffset;

  bool _isHovering = false;
  double _targetX = 0.0; // normalized -1.0..1.0
  double _targetY = 0.0; // normalized -1.0..1.0

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _floatOffset = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      if (_floatController.isAnimating) {
        _floatController.stop();
      }
    } else if (!_floatController.isAnimating) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _handleHover(PointerEvent event) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final size = renderBox.size;
    if (size.width <= 0 || size.height <= 0) return;

    final local = renderBox.globalToLocal(event.position);
    final nx = ((local.dx / size.width) * 2.0 - 1.0).clamp(-1.0, 1.0);
    final ny = ((local.dy / size.height) * 2.0 - 1.0).clamp(-1.0, 1.0);

    if (!_isHovering ||
        (nx - _targetX).abs() > 0.004 ||
        (ny - _targetY).abs() > 0.004) {
      setState(() {
        _isHovering = true;
        _targetX = nx;
        _targetY = ny;
      });
    }
  }

  void _handleExit(PointerEvent _) {
    if (_isHovering || _targetX != 0.0 || _targetY != 0.0) {
      setState(() {
        _isHovering = false;
        _targetX = 0.0;
        _targetY = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final stageWidth = widget.width ?? (widget.height * 0.82);

    final phoneImage = Semantics(
      image: true,
      label: widget.semanticLabel,
      child: Transform.scale(
        scale: widget.imageScale,
        child: Image.asset(
          widget.assetPath,
          height: widget.height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );

    if (disableAnimations) {
      return RepaintBoundary(
        child: SizedBox(
          width: stageWidth,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _buildDotGridStage(stageWidth, widget.height),
              Positioned(bottom: 12, child: _buildAmbientShadow(stageWidth)),
              phoneImage,
              if (widget.showFloatingChips) ...[
                Positioned(
                  top: widget.height * 0.14,
                  right: 6,
                  child: _buildEyesDetectedChip(),
                ),
                Positioned(
                  bottom: widget.height * 0.16,
                  left: 6,
                  child: _buildFreshResultChip(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: MouseRegion(
        onHover: _handleHover,
        onExit: _handleExit,
        child: SizedBox(
          width: stageWidth,
          height: widget.height,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(end: Offset(_targetX, _targetY)),
            duration: _glideDuration,
            curve: _glideCurve,
            builder: (context, smoothNorm, _) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(end: _isHovering ? 1.0 : 0.0),
                duration: _glideDuration,
                curve: _glideCurve,
                builder: (context, hoverT, _) {
                  final maxTilt = widget.maxTiltRadians.clamp(0.0, 0.08);
                  final tiltX =
                      (-smoothNorm.dy * maxTilt).clamp(-maxTilt, maxTilt);
                  final tiltY =
                      (smoothNorm.dx * maxTilt).clamp(-maxTilt, maxTilt);
                  final rotZ = widget.restingRotateZ * (1.0 - hoverT);
                  final scale = 1.0 + (widget.hoverScale - 1.0) * hoverT;

                  final matrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(tiltX)
                    ..rotateY(tiltY)
                    ..rotateZ(rotZ)
                    ..scaleByDouble(scale, scale, 1.0, 1.0);

                  return AnimatedBuilder(
                    animation: _floatOffset,
                    child: phoneImage,
                    builder: (context, child) {
                      final floatY = _floatOffset.value * (1.0 - hoverT);
                      final shadowDx = -smoothNorm.dx * 10.0;
                      final shadowDy = -smoothNorm.dy * 6.0;

                      // Parting chips glide outward ±18px on hover + subtle parallax
                      final topRightDx = 18.0 * hoverT + smoothNorm.dx * 4.0;
                      final topRightDy = -18.0 * hoverT + smoothNorm.dy * 4.0;
                      final bottomLeftDx = -18.0 * hoverT + smoothNorm.dx * 4.0;
                      final bottomLeftDy = 18.0 * hoverT + smoothNorm.dy * 4.0;

                      return Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          _buildDotGridStage(stageWidth, widget.height),
                          Positioned(
                            bottom: 12,
                            child: Transform.translate(
                              offset: Offset(shadowDx, shadowDy),
                              child: _buildAmbientShadow(stageWidth),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, floatY),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: matrix,
                              child: child,
                            ),
                          ),
                          if (widget.showFloatingChips) ...[
                            Positioned(
                              top: widget.height * 0.14,
                              right: 6,
                              child: Transform.translate(
                                offset: Offset(topRightDx, topRightDy),
                                child: _buildEyesDetectedChip(),
                              ),
                            ),
                            Positioned(
                              bottom: widget.height * 0.16,
                              left: 6,
                              child: Transform.translate(
                                offset: Offset(bottomLeftDx, bottomLeftDy),
                                child: _buildFreshResultChip(),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Minimalist monochrome dot-grid stage masked with a radial gradient + soft ambient halo
  Widget _buildDotGridStage(double width, double height) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient halo behind device
          Container(
            width: width * 0.82,
            height: height * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.90),
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Subtle 20px dot grid faded radially into #F5F5F7
          SizedBox(
            width: width,
            height: height * 0.92,
            child: ShaderMask(
              shaderCallback: (bounds) => const RadialGradient(
                center: Alignment.center,
                radius: 0.55,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.55, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: const CustomPaint(
                painter: _DotGridPainter(
                  spacing: 20.0,
                  dotRadius: 1.15,
                  color: Color(0x0A000000), // Colors.black.withOpacity(0.04)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientShadow(double stageWidth) {
    final shadowWidth = (stageWidth * 0.58).clamp(160.0, 320.0);
    return IgnorePointer(
      child: Container(
        width: shadowWidth,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 48,
              spreadRadius: -8,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreshResultChip() {
    return _buildGlassChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: SariwaColors.brandPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            'Fresh · 75.8%',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.15,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyesDetectedChip() {
    return _buildGlassChip(
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.viewfinder,
            size: 13.5,
            color: Color(0xFF111111),
          ),
          SizedBox(width: 6),
          Text(
            '4 Eyes Detected',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.15,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassChip({required Widget child}) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final double spacing;
  final double dotRadius;
  final Color color;

  const _DotGridPainter({
    required this.spacing,
    required this.dotRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.color != color;
}
