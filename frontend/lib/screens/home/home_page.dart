import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/theme/app_colors.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/navigation/web_footer.dart';
import '../../widgets/navigation/web_navbar.dart';
import 'sections/features_section.dart';
import 'sections/how_it_works_section.dart';
import 'sections/landing_section.dart';

/// Unified Home Page
/// Imports modular sections for Landing (100vh hero), Features (off-white leaning primary teal),
/// and How It Works (off-white leaning primary teal), with sticky navbar, smooth scrolling, and persistent footer.
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

  bool _isScrolled = false;
  bool _isLightNavbar = false;
  String _activeTab = 'Home';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final scrolled = offset > 16;

    String newTab = 'Home';
    bool lightNav = false;

    final featuresBox =
        _featuresKey.currentContext?.findRenderObject() as RenderBox?;
    final howItWorksBox =
        _howItWorksKey.currentContext?.findRenderObject() as RenderBox?;

    if (featuresBox != null && featuresBox.hasSize) {
      final featuresTop = featuresBox.localToGlobal(Offset.zero).dy;
      if (featuresTop <= 96) {
        newTab = 'Features';
        lightNav = true;
      }
    }

    if (howItWorksBox != null && howItWorksBox.hasSize) {
      final howTop = howItWorksBox.localToGlobal(Offset.zero).dy;
      if (howTop <= 96) {
        newTab = 'How it Works';
        lightNav = true;
      }
    }

    if (scrolled != _isScrolled ||
        lightNav != _isLightNavbar ||
        newTab != _activeTab) {
      setState(() {
        _isScrolled = scrolled;
        _isLightNavbar = lightNav;
        _activeTab = newTab;
      });
    }
  }

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
    _scrollController.removeListener(_onScroll);
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
      body: Stack(
        children: [
          // Scrollable Page Sections
          SingleChildScrollView(
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

          // Sticky Top Web Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WebNavbar(
              activeTab: _activeTab,
              isLight: _isLightNavbar,
              isScrolled: _isScrolled,
              user: authState.user,
              onHome: () => _scrollToKey(_homeKey),
              onFeatures: () => _scrollToKey(_featuresKey),
              onHowItWorks: () => _scrollToKey(_howItWorksKey),
              onDownloads: () => authController.goToDownloads(),
              onGetStarted: () => authController.goToDownloads(),
              onLogIn: () => authController.goToLogin(),
              onDashboard: () => authController.goToDashboard(),
              onSignOut: () => authController.signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

