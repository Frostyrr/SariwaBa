import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: SvgPicture.asset(
          'assets/icons/google.svg',
          width: 18,
          height: 18,
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
