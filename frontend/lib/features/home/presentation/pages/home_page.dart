import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../landing/presentation/widgets/web_footer.dart';
import '../sections/features_section.dart';
import '../sections/how_it_works_section.dart';
import '../sections/landing_section.dart';

/// Unified Home Page
/// Imports modular sections for Landing (100vh hero), Features (off-white leaning primary teal),
/// and How It Works (off-white leaning primary teal), with smooth scrolling and persistent footer.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final isGuest = authState.isGuest;

    return Scaffold(
      backgroundColor: SariwaColors.bgAbyssDark,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Section 1: 100vh Landing Hero (Underwater illustration background)
            LandingSection(
              key: _homeKey,
              isGuest: isGuest,
              user: authState.user,
              onConnectGoogle: () => authController.continueWithGoogle(),
              onHome: () => _scrollToKey(_homeKey),
              onFeatures: () => _scrollToKey(_featuresKey),
              onHowItWorks: () => _scrollToKey(_howItWorksKey),
              onDownloads: () => authController.goToDownloads(),
              onLogIn: () => authController.goToLogin(),
              onDashboard: () => authController.goToDashboard(),
              onSignOut: () => authController.signOut(),
            ),

            // Section 2: Features Section (Off-white leaning primary teal #F0F7F6)
            FeaturesSection(
              key: _featuresKey,
            ),

            // Section 3: How It Works Section (Off-white leaning primary teal #F0F7F6)
            HowItWorksSection(
              key: _howItWorksKey,
              onDownload: () => authController.goToDownloads(),
            ),

            // Section 4: Web Footer (Deep Abyss #0A2229)
            WebFooter(
              onHome: () => _scrollToKey(_homeKey),
              onFeatures: () => _scrollToKey(_featuresKey),
              onHowItWorks: () => _scrollToKey(_howItWorksKey),
              onDownloads: () => authController.goToDownloads(),
            ),
          ],
        ),
      ),
    );
  }
}
