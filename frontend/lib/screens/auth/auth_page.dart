import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'mobile_welcome_page.dart';
import 'web_sign_in_page.dart';

/// Platform-separated Auth entry:
/// - Web (`kIsWeb`): Minimal daylight [WebSignInPage] matching the website.
/// - Mobile (`!kIsWeb`): Unforced single-screen [MobileWelcomePage] with anchored sheet.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebSignInPage();
    }
    return const MobileWelcomePage();
  }
}
