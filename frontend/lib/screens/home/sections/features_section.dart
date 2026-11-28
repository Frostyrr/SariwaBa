import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/staggered_reveal.dart';

class _FeatureTab {
  final IconData icon;
  final String title;
  final String summary;

  const _FeatureTab({
    required this.icon,
    required this.title,
    required this.summary,
  });
}

/// Interactive Single-Stage Features Section
/// - Desktop (`>= 840px`): 4 hairline-separated clickable feature rows on the left
///   driving one calm, focused visual stage on the right (zero cluttered Bento boxes).
/// - Mobile (`< 840px`): Clean pill selector above the single stage.
class FeaturesSection extends StatefulWidget {
  const FeaturesSection({super.key});

  @override
  State<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  int _selectedIndex = 0;

  static const List<_FeatureTab> _tabs = [
    _FeatureTab(
      icon: CupertinoIcons.viewfinder,
      title: 'Eye & Gill Scanner',
      summary:
          'Upload or snap a close-up of a Tilapia eye, exposed gill, or whole fish. Auto eye detection frames the region for you.',
    ),
    _FeatureTab(
      icon: CupertinoIcons.checkmark_seal,
      title: 'Clear Confidence Score',
      summary:
          'Get a straightforward Fresh or Not Fresh verdict paired with visual model confidence and zero confusing jargon.',
    ),
    _FeatureTab(
      icon: CupertinoIcons.device_phone_portrait,
      title: 'Web & Mobile Ready',
      summary:
          'Run quick inspections right in your browser or use the Android app for market and field checks.',
    ),
    _FeatureTab(
      icon: CupertinoIcons.clock,
      title: 'Synced History & CSV',
      summary:
          'Sign in with Google to archive scans across devices, filter by eye or gill, and export CSV records anytime.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 840;
    final isMobile = width < 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        border: Border(
          bottom: BorderSide(color: SariwaColors.colorLineSubtle),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24.0,
        isMobile ? 48.0 : 64.0,
        24.0,
        isMobile ? 64.0 : 80.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                header: true,
                child: StaggeredReveal(
                  revealOnScroll: true,
                  staggerIndex: 0,
                  child: Text(
                    'Built for fast, reliable checks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.7,
                      height: 1.15,
                      color: SariwaColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: const Text(
                    'Check fish freshness in seconds and keep your scan records organized across devices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                      letterSpacing: -0.15,
                      color: SariwaColors.inkSlateSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 32 : 48),
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 2,
                child: isDesktop
                    ? _buildDesktopSplitStage()
                    : _buildMobileTabbedStage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSplitStage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: 4 hairline-separated interactive feature rows
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                _FeatureTabRow(
                  tab: _tabs[i],
                  isActive: i == _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = i),
                ),
                if (i < _tabs.length - 1)
                  const Divider(height: 1, color: SariwaColors.colorLineSubtle),
              ],
            ],
          ),
        ),
        const SizedBox(width: 48),
        // Right: Single focused visual stage
        Expanded(
          flex: 7,
          child: _buildVisualStage(height: 360),
        ),
      ],
    );
  }

  Widget _buildMobileTabbedStage() {
    final activeTab = _tabs[_selectedIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Semantics(
                button: true,
                selected: i == _selectedIndex,
                label: _tabs[i].title,
                child: Material(
                  color: i == _selectedIndex
                      ? SariwaColors.brandPrimary
                      : SariwaColors.colorSurface,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: i == _selectedIndex
                          ? SariwaColors.brandPrimary
                          : SariwaColors.colorLine,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = i),
                    customBorder: const StadiumBorder(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        _tabs[i].title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: i == _selectedIndex
                              ? SariwaColors.cardSurfaceLight
                              : SariwaColors.inkSlateSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          activeTab.summary,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.5,
            color: SariwaColors.inkSlateSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildVisualStage(height: 280),
      ],
    );
  }

  Widget _buildVisualStage({required double height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SariwaColors.colorWorkspace,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: switch (_selectedIndex) {
            0 => _buildScannerStage(),
            1 => _buildConfidenceStage(),
            2 => _buildPlatformsStage(),
            _ => _buildHistoryStage(),
          },
        ),
      ),
    );
  }

  /// Stage 0: Region modes + cropped eye focus frame
  Widget _buildScannerStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Inspection Region',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SariwaColors.cardSurfaceLight,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SariwaColors.colorLine),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stagePill('Auto', isActive: true),
                  _stagePill('Eye', isActive: false),
                  _stagePill('Gill', isActive: false),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/sample_tilapia2.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: SariwaColors.bgAbyssDark,
                  ),
                ),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SariwaColors.brandGlow,
                        width: 2,
                      ),
                      color: SariwaColors.brandGlow.withValues(alpha: 0.16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Stage 1: Clear Fresh vs Not Fresh confidence breakdown
  Widget _buildConfidenceStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _confidenceRow(
          label: 'Fresh',
          score: '94.7%',
          progress: 0.947,
          barColor: SariwaColors.statusFresh,
          textColor: SariwaColors.freshText,
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, color: SariwaColors.colorLine),
        const SizedBox(height: 24),
        _confidenceRow(
          label: 'Not Fresh',
          score: '5.3%',
          progress: 0.053,
          barColor: SariwaColors.statusSpoiled,
          textColor: SariwaColors.notFreshText,
        ),
        const SizedBox(height: 24),
        const Text(
          'Visual freshness estimate — always pair with smell and texture checks.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: SariwaColors.inkSlateMuted,
          ),
        ),
      ],
    );
  }

  Widget _confidenceRow({
    required String label,
    required String score,
    required double progress,
    required Color barColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            Text(
              score,
              style: const TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: SariwaColors.cardSurfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  /// Stage 2: Clean platform availability rows
  Widget _buildPlatformsStage() {
    const rows = [
      (
        icon: CupertinoIcons.globe,
        title: 'Web Browser',
        subtitle: 'Upload desktop or phone photos with zero install.',
        tag: 'Instant',
      ),
      (
        icon: CupertinoIcons.device_phone_portrait,
        title: 'Android Mobile App',
        subtitle: 'Snap close-ups directly at the market or dock.',
        tag: 'APK',
      ),
      (
        icon: CupertinoIcons.person_crop_circle,
        title: 'Guest or Google Sync',
        subtitle: 'Inspect locally as a guest or sync across devices.',
        tag: 'Flexible',
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SariwaColors.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SariwaColors.colorLine),
                ),
                child: Icon(
                  rows[i].icon,
                  size: 18,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rows[i].title,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rows[i].subtitle,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                rows[i].tag,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ],
          ),
          if (i < rows.length - 1) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: SariwaColors.colorLine),
            const SizedBox(height: 16),
          ],
        ],
      ],
    );
  }

  /// Stage 3: Clean synced scan history & CSV export preview
  Widget _buildHistoryStage() {
    const entries = [
      (name: 'Eye Scan', time: 'Today, 9:14 AM', status: 'Fresh · 94%', fresh: true),
      (name: 'Gill Scan', time: 'Today, 8:50 AM', status: 'Fresh · 91%', fresh: true),
      (name: 'Eye Scan', time: 'Yesterday', status: 'Not Fresh · 88%', fresh: false),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Scans',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: SariwaColors.cardSurfaceLight,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SariwaColors.colorLine),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.arrow_down_doc,
                    size: 12,
                    color: SariwaColors.brandPrimary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Export CSV',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < entries.length; i++) ...[
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entries[i].fresh
                      ? SariwaColors.statusFresh
                      : SariwaColors.statusSpoiled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entries[i].name,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    Text(
                      entries[i].time,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                entries[i].status,
                style: TextStyle(
                  fontFamily: 'Geist Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: entries[i].fresh
                      ? SariwaColors.freshText
                      : SariwaColors.notFreshText,
                ),
              ),
            ],
          ),
          if (i < entries.length - 1) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: SariwaColors.colorLine),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  Widget _stagePill(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? SariwaColors.colorPale : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive
              ? SariwaColors.brandPrimary
              : SariwaColors.inkSlateMuted,
        ),
      ),
    );
  }
}

class _FeatureTabRow extends StatelessWidget {
  final _FeatureTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _FeatureTabRow({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: tab.title,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isActive
                    ? SariwaColors.brandPrimary
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    tab.icon,
                    size: 18,
                    color: isActive
                        ? SariwaColors.brandPrimary
                        : SariwaColors.inkSlateMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tab.title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                        color: isActive
                            ? SariwaColors.textPrimaryDark
                            : SariwaColors.inkSlateSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8, left: 30),
                  child: Text(
                    tab.summary,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                      color: SariwaColors.inkSlateSecondary,
                    ),
                  ),
                ),
                crossFadeState: isActive
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
