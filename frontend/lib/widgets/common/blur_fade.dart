import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// Lightweight optical "snapping into focus" entrance animation widget.
///
/// Animates opacity (`0 -> 1`), vertical translation (`yOffset -> 0`), and
/// Gaussian blur (`blurSigma -> 0`) on a crisp deceleration curve.
///
/// Performance & Accessibility:
/// - Returns [child] directly when [MediaQuery.disableAnimationsOf] is `true`.
/// - Bypasses [ImageFiltered] and returns [child] directly once completed so
///   there is zero ongoing rasterization or layer overhead.
/// - Uses an [Interval]-based [AnimationController] (zero `Future.delayed` timers)
///   for 60/120fps smoothness and `flutter test` compatibility.
class BlurFade extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double yOffset;
  final double blurSigma;
  final bool triggerOnVisible;
  final double viewportTriggerRatio;

  const BlurFade({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.yOffset = 8.0,
    this.blurSigma = 6.0,
    this.triggerOnVisible = true,
    this.viewportTriggerRatio = 0.92,
  });

  @override
  State<BlurFade> createState() => _BlurFadeState();
}

class _BlurFadeState extends State<BlurFade>
    with SingleTickerProviderStateMixin {
  static const Curve _focusCurve = Cubic(0.22, 1.0, 0.36, 1.0);

  late final AnimationController _controller;
  late final Animation<double> _progress;

  ScrollPosition? _scrollPosition;
  bool _hasTriggered = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    final delayMs = widget.delay.inMilliseconds;
    final activeMs = widget.duration.inMilliseconds;
    final totalMs = delayMs + activeMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs > 0 ? totalMs : 1),
    )..addStatusListener(_handleStatus);

    final startFraction =
        totalMs > 0 ? (delayMs / totalMs).clamp(0.0, 0.92) : 0.0;

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(startFraction, 1.0, curve: _focusCurve),
    );

    if (!widget.triggerOnVisible) {
      _hasTriggered = true;
      _controller.forward();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isCompleted && mounted) {
      setState(() => _isCompleted = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.triggerOnVisible && !_hasTriggered) {
      final newPosition = Scrollable.maybeOf(context)?.position;
      if (_scrollPosition != newPosition) {
        _scrollPosition?.removeListener(_checkVisibility);
        _scrollPosition = newPosition;
        _scrollPosition?.addListener(_checkVisibility);
      }
    }
  }

  void _checkVisibility() {
    if (_hasTriggered || !mounted) return;

    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final topY = renderObject.localToGlobal(Offset.zero).dy;
      final viewportHeight = MediaQuery.sizeOf(context).height;

      if (topY <= viewportHeight * widget.viewportTriggerRatio) {
        _hasTriggered = true;
        _scrollPosition?.removeListener(_checkVisibility);
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.removeStatusListener(_handleStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) || _isCompleted) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isCompleted) {
          return child!;
        }

        final t = _progress.value;
        final opacity = t.clamp(0.0, 1.0);
        final dy = widget.yOffset * (1.0 - t);
        final sigma = widget.blurSigma * (1.0 - t);

        Widget current = child!;
        if (sigma > 0.05) {
          current = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
              tileMode: TileMode.decal,
            ),
            child: current,
          );
        }

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: current,
          ),
        );
      },
      child: widget.child,
    );
  }
}
