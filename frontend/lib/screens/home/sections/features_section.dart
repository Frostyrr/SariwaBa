import 'package:cupertino_ui/cupertino_ui.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/staggered_reveal.dart';

/// Features Section Widget
/// Crisp bordered surface cards on tinted marine workspace with zero stacked shadows.
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        border: Border.symmetric(
          horizontal: BorderSide(color: SariwaColors.colorLineSubtle),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 64.0 : 80.0,
        horizontal: 24.0,
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
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const Text(
                    'Check fish freshness in seconds and keep your scan records organized across devices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: -0.15,
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                      color: SariwaColors.inkSlateSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 4 Feature Cards: 2x2 Grid on Desktop, Horizontal Snapped Carousel on Mobile
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 768;

                  const items = [
                    (
                      icon: CupertinoIcons.eye,
                      title: 'Eye & Gill Scanner',
                      desc:
                          'Upload or snap a close-up photo of a Tilapia eye, exposed gill, or whole fish for an instant freshness reading.',
                    ),
                    (
                      icon: CupertinoIcons.checkmark_seal,
                      title: 'Clear Confidence Score',
                      desc:
                          'See a straightforward Fresh or Not Fresh result paired with visual confidence.',
                    ),
                    (
                      icon: CupertinoIcons.device_phone_portrait,
                      title: 'Web & Mobile Ready',
                      desc:
                          'Inspect directly in your browser or use the Android app for quick market and field checks.',
                    ),
                    (
                      icon: CupertinoIcons.clock,
                      title: 'Synced History & CSV',
                      desc:
                          'Review past scans, filter by eye or gill, and export CSV records when signed in with Google.',
                    ),
                  ];

                  if (!isDesktop) {
                    return _MobileFeatureCarousel(items: items);
                  }

                  final cardWidth = (constraints.maxWidth - 24) / 2;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        SizedBox(
                          width: cardWidth,
                          child: StaggeredReveal(
                            revealOnScroll: true,
                            staggerIndex: i + 1,
                            child: _FeatureCard(
                              icon: items[i].icon,
                              title: items[i].title,
                              desc: items[i].desc,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileFeatureCarousel extends StatefulWidget {
  final List<({IconData icon, String title, String desc})> items;

  const _MobileFeatureCarousel({required this.items});

  @override
  State<_MobileFeatureCarousel> createState() => _MobileFeatureCarouselState();
}

class _MobileFeatureCarouselState extends State<_MobileFeatureCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.86);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 224,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _FeatureCard(
                  icon: item.icon,
                  title: item.title,
                  desc: item.desc,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? SariwaColors.brandPrimary
                    : SariwaColors.colorLine,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SariwaColors.cardSurfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? SariwaColors.brandPrimary.withValues(alpha: 0.45)
                : SariwaColors.colorLine,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SariwaColors.colorPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: SariwaColors.brandPrimary,
                size: 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.desc,
              style: const TextStyle(
                letterSpacing: -0.1,
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                height: 1.5,
                color: SariwaColors.inkSlateSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
