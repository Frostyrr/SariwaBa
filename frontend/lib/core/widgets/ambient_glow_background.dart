import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Minimalist Dark Ambient Background
/// Inspired by Resend: Deep true black (#0A0A0A) with subtle diagonal
/// lighting sheen and delicate ambient highlight.
class AmbientGlowBackground extends StatelessWidget {
  final Widget child;
  final bool showTopRightGlow;
  final bool showBottomGlow;

  const AmbientGlowBackground({
    super.key,
    required this.child,
    this.showTopRightGlow = true,
    this.showBottomGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          // Subtle diagonal lighting sheen (Resend style)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F0F0F),
                    Color(0xFF0A0A0A),
                    Color(0xFF070707),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Subtle ambient glow
          if (showTopRightGlow)
            Positioned(
              top: -180,
              right: -120,
              child: IgnorePointer(
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
            ),

          // Main child content
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}
