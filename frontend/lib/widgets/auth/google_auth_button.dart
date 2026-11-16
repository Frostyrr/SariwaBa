import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/app_button.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;

  const GoogleAuthButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Sign in with Google',
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: label,
      icon: SvgPicture.asset('assets/icons/google.svg', width: 18, height: 18),
      isLoading: isLoading,
      width: double.infinity,
      height: 52,
      borderRadius: 999,
      onPressed: onPressed,
    );
  }
}
