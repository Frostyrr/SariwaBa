import 'package:material_ui/material_ui.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/blur_fade.dart';

/// Monochrome-first Features Section ("95% Monochrome + 5% Surgical Teal")
/// 2x2 grid on desktop (4-column on xl >= 1240px) of pure white rounded-3xl cards,
/// each with a lightweight neutral micro-graphic and exactly ONE surgical teal accent.
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const Color _canvasColor = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _hairline = Color(0x0D171717);
  static const Color _neutralLight = Color(0xFFE5E5E7);
  static const Color _neutralMid = Color(0xFFD4D4D8);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: _canvasColor,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 56.0 : 80.0,
        horizontal: 24.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlurFade(
                triggerOnVisible: true,
                delay: Duration.zero,
                child: Column(
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Built for fast, reliable checks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: isMobile ? 28 : 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: isMobile ? -0.7 : -0.9,
                          height: 1.15,
                          color: _inkPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: const Text(
                        'Check fish freshness in seconds and keep your scan records organized across devices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: _inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 32 : 48),

              LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  final columns = maxW >= 1120
                      ? 4
                      : maxW >= 680
                          ? 2
                          : 1;
                  const gap = 20.0;

                  final cards = [
                    _FeatureMicroCard(
                      graphic: _buildScannerMicroGraphic(),
                      title: 'Eye & Gill Scanner',
                      description:
                          'Upload a close-up or whole fish photo with automatic eye framing.',
                    ),
                    _FeatureMicroCard(
                      graphic: _buildConfidenceMicroGraphic(),
                      title: 'Clear Confidence Score',
                      description:
                          'Get an instant Fresh or Not Fresh readout backed by visual confidence.',
                    ),
                    _FeatureMicroCard(
                      graphic: _buildPlatformsMicroGraphic(),
                      title: 'Web & Mobile Ready',
                      description:
                          'Inspect directly in your browser or on Android for field checks.',
                    ),
                    _FeatureMicroCard(
                      graphic: _buildHistoryMicroGraphic(),
                      title: 'Synced History & CSV',
                      description:
                          'Archive past scans with Google and export clean CSV logs anytime.',
                    ),
                  ];

                  if (columns == 1) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          BlurFade(
                            triggerOnVisible: true,
                            delay: Duration(milliseconds: 60 * i),
                            child: cards[i],
                          ),
                          if (i < cards.length - 1) const SizedBox(height: gap),
                        ],
                      ],
                    );
                  }

                  if (columns == 2) {
                    return Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: BlurFade(
                                  triggerOnVisible: true,
                                  delay: Duration.zero,
                                  child: cards[0],
                                ),
                              ),
                              const SizedBox(width: gap),
                              Expanded(
                                child: BlurFade(
                                  triggerOnVisible: true,
                                  delay: const Duration(milliseconds: 60),
                                  child: cards[1],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: gap),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: BlurFade(
                                  triggerOnVisible: true,
                                  delay: const Duration(milliseconds: 120),
                                  child: cards[2],
                                ),
                              ),
                              const SizedBox(width: gap),
                              Expanded(
                                child: BlurFade(
                                  triggerOnVisible: true,
                                  delay: const Duration(milliseconds: 180),
                                  child: cards[3],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // 4-column xl row
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          Expanded(
                            child: BlurFade(
                              triggerOnVisible: true,
                              delay: Duration(milliseconds: 60 * i),
                              child: cards[i],
                            ),
                          ),
                          if (i < cards.length - 1) const SizedBox(width: gap),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Minimal gray camera/frame with ONLY the auto-detected corner reticle in teal.
  static Widget _buildScannerMicroGraphic() {
    return SizedBox(
      width: 112,
      height: 72,
      child: CustomPaint(
        painter: _ReticleMicroPainter(
          frameColor: _neutralLight,
          lensColor: _neutralMid,
          tealAccent: SariwaColors.brandPrimary,
        ),
      ),
    );
  }

  /// 2. Minimal gray horizontal progress bar with ONLY the 94% fill & dot in teal.
  static Widget _buildConfidenceMicroGraphic() {
    return SizedBox(
      width: 128,
      height: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 6,
                decoration: BoxDecoration(
                  color: _neutralLight,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '94%',
                    style: TextStyle(
                      fontFamily: 'Geist Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _inkPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.94,
              minHeight: 7,
              backgroundColor: _neutralLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                SariwaColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 5,
            width: 72,
            decoration: BoxDecoration(
              color: _neutralLight,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Minimal overlapping gray desktop & mobile silhouettes with ONE teal sync dot.
  static Widget _buildPlatformsMicroGraphic() {
    return SizedBox(
      width: 120,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Desktop silhouette
          Positioned(
            left: 10,
            top: 8,
            child: Container(
              width: 78,
              height: 50,
              decoration: BoxDecoration(
                color: _neutralLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _neutralMid, width: 1.2),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: _neutralMid,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < 2) const SizedBox(width: 3),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlapping mobile silhouette
          Positioned(
            right: 12,
            bottom: 6,
            child: Container(
              width: 34,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _neutralMid, width: 1.4),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: _neutralLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Spacer(),
                  // Single surgical teal sync status dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SariwaColors.brandPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 14,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: _neutralLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Three minimal gray list rows with a SINGLE surgical teal `.CSV` badge.
  static Widget _buildHistoryMicroGraphic() {
    return SizedBox(
      width: 128,
      height: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _microLogRow(barWidth: 56, showCsvBadge: true),
          const SizedBox(height: 8),
          _microLogRow(barWidth: 74, showCsvBadge: false),
          const SizedBox(height: 8),
          _microLogRow(barWidth: 62, showCsvBadge: false),
        ],
      ),
    );
  }

  static Widget _microLogRow({
    required double barWidth,
    required bool showCsvBadge,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _neutralMid,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: barWidth,
          height: 6,
          decoration: BoxDecoration(
            color: _neutralLight,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const Spacer(),
        if (showCsvBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              '.CSV',
              style: TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: SariwaColors.brandPrimary,
              ),
            ),
          )
        else
          Container(
            width: 22,
            height: 6,
            decoration: BoxDecoration(
              color: _neutralLight,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _FeatureMicroCard extends StatelessWidget {
  final Widget graphic;
  final String title;
  final String description;

  const _FeatureMicroCard({
    required this.graphic,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FeaturesSection._hairline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          graphic,
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.16,
              color: FeaturesSection._inkPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.55,
              color: FeaturesSection._inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticleMicroPainter extends CustomPainter {
  final Color frameColor;
  final Color lensColor;
  final Color tealAccent;

  const _ReticleMicroPainter({
    required this.frameColor,
    required this.lensColor,
    required this.tealAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Minimal monochrome outer viewfinder frame
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 6, size.width - 16, size.height - 12),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      frameRect,
      Paint()..color = frameColor,
    );

    // Subtle monochrome inner circle (fish eye placeholder)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      12,
      Paint()..color = lensColor,
    );

    // Surgical teal corner reticle brackets
    final bracketPaint = Paint()
      ..color = tealAccent
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const half = 20.0;
    const arm = 8.0;

    // Top-left
    canvas.drawLine(Offset(cx - half, cy - half + arm), Offset(cx - half, cy - half), bracketPaint);
    canvas.drawLine(Offset(cx - half, cy - half), Offset(cx - half + arm, cy - half), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(cx + half - arm, cy - half), Offset(cx + half, cy - half), bracketPaint);
    canvas.drawLine(Offset(cx + half, cy - half), Offset(cx + half, cy - half + arm), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(cx - half, cy + half - arm), Offset(cx - half, cy + half), bracketPaint);
    canvas.drawLine(Offset(cx - half, cy + half), Offset(cx - half + arm, cy + half), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(cx + half - arm, cy + half), Offset(cx + half, cy + half), bracketPaint);
    canvas.drawLine(Offset(cx + half, cy + half), Offset(cx + half, cy + half - arm), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _ReticleMicroPainter oldDelegate) => false;
}
