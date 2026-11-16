import 'package:flutter/material.dart';

/// Painter for the AI Inspection Reticle & Holographic Scanning Beam
class ScanningReticlePainter extends CustomPainter {
  final double scanProgress; // 0.0 to 1.0 (scans top to bottom and back)
  final bool isScanning;
  final Color primaryColor;

  ScanningReticlePainter({
    required this.scanProgress,
    this.isScanning = false,
    this.primaryColor = const Color(0xFF14B8A6),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Corner guides
    final cornerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;

    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLength), cornerPaint);

    // Top-right
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -cornerLength), cornerPaint);

    // Bottom-right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -cornerLength), cornerPaint);

    // Subtle 3x3 Rule of Thirds Guide Grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final thirdW = size.width / 3;
    final thirdH = size.height / 3;

    canvas.drawLine(Offset(thirdW, 0), Offset(thirdW, size.height), gridPaint);
    canvas.drawLine(Offset(thirdW * 2, 0), Offset(thirdW * 2, size.height), gridPaint);
    canvas.drawLine(Offset(0, thirdH), Offset(size.width, thirdH), gridPaint);
    canvas.drawLine(Offset(0, thirdH * 2), Offset(size.width, thirdH * 2), gridPaint);

    // Scanning Beam Animation
    if (isScanning && scanProgress >= 0.0 && scanProgress <= 1.0) {
      final y = size.height * scanProgress;

      // Soft vertical gradient glow trail behind beam
      final glowHeight = 36.0;
      final trailRect = Rect.fromLTRB(0, (y - glowHeight).clamp(0.0, size.height), size.width, y);
      final trailPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            primaryColor.withValues(alpha: 0.28),
          ],
        ).createShader(trailRect);

      canvas.drawRect(trailRect, trailPaint);

      // Solid central laser scan line
      final beamPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.5);

      final outerGlowPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), outerGlowPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), beamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScanningReticlePainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.isScanning != isScanning ||
        oldDelegate.primaryColor != primaryColor;
  }
}
