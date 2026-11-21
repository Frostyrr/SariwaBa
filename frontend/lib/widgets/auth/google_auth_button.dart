import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/app_button.dart';
import 'google_web_button_stub.dart'
    if (dart.library.js_interop) 'google_web_button.dart';

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
    if (kIsWeb) {
      return Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            ignoring: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.4 : 1,
              child: buildGoogleWebButton(),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      );
    }
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
