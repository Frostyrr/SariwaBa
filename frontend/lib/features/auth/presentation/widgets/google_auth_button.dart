import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;

  const GoogleAuthButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Sign in With Google',
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: label,
      icon: Container(
        width: 22,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.network(
          'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.g_mobiledata_rounded,
            color: SariwaColors.bgAbyssDark,
            size: 18,
          ),
        ),
      ),
      isLoading: isLoading,
      width: double.infinity,
      height: 52,
      borderRadius: 999, // Stadium/pill geometry matching wireframe
      onPressed: onPressed,
    );
  }
}
