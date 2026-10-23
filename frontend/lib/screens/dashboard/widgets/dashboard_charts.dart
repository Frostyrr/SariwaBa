import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';

typedef KpiCard = NotchedKpiCard;

/// Reusable User Avatar with graceful initial fallback
class DashboardUserAvatar extends StatelessWidget {
  final dynamic user;
  final double size;

  const DashboardUserAvatar({
    super.key,
    required this.user,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final pictureUrl = user?.profilePicture as String?;
    final displayName = (user?.displayName ?? 'U').toString();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SariwaColors.brandPrimary, width: 1.5),
      ),
      child: ClipOval(
        child: pictureUrl != null && pictureUrl.isNotEmpty
            ? Image.network(
                pictureUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(initial),
              )
            : _buildFallback(initial),
      ),
    );
  }

  Widget _buildFallback(String initial) {
    return Container(
      width: size,
      height: size,
      color: SariwaColors.brandPrimary,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Geist',
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Adaptive KPI Card supporting Desktop (Notched + Sparkline Wave) and Mobile (Compact 2x2 Bento)
class NotchedKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String trendText;
  final String comparisonText;
  final Color waveColor;
  final Color trendColor;
  final List<double> points;
  final VoidCallback onTap;
  final bool showSparkline;
  final bool isCompact;

  const NotchedKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.trendText,
    required this.comparisonText,
    required this.waveColor,
    required this.trendColor,
    required this.points,
    required this.onTap,
    this.showSparkline = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCompact = isCompact || !showSparkline;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: effectiveCompact
                  ? const EdgeInsets.all(14)
                  : const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(effectiveCompact ? 16 : 20),
                border: Border.all(
                  color: SariwaColors.borderLightTeal,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x060A2229),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: effectiveCompact
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: showSparkline ? 36 : 4,
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: effectiveCompact ? 11.5 : 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.2,
                              color: SariwaColors.textMutedDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (!showSparkline)
                        Icon(
                          Icons.north_east_rounded,
                          size: 14,
                          color: waveColor.withValues(alpha: 0.75),
                        ),
                    ],
                  ),
                  SizedBox(height: effectiveCompact ? 4 : 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: effectiveCompact ? 20 : 24,
                      fontWeight: FontWeight.w600,
                      color: SariwaColors.textPrimaryDark,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: effectiveCompact ? 4 : 6),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: effectiveCompact ? 12.5 : 14,
                        color: trendColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendText,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: effectiveCompact ? 11 : 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: trendColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          comparisonText,
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: effectiveCompact ? 10.5 : 11,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.15,
                            color: SariwaColors.textMutedDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (showSparkline) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: SparklineWavePainter(
                          points: points,
                          color: waveColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Top-Right Cutout Notch & Circular Action Badge (Desktop / showSparkline mode)
            if (showSparkline)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  decoration: const BoxDecoration(
                    color: SariwaColors.bgDashboard,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                    ),
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: SariwaColors.textPrimaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.north_east_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 1. Smooth Bezier Sparkline Wave with Vertical Dotted Stems & Endpoint Dot
class SparklineWavePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  SparklineWavePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    final coords = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * (size.width - 6);
      final y = (1.0 - points[i]) * (size.height - 10) + 5;
      coords.add(Offset(x, y));
    }

    path.moveTo(coords.first.dx, coords.first.dy);
    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final stemPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 1.1;

    const stemCount = 18;
    for (int i = 0; i <= stemCount; i++) {
      final t = i / stemCount;
      final segFloat = t * (coords.length - 1);
      final segIdx = segFloat.floor().clamp(0, coords.length - 2);
      final localT = segFloat - segIdx;
      final yTop =
          coords[segIdx].dy +
          (coords[segIdx + 1].dy - coords[segIdx].dy) * localT;
      final x = t * (size.width - 6);

      for (double dy = yTop + 3; dy < size.height; dy += 4) {
        canvas.drawLine(
          Offset(x, dy),
          Offset(x, math.min(dy + 1.8, size.height)),
          stemPaint,
        );
      }
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    final endPt = coords.last;
    canvas.drawCircle(endPt, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant SparklineWavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.points != points;
}

/// 2. Block-Matrix Monthly Telemetry Chart
class BlockMatrixChartPainter extends CustomPainter {
  final int selectedMonthIndex;

  BlockMatrixChartPainter({required this.selectedMonthIndex});

  static const List<List<int>> _totalBlocks = [
    [2, 3, 5, 7],
    [4, 9, 12, 8],
    [10, 6, 8, 5],
    [5, 8, 11, 7],
    [8, 13, 16, 11],
    [9, 7, 10, 6],
    [11, 14, 12, 9],
    [6, 8, 11, 7],
    [9, 13, 10, 6],
    [5, 7, 9, 5],
    [7, 11, 8, 6],
    [8, 12, 13, 9],
  ];

  static const List<List<int>> _freshBlocks = [
    [1, 2, 4, 3],
    [2, 5, 8, 5],
    [6, 4, 5, 3],
    [3, 6, 9, 5],
    [6, 10, 12, 8],
    [6, 4, 7, 4],
    [8, 11, 9, 7],
    [4, 5, 8, 4],
    [6, 10, 7, 4],
    [3, 5, 6, 3],
    [5, 8, 6, 4],
    [6, 9, 10, 6],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 18;
    const cols = 48;
    const gap = 2.5;

    final cellW = (size.width - (cols - 1) * gap) / cols;
    final cellH = (size.height - (rows - 1) * gap) / rows;

    final emptyPaint = Paint()..color = const Color(0xFFF6FAFA);
    final totalPaint = Paint()..color = const Color(0xFFE0EDED);
    final freshPaint = Paint()..color = SariwaColors.brandPrimary;
    final freshHighlightPaint = Paint()..color = SariwaColors.statusFresh;

    for (int c = 0; c < cols; c++) {
      final monthIdx = c ~/ 4;
      final subCol = c % 4;
      final totalH = _totalBlocks[monthIdx][subCol];
      final freshH = _freshBlocks[monthIdx][subCol];
      final isSelectedMonth = monthIdx == selectedMonthIndex;

      for (int r = 0; r < rows; r++) {
        final rowFromBottom = rows - 1 - r;
        final left = c * (cellW + gap);
        final top = r * (cellH + gap);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cellW, cellH),
          const Radius.circular(2.2),
        );

        if (rowFromBottom < freshH) {
          canvas.drawRRect(
            rect,
            isSelectedMonth ? freshHighlightPaint : freshPaint,
          );
        } else if (rowFromBottom < totalH) {
          canvas.drawRRect(rect, totalPaint);
        } else {
          canvas.drawRRect(rect, emptyPaint);
        }
      }
    }

    final cursorCol = selectedMonthIndex * 4 + 1.5;
    final cursorX = cursorCol * (cellW + gap);
    final dashPaint = Paint()
      ..color = SariwaColors.textPrimaryDark.withValues(alpha: 0.45)
      ..strokeWidth = 1.2;

    for (double y = 0; y < size.height; y += 5) {
      canvas.drawLine(Offset(cursorX, y), Offset(cursorX, y + 2.5), dashPaint);
    }

    const markerY = 64.0;
    canvas.drawCircle(
      Offset(cursorX, markerY),
      6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cursorX, markerY),
      6,
      Paint()
        ..color = SariwaColors.brandPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(cursorX, markerY),
      3,
      Paint()..color = SariwaColors.textPrimaryDark,
    );
  }

  @override
  bool shouldRepaint(covariant BlockMatrixChartPainter oldDelegate) =>
      oldDelegate.selectedMonthIndex != selectedMonthIndex;
}

/// 3. Multi-Radius Polar Sector Chart
class PolarSectorChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2 - 4;

    canvas.drawCircle(
      center,
      maxR,
      Paint()
        ..color = SariwaColors.bgDashboardSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    final sectors = [
      (
        start: 2.3,
        sweep: 1.9,
        radiusFactor: 0.92,
        color: SariwaColors.brandPrimary,
      ),
      (
        start: 4.2,
        sweep: 1.3,
        radiusFactor: 0.80,
        color: SariwaColors.statusFresh,
      ),
      (
        start: 5.5,
        sweep: 1.1,
        radiusFactor: 0.68,
        color: SariwaColors.statusInfo,
      ),
      (
        start: 0.32,
        sweep: 1.0,
        radiusFactor: 0.58,
        color: SariwaColors.statusModerate,
      ),
      (
        start: 1.32,
        sweep: 0.98,
        radiusFactor: 0.48,
        color: SariwaColors.statusSpoiled,
      ),
    ];

    for (final s in sectors) {
      final r = maxR * s.radiusFactor;
      final rect = Rect.fromCircle(center: center, radius: r);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [s.color.withValues(alpha: 0.55), s.color],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, s.start, s.sweep - 0.04, true, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. Gradient Triangular Peak Chart
class PeakAreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = SariwaColors.borderLightTeal.withValues(alpha: 0.55)
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 3; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final peaks = [
      (xCenter: 0.10, width: 0.14, height: 0.16),
      (xCenter: 0.27, width: 0.15, height: 0.28),
      (xCenter: 0.48, width: 0.16, height: 0.58),
      (xCenter: 0.69, width: 0.16, height: 0.76),
      (xCenter: 0.88, width: 0.16, height: 0.96),
    ];

    for (final p in peaks) {
      final cx = p.xCenter * size.width;
      final halfW = (p.width * size.width) / 2;
      final topY = size.height * (1.0 - p.height);

      final path = Path()
        ..moveTo(cx - halfW, size.height)
        ..lineTo(cx, topY)
        ..lineTo(cx + halfW, size.height)
        ..close();

      final rect = Rect.fromLTRB(cx - halfW, topY, cx + halfW, size.height);
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SariwaColors.brandPrimary.withValues(alpha: 0.48),
            SariwaColors.brandLight.withValues(alpha: 0.05),
          ],
        ).createShader(rect);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
