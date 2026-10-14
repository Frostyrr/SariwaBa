import 'package:flutter/material.dart';
import '../../../home/presentation/pages/home_page.dart';

/// Landing Page wrapper delegating directly to unified HomePage
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
