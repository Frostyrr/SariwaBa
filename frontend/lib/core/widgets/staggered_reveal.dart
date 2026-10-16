import 'package:flutter/material.dart';

/// A smooth staggered entrance & scroll-reveal animation wrapper.
///
/// Uses an [Interval]-based [AnimationController] (zero `Future.delayed` timers)
/// so animations are 60/120fps smooth and fully compatible with `flutter test`.
///
/// - When [revealOnScroll] is `false` (default for above-the-fold content),
///   the animation begins immediately on mount with [staggerIndex] * [staggerStep].
/// - When [revealOnScroll] is `true`, the widget listens to the enclosing
///   [Scrollable] and triggers its staggered entrance as soon as it enters
///   the viewport.
class StaggeredReveal extends StatefulWidget {
  final Widget child;
  final int staggerIndex;
  final Duration staggerStep;
  final Duration duration;
  final Offset slideOffset;
  final Curve curve;
  final bool revealOnScroll;
  final double viewportTriggerRatio;

  const StaggeredReveal({
    super.key,
    required this.child,
    this.staggerIndex = 0,
    this.staggerStep = const Duration(milliseconds: 90),
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = const Offset(0, 24),
    this.curve = Curves.easeOutCubic,
    this.revealOnScroll = false,
    this.viewportTriggerRatio = 0.92,
  });

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  ScrollPosition? _scrollPosition;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();

    final delayMs = widget.staggerIndex * widget.staggerStep.inMilliseconds;
    final activeMs = widget.duration.inMilliseconds;
    final totalMs = delayMs + activeMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    final startFraction = totalMs > 0
        ? (delayMs / totalMs).clamp(0.0, 0.9)
        : 0.0;

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(startFraction, 1.0, curve: widget.curve),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slide = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(curved);

    if (!widget.revealOnScroll) {
      _hasTriggered = true;
      _controller.forward();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.revealOnScroll) {
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
      final position = renderObject.localToGlobal(Offset.zero);
      final viewportHeight = MediaQuery.sizeOf(context).height;

      if (position.dy <= viewportHeight * widget.viewportTriggerRatio) {
        _hasTriggered = true;
        _scrollPosition?.removeListener(_checkVisibility);
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(offset: _slide.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
