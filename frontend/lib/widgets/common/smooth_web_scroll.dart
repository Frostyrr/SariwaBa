import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

/// Intercepts mouse-wheel [PointerScrollEvent]s on Web/Desktop and drives
/// [controller] with frame-rate-independent 60/120fps exponential damping
/// (similar to Lenis / native browser smooth scroll).
///
/// Touch dragging, trackpad inertia, scrollbar dragging, and programmatic
/// `animateTo` / `Scrollable.ensureVisible` remain 100% native.
class SmoothWebScrollChild extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final double wheelMultiplier;
  final double damping;

  const SmoothWebScrollChild({
    super.key,
    required this.controller,
    required this.child,
    this.wheelMultiplier = 1.15,
    this.damping = 11.0,
  });

  @override
  State<SmoothWebScrollChild> createState() => _SmoothWebScrollChildState();
}

class _SmoothWebScrollChildState extends State<SmoothWebScrollChild>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _targetOffset = 0.0;
  Duration _lastElapsed = Duration.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !widget.controller.hasClients) {
      _stopTicker();
      return;
    }

    final dt = _lastElapsed == Duration.zero
        ? 1.0 / 60.0
        : ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(0.001, 0.05);
    _lastElapsed = elapsed;

    final position = widget.controller.position;
    final current = position.pixels;
    final clampedTarget = _targetOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _targetOffset = clampedTarget;

    final diff = clampedTarget - current;
    if (diff.abs() < 0.4) {
      if (diff != 0.0) {
        widget.controller.jumpTo(clampedTarget);
      }
      _stopTicker();
      return;
    }

    final factor = 1.0 - math.exp(-widget.damping * dt);
    final next = current + diff * factor;
    widget.controller.jumpTo(next);
  }

  void _stopTicker() {
    _isAnimating = false;
    _lastElapsed = Duration.zero;
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!kIsWeb) return;
    if (event is! PointerScrollEvent) return;
    if (event.kind != PointerDeviceKind.mouse) return;
    if (event.scrollDelta.dy == 0.0) return;

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations || !widget.controller.hasClients) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      if (!mounted || !widget.controller.hasClients) return;
      final scrollEvent = e as PointerScrollEvent;
      final position = widget.controller.position;

      if (!_isAnimating) {
        _targetOffset = position.pixels;
      }

      _targetOffset = (_targetOffset +
              scrollEvent.scrollDelta.dy * widget.wheelMultiplier)
          .clamp(position.minScrollExtent, position.maxScrollExtent);

      if (!_isAnimating) {
        _isAnimating = true;
        _lastElapsed = Duration.zero;
        _ticker.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      onPointerDown: (_) {
        if (_isAnimating) _stopTicker();
      },
      child: widget.child,
    );
  }
}
