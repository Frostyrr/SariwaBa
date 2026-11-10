import 'package:flutter/material.dart';

/// Simulated Mouse Cursor for Programmatic Product Demonstrations
/// Renders an authentic, vector-drawn macOS/Figma style cursor pointer
/// with a drop shadow, clicking depression, and animated click pulse.
class SimulatedCursor extends StatelessWidget {
  final bool isClicking;
  final double clickProgress; // 0.0 to 1.0 during click
  final bool isTouchMode; // For touch viewports (renders subtle touch ring)

  const SimulatedCursor({
    super.key,
    this.isClicking = false,
    this.clickProgress = 0.0,
    this.isTouchMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isTouchMode) {
      return _buildTouchIndicator();
    }

    final scale = isClicking ? 0.90 : 1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Click Ripple Wave
        if (clickProgress > 0.0 && clickProgress < 1.0)
          Positioned(
            left: -12,
            top: -12,
            child: Opacity(
              opacity: (1.0 - clickProgress).clamp(0.0, 1.0),
              child: Container(
                width: 36 * clickProgress + 12,
                height: 36 * clickProgress + 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.8),
                    width: 2.0 * (1.0 - clickProgress) + 0.5,
                  ),
                ),
              ),
            ),
          ),

        // Vector Mouse Cursor Pointer
        Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: CustomPaint(
            size: const Size(22, 28),
            painter: _CursorPointerPainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildTouchIndicator() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: isClicking ? 0.6 : 0.35),
        border: Border.all(
          color: const Color(0xFF14B8A6),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3314B8A6),
            blurRadius: 10,
            spreadRadius: isClicking ? 2 : 0,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for a crisp, high-DPI modern cursor arrow
class _CursorPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 20)
      ..lineTo(5.2, 16.2)
      ..lineTo(9.6, 24.5)
      ..lineTo(13.2, 22.6)
      ..lineTo(8.8, 14.5)
      ..lineTo(15.2, 14.5)
      ..close();

    // Draw shadow slightly offset
    canvas.save();
    canvas.translate(1.5, 2.5);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Outer dark stroke for contrast on bright surfaces
    final borderPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    // Crisp pure white fill
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
