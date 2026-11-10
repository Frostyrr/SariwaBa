import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Atmospheric banner with blurred underwater background and high-contrast deep gradient overlay.
class DashboardAtmosphericBanner extends StatelessWidget {
  final Widget content;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const DashboardAtmosphericBanner({
    super.key,
    required this.content,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E0A2229),
            blurRadius: 32,
            offset: Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x1414B8A6),
            blurRadius: 36,
            offset: Offset(0, 16),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Layer 1: Blurred Underwater Aquatic Backdrop
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Layer 2: Deep Abyss Gradient Overlay (ensures high contrast & text legibility)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.88),
                      const Color(0xFF0D2F38).withValues(alpha: 0.82),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.92),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0x28CCEAE6),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),

            // Layer 3: Ambient Radial Glow Flare in top-right corner
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x3514B8A6),
                      Color(0x0E2DD4BF),
                      Color(0x002DD4BF),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Layer 4: Foreground Content
            Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
