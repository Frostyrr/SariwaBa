import 'dart:ui' as ui;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import 'organoleptic_guidelines_dialog.dart';

/// Compact iOS-style floating glass pill mobile top bar.
/// Shows brand mark + current page title on the left and the isolated `?` help button on the right.
/// No hamburger menu icon — mobile relies solely on the bottom floating glass pill.
class DashboardMobileTopBar extends StatelessWidget {
  final dynamic user;
  final bool isGuestUser;
  final String activeNav;
  final ValueChanged<String> onNavSelected;
  final VoidCallback onGoHome;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;
  final VoidCallback onSyncHistory;
  final VoidCallback? onOpenDrawer;
  final bool showTopTabs;

  const DashboardMobileTopBar({
    super.key,
    required this.user,
    required this.isGuestUser,
    required this.activeNav,
    required this.onNavSelected,
    required this.onGoHome,
    required this.onSignOut,
    required this.onSignIn,
    required this.onSyncHistory,
    this.onOpenDrawer,
    this.showTopTabs = false,
  });

  String get _screenTitle {
    switch (activeNav) {
      case 'History':
      case 'Analytics':
      case 'Summary':
        return 'History';
      case 'Settings':
      case 'Account':
        return 'Settings';
      case 'Admin':
        return 'Admin';
      case 'HowItWorks':
      case 'How It Works':
        return 'Guide';
      case 'Help':
      case 'FAQs':
      case 'Help & FAQs':
        return 'Help & FAQs';
      default:
        return 'Inspect';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pillInner = Container(
      height: 46,
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight.withValues(
          alpha: kIsWeb ? 0.92 : 0.84,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: SariwaColors.colorLine,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/SariwaBa logo.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            semanticLabel: 'SariwaBa logo',
            errorBuilder: (_, _, _) => const Icon(
              CupertinoIcons.sparkles,
              color: SariwaColors.brandPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _screenTitle,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: AppTypography.defaultLetterSpacing,
                color: SariwaColors.textPrimaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
            message: 'Quality Inspection Guide',
            child: Material(
              color: SariwaColors.colorSurface.withValues(alpha: 0.85),
              shape: const CircleBorder(
                side: BorderSide(color: SariwaColors.colorLine, width: 0.8),
              ),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  OrganolepticGuidelinesDialog.show(context);
                },
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(
                    CupertinoIcons.question_circle,
                    size: 18,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final glassPill = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: SariwaColors.shadowHairline,
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: pillInner,
        ),
      ),
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
        child: glassPill,
      ),
    );
  }
}
