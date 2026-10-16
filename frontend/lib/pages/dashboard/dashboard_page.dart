import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/navigation/web_navbar.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String _historyFilter = 'All'; // 'All', 'Fresh', 'Non-Fresh'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load fresh history when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classificationControllerProvider.notifier).loadHistory();
    });
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final scrolled = _scrollController.offset > 12;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
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
    final classState = ref.watch(classificationControllerProvider);
    final classController = ref.read(classificationControllerProvider.notifier);
    final user = authState.user;

    return Scaffold(
      backgroundColor: SariwaColors.bgDashboard,
      body: Column(
        children: [
          // Sticky Web Navbar configured for Off-White Light Mode
          WebNavbar(
            user: user,
            isLight: true,
            isScrolled: _isScrolled,
            activeTab: 'Dashboard',
            onHome: () => authController.goToLanding(),
            onDashboard: () => authController.goToDashboard(),
            onGetStarted: () => authController.goToDownloads(),
            onDownloads: () => authController.goToDownloads(),
            onLogIn: () => authController.goToLogin(),
            onSignOut: () => authController.signOut(),
          ),

          // Main Scrollable Dashboard Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Greetings & Actions
                      StaggeredReveal(
                        staggerIndex: 0,
                        child: _buildDashboardHeader(user, classController),
                      ),
                      const SizedBox(height: 24),

                      // KPI Metric Summary Cards (staggered 1..4)
                      _buildKpiMetrics(classState.history),
                      const SizedBox(height: 28),

                      // Status Notifications (Errors / Success)
                      if (classState.errorMessage != null)
                        _buildNotificationBanner(
                          message: classState.errorMessage!,
                          isError: true,
                        ),
                      if (classState.successMessage != null)
                        _buildNotificationBanner(
                          message: classState.successMessage!,
                          isError: false,
                        ),
                      if (classState.errorMessage != null ||
                          classState.successMessage != null)
                        const SizedBox(height: 20),

                      // Responsive Workstation Layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 960;

                          if (isDesktop) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left 55%: Interactive Scanner Station
                                Expanded(
                                  flex: 11,
                                  child: StaggeredReveal(
                                    staggerIndex: 5,
                                    child: _buildScannerCard(
                                      classState,
                                      classController,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Right 45%: Classification History
                                Expanded(
                                  flex: 9,
                                  child: StaggeredReveal(
                                    staggerIndex: 6,
                                    child: _buildHistoryCard(
                                      classState,
                                      classController,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Mobile / Tablet stacked column
                            return Column(
                              children: [
                                StaggeredReveal(
                                  staggerIndex: 5,
                                  child: _buildScannerCard(
                                    classState,
                                    classController,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                StaggeredReveal(
                                  revealOnScroll: true,
                                  staggerIndex: 1,
                                  child: _buildHistoryCard(
                                    classState,
                                    classController,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 48),

                      // Light Footer
                      StaggeredReveal(
                        revealOnScroll: true,
                        staggerIndex: 1,
                        child: _buildSimpleFooter(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header Section
  Widget _buildDashboardHeader(
    dynamic user,
    ClassificationController controller,
  ) {
    final name = (user?.displayName ?? 'Evaluator').toString().split(' ').first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.25,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: SariwaColors.brandPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PostgreSQL Live Session',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: SariwaColors.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back, $name!',
                style: AppTypography.displayLarge.copyWith(
                  color: SariwaColors.textPrimaryDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inspect seafood freshness in real-time and review historical quality audits.',
                style: AppTypography.bodyMedium.copyWith(
                  color: SariwaColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => controller.loadHistory(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Sync History'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SariwaColors.brandPrimary,
            side: const BorderSide(
              color: SariwaColors.borderLightTeal,
              width: 1.2,
            ),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // 4 KPI Summary Cards
  Widget _buildKpiMetrics(List<ClassificationResult> history) {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final cautionCount = total - freshCount;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 95.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        final cards = [
          _buildMetricBox(
            title: 'Total Scans',
            value: total.toString(),
            subtitle: 'Lifetime audit records',
            icon: Icons.analytics_outlined,
            iconColor: SariwaColors.brandPrimary,
            iconBg: SariwaColors.brandPrimary.withValues(alpha: 0.12),
          ),
          _buildMetricBox(
            title: 'Sariwa (Fresh)',
            value: freshCount.toString(),
            subtitle: total > 0
                ? '${((freshCount / total) * 100).toStringAsFixed(0)}% of total scans'
                : 'Grade A benchmark',
            icon: Icons.check_circle_outline_rounded,
            iconColor: SariwaColors.statusFresh,
            iconBg: SariwaColors.statusFresh.withValues(alpha: 0.12),
          ),
          _buildMetricBox(
            title: 'Substandard / Caution',
            value: cautionCount.toString(),
            subtitle: 'Grade B & Spoiled alerts',
            icon: Icons.warning_amber_rounded,
            iconColor: SariwaColors.statusModerate,
            iconBg: SariwaColors.statusModerate.withValues(alpha: 0.12),
          ),
          _buildMetricBox(
            title: 'Avg. Confidence',
            value: '${avgConfidence.toStringAsFixed(1)}%',
            subtitle: 'MobileNetV3 precision',
            icon: Icons.speed_rounded,
            iconColor: SariwaColors.statusInfo,
            iconBg: SariwaColors.statusInfo.withValues(alpha: 0.12),
          ),
        ];

        if (isDesktop) {
          return Row(
            children: List.generate(
              cards.length,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: StaggeredReveal(staggerIndex: i + 1, child: cards[i]),
                ),
              ),
            ),
          );
        } else {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              cards.length,
              (i) => SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: StaggeredReveal(staggerIndex: i + 1, child: cards[i]),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060A2229),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.5, color: SariwaColors.textMutedDark),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Left Column: Interactive Fish Freshness Scanner Card
  Widget _buildScannerCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.borderLightTeal, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080A2229),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Freshness Inspection',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Multi-cue analysis of cornea, gills & dermal sheen',
                            style: TextStyle(
                              fontSize: 12,
                              color: SariwaColors.textSecondaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SariwaColors.bgDashboardSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SariwaColors.borderLightTeal,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'MobileNetV3',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Upload Dropzone or Selected Image Preview
          if (state.selectedImageBytes == null)
            _buildEmptyUploadDropzone(controller)
          else
            _buildSelectedImagePreview(state, controller),

          const SizedBox(height: 20),

          // Primary Inspection CTA Button
          if (state.selectedImageBytes != null)
            AppButton.primary(
              label: state.isClassifying
                  ? 'Analyzing Tissue & Cornea...'
                  : 'Classify Fish Freshness',
              isLoading: state.isClassifying,
              height: 48,
              borderRadius: 14,
              icon: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.white,
              ),
              onPressed: state.isClassifying
                  ? () {}
                  : () => controller.classify(),
            ),

          // Live Result Breakdown (when available)
          if (state.latestResult != null) ...[
            const SizedBox(height: 24),
            const Divider(color: SariwaColors.borderLightTeal, height: 1),
            const SizedBox(height: 20),
            _buildInspectionResultView(state.latestResult!),
          ],
        ],
      ),
    );
  }

  // Upload Dropzone View
  Widget _buildEmptyUploadDropzone(ClassificationController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SariwaColors.brandPrimary.withValues(alpha: 0.35),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 36,
              color: SariwaColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Select or capture a fish image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Supports JPEG or PNG formats up to 5 MB per inspection',
            style: TextStyle(
              fontSize: 12,
              color: SariwaColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 17),
                label: const Text('Browse Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SariwaColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 17),
                label: const Text('Use Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.brandPrimary,
                  side: const BorderSide(color: SariwaColors.borderLightTeal),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Selected Image Preview View
  Widget _buildSelectedImagePreview(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.memory(state.selectedImageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: SariwaColors.brandPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.selectedImageName ?? 'fish_scan.jpg',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SariwaColors.textPrimaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => controller.clearSelection(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: SariwaColors.statusSpoiled,
                ),
                label: const Text(
                  'Remove',
                  style: TextStyle(
                    color: SariwaColors.statusSpoiled,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Full Live Classification Inspection Output
  Widget _buildInspectionResultView(ClassificationResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result Grade Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: result.statusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: result.statusColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.statusColor,
                ),
                child: Icon(
                  result.isFresh
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          result.label,
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: result.statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: result.statusColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            result.grade,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: result.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Statistical Confidence: ${result.formattedConfidence}',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sensory Indicators Breakdown Grid
        const Text(
          'Sensory Biomarkers Analysis',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: SariwaColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSensoryTile(
                title: 'Cornea / Eyes',
                value: result.eyesIndicator,
                color: result.statusColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSensoryTile(
                title: 'Branchial Gills',
                value: result.gillsIndicator,
                color: result.statusColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSensoryTile(
                title: 'Dermal Scales',
                value: result.scalesIndicator,
                color: result.statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Recommendation Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SariwaColors.bgDashboardSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SariwaColors.borderLightTeal),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: SariwaColors.brandPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.recommendation,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // PostgreSQL Saved Banner
        if (result.saved && result.scanId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: SariwaColors.statusFresh.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 15,
                  color: SariwaColors.statusFresh,
                ),
                const SizedBox(width: 8),
                Text(
                  'Archived in PostgreSQL History — Scan ID #${result.scanId}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.statusFresh,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Mandatory Disclaimer per SRS FR-008
        Text(
          'Disclaimer: SariwaBa AI assessments are designed for decision-support and quality benchmarking. Sensory results should be validated with standard organoleptic procedures for critical consumer safety.',
          style: TextStyle(
            fontSize: 11,
            height: 1.35,
            color: SariwaColors.textMutedDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSensoryTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: SariwaColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // Right Column: Classification History Card
  Widget _buildHistoryCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    var filtered = state.history;
    if (_historyFilter == 'Fresh') {
      filtered = state.history.where((s) => s.isFresh).toList();
    } else if (_historyFilter == 'Non-Fresh') {
      filtered = state.history.where((s) => !s.isFresh).toList();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.borderLightTeal, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080A2229),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count & filter chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 20,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audit History',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${state.history.length} scans recorded in PostgreSQL',
                            style: TextStyle(
                              fontSize: 12,
                              color: SariwaColors.textSecondaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => controller.loadHistory(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Refresh history from server',
                color: SariwaColors.brandPrimary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Segment Tabs
          Row(
            children: ['All', 'Fresh', 'Non-Fresh'].map((filter) {
              final isSelected = _historyFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _historyFilter = filter;
                    });
                  },
                  selectedColor: SariwaColors.brandPrimary.withValues(
                    alpha: 0.15,
                  ),
                  backgroundColor: SariwaColors.bgDashboard,
                  side: BorderSide(
                    color: isSelected
                        ? SariwaColors.brandPrimary
                        : SariwaColors.borderLightTeal,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? SariwaColors.brandPrimary
                        : SariwaColors.textSecondaryDark,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // History List View or Empty State
          if (state.isLoadingHistory && state.history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: SariwaColors.brandPrimary,
                ),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyHistoryState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scan = filtered[index];
                return _buildHistoryItemRow(scan, controller, state);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/SariwaBa logo.png',
            height: 64,
            errorBuilder: (_, _, _) => const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: SariwaColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No scan history found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload a fish photo to start building your permanent quality log.',
            style: TextStyle(
              fontSize: 12,
              color: SariwaColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItemRow(
    ClassificationResult scan,
    ClassificationController controller,
    ClassificationState state,
  ) {
    final isDeleting = state.deletingScanId == scan.scanId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Row(
        children: [
          // Image thumbnail or badge
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              color: scan.statusColor.withValues(alpha: 0.15),
              child: scan.imageUrl != null && scan.imageUrl!.isNotEmpty
                  ? Image.network(
                      scan.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.set_meal_rounded,
                        color: scan.statusColor,
                        size: 26,
                      ),
                    )
                  : Icon(
                      Icons.set_meal_rounded,
                      color: scan.statusColor,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Metadata & status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      scan.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: scan.statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: scan.statusColor, width: 0.8),
                      ),
                      child: Text(
                        scan.formattedConfidence,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: scan.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  scan.createdAt != null
                      ? '${scan.createdAt!.month}/${scan.createdAt!.day}/${scan.createdAt!.year} at ${scan.createdAt!.hour}:${scan.createdAt!.minute.toString().padLeft(2, '0')}'
                      : 'Audit Scan #${scan.scanId ?? ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),

          // Delete button
          if (scan.scanId != null)
            IconButton(
              icon: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              color: SariwaColors.textMutedDark,
              tooltip: 'Delete scan',
              onPressed: isDeleting
                  ? null
                  : () {
                      _confirmDelete(context, scan.scanId!, controller);
                    },
            ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int scanId,
    ClassificationController controller,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Scan Record?'),
        content: Text(
          'Are you sure you want to permanently delete Scan #$scanId from PostgreSQL history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.statusSpoiled,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              controller.deleteScan(scanId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner({
    required String message,
    required bool isError,
  }) {
    final color = isError
        ? SariwaColors.statusSpoiled
        : SariwaColors.statusFresh;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} SariwaBa — Intelligent Fish Freshness Classification System. All rights reserved.',
        style: TextStyle(fontSize: 12, color: SariwaColors.textMutedDark),
      ),
    );
  }
}
