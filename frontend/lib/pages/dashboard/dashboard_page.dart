import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../services/classification/classification_service.dart';
import '../../widgets/classification/roi_cropper_widget.dart';
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
  String _historyFilter = 'All'; // 'All', 'Fresh', 'Not Fresh'
  bool _isCropModalOpen = false;
  BuildContext? _cropModalContext;

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

  void _showRoiCropperModal() {
    if (!mounted || _isCropModalOpen) return;
    final current = ref.read(classificationControllerProvider);
    if (!current.hasSelectedImage || current.isCropConfirmed) return;

    setState(() => _isCropModalOpen = true);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        _cropModalContext = dialogContext;
        return Consumer(
          builder: (context, ref, _) {
            final modalState = ref.watch(classificationControllerProvider);
            final modalController =
                ref.read(classificationControllerProvider.notifier);

            if (!_isCropModalOpen ||
                !modalState.hasSelectedImage ||
                modalState.isCropConfirmed) {
              return const SizedBox.shrink();
            }

            return Dialog(
              key: const Key('roi_cropper_modal'),
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: RoiCropperWidget(
                  state: modalState,
                  controller: modalController,
                  isModal: true,
                  onCloseModal: _closeRoiCropperModal,
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _cropModalContext = null;
      if (mounted && _isCropModalOpen) {
        setState(() => _isCropModalOpen = false);
      }
    });
  }

  void _closeRoiCropperModal() {
    final dialogCtx = _cropModalContext;
    _cropModalContext = null;
    if (mounted && _isCropModalOpen) {
      setState(() => _isCropModalOpen = false);
    }
    if (dialogCtx != null && dialogCtx.mounted) {
      Navigator.of(dialogCtx).pop();
    }
  }

  @override
  void dispose() {
    _cropModalContext = null;
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

    ref.listen<ClassificationState>(classificationControllerProvider,
        (previous, next) {
      final isNewUnconfirmedImage = next.hasSelectedImage &&
          !next.isCropConfirmed &&
          previous?.selectedImageBytes != next.selectedImageBytes;
      final isReopenedCropEditor = next.hasSelectedImage &&
          !next.isCropConfirmed &&
          ((previous?.isCropConfirmed == true) ||
              (previous?.isEditingCrop == false && next.isEditingCrop));

      if (isNewUnconfirmedImage || isReopenedCropEditor) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final latest = ref.read(classificationControllerProvider);
          if (latest.hasSelectedImage && !latest.isCropConfirmed) {
            _showRoiCropperModal();
          }
        });
      } else if (next.isCropConfirmed || !next.hasSelectedImage) {
        if (_isCropModalOpen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _closeRoiCropperModal();
            }
          });
        }
      }
    });

    final isModalEffectivelyOpen = _isCropModalOpen &&
        classState.hasSelectedImage &&
        !classState.isCropConfirmed;

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

                      // Status Notifications (Errors / Rejections / Success)
                      if (classState.errorMessage != null &&
                          !isModalEffectivelyOpen)
                        _buildNotificationBanner(
                          message: classState.errorMessage!,
                          isError: true,
                          state: classState,
                          controller: classController,
                        ),
                      if (classState.successMessage != null)
                        _buildNotificationBanner(
                          message: classState.successMessage!,
                          isError: false,
                          state: classState,
                          controller: classController,
                        ),
                      if ((classState.errorMessage != null &&
                              !isModalEffectivelyOpen) ||
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
    final isGuestUser = user?.isGuest == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final headerInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Flexible(
                    child: Text(
                      isGuestUser
                          ? 'Guest Evaluation Session'
                          : 'PostgreSQL Live Session',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: SariwaColors.brandPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back, $name!',
              style: AppTypography.displayLarge.copyWith(
                color: SariwaColors.textPrimaryDark,
                fontSize: isCompact ? 22 : 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload a Tilapia photo, select and confirm an eye or exposed-gill region, and run preliminary MobileNetV3 freshness analysis.',
              style: AppTypography.bodyMedium.copyWith(
                color: SariwaColors.textSecondaryDark,
                fontSize: 14,
              ),
            ),
          ],
        );

        final syncBtn = OutlinedButton.icon(
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
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerInfo,
              const SizedBox(height: 12),
              syncBtn,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: headerInfo),
            const SizedBox(width: 16),
            syncBtn,
          ],
        );
      },
    );
  }

  // 4 KPI Summary Cards
  Widget _buildKpiMetrics(List<ClassificationResult> history) {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final cautionCount = total - freshCount;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 0.0;

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
                : 'Fresh Tilapia count',
            icon: Icons.check_circle_outline_rounded,
            iconColor: SariwaColors.statusFresh,
            iconBg: SariwaColors.statusFresh.withValues(alpha: 0.12),
          ),
          _buildMetricBox(
            title: 'Not Fresh Alerts',
            value: cautionCount.toString(),
            subtitle: 'Non-fresh detections',
            icon: Icons.warning_amber_rounded,
            iconColor: SariwaColors.statusModerate,
            iconBg: SariwaColors.statusModerate.withValues(alpha: 0.12),
          ),
          _buildMetricBox(
            title: 'Avg. Confidence',
            value: total > 0 ? '${avgConfidence.toStringAsFixed(1)}%' : '—',
            subtitle: 'History mean score',
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
                  style: const TextStyle(
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
            style: const TextStyle(
              fontSize: 11.5,
              color: SariwaColors.textMutedDark,
            ),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Freshness Inspection',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Tilapia Eye & Exposed Gill ROI Classification',
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
          const SizedBox(height: 16),

          // 4-Stage Guided Workflow Stepper
          _buildWorkflowStepPills(state),
          const SizedBox(height: 16),

          // Step 1: Upload Dropzone OR ROI Preparation Modal / Confirmed Summary
          if (state.selectedImageBytes == null)
            _buildEmptyUploadDropzone(controller)
          else if (_isCropModalOpen && !state.isCropConfirmed)
            _buildActiveModalPlaceholderCard(state)
          else
            RoiCropperWidget(
              state: state,
              controller: controller,
              isModal: false,
              onOpenModal: _showRoiCropperModal,
            ),

          const SizedBox(height: 20),

          // Step 4: Validate and Classify Section (hidden behind modal when modal is active)
          if (state.selectedImageBytes != null &&
              !(_isCropModalOpen && !state.isCropConfirmed))
            _buildStep4ClassifySection(state, controller),

          // Dedicated Image Rejection State (when input is rejected by validation or Model A)
          if (state.errorMessage != null &&
              state.isInputRejection &&
              !const {
                'MISSING_IMAGE',
                'INVALID_REGION_TYPE',
                'CONFIRMATION_REQUIRED',
              }.contains(state.errorCode)) ...[
            const SizedBox(height: 24),
            const Divider(color: SariwaColors.borderLightTeal, height: 1),
            const SizedBox(height: 20),
            _buildImageRejectionCard(state, controller),
          ] else if (state.errorMessage != null && !state.isInputRejection) ...[
            const SizedBox(height: 24),
            const Divider(color: SariwaColors.borderLightTeal, height: 1),
            const SizedBox(height: 20),
            _buildTechnicalErrorCard(state, controller),
          ],

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

  Widget _buildActiveModalPlaceholderCard(ClassificationState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.crop_free_rounded,
              color: SariwaColors.brandPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedImageName ?? 'tilapia_scan.jpg',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Region selection & ROI cropping active in modal dialog...',
                  style: TextStyle(
                    fontSize: 12,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStepPills(ClassificationState state) {
    final step1Done = state.hasSelectedImage;
    final step2Done = state.hasSelectedRegion;
    final step3Done = state.isCropConfirmed && state.confirmedImageBytes != null;
    final step4Done = state.latestResult != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboardSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildStepPill(
            stepNumber: '1',
            label: 'Upload Image',
            isCompleted: step1Done,
            isActive: !step1Done,
          ),
          _buildStepPill(
            stepNumber: '2',
            label: 'Select Region',
            isCompleted: step2Done,
            isActive: step1Done && !step2Done,
          ),
          _buildStepPill(
            stepNumber: '3',
            label: 'Crop & Confirm',
            isCompleted: step3Done,
            isActive: step2Done && !step3Done,
          ),
          _buildStepPill(
            stepNumber: '4',
            label: 'Validate & Classify',
            isCompleted: step4Done,
            isActive: step3Done && !step4Done,
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill({
    required String stepNumber,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    final bgColor = isCompleted
        ? SariwaColors.brandPrimary.withValues(alpha: 0.14)
        : (isActive ? Colors.white : Colors.transparent);
    final textColor = isCompleted || isActive
        ? SariwaColors.brandPrimary
        : SariwaColors.textMutedDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted || isActive
              ? SariwaColors.brandPrimary.withValues(alpha: 0.35)
              : SariwaColors.borderLightTeal,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.adjust_rounded,
            size: 13,
            color: textColor,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '$stepNumber. $label',
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isCompleted || isActive ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4ClassifySection(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final isReady = state.isReadyToClassify;
    final statusText = state.processingStage ?? 'Analyzing image...';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'STEP 4',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Validate and Classify',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isReady
                ? 'Confirmed ${state.selectedRegion?.displayName ?? ''} region is ready for backend validation and MobileNetV3 freshness analysis.'
                : 'Complete Step 2 (select Eye or Gill) and Step 3 (confirm cropped region or close-up) to enable classification.',
            style: const TextStyle(
              fontSize: 11.5,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: !isReady && !state.isClassifying
                ? () => controller.classify()
                : null,
            child: AppButton.primary(
              key: const Key('validate_and_classify_button'),
              label: state.isClassifying
                  ? statusText
                  : 'Validate & Classify Freshness',
              isLoading: state.isClassifying,
              height: 48,
              borderRadius: 14,
              icon: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.white,
              ),
              onPressed: isReady && !state.isClassifying
                  ? () => controller.classify()
                  : null,
            ),
          ),
          if (state.isClassifying) ...[
            const SizedBox(height: 10),
            Container(
              key: const Key('analyzing_image_status'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SariwaColors.borderLightTeal),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    size: 15,
                    color: SariwaColors.brandPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Dedicated Rejected-Image State Card (Neutral / Warning styling — never Fresh/Not Fresh colors)
  Widget _buildImageRejectionCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final code = state.errorCode;
    final guidance = ClassificationApiException.contextualGuidanceForCode(code);
    final serverMessage = state.errorMessage ?? guidance;

    return Container(
      key: const Key('image_rejection_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SariwaColors.statusModerate.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SariwaColors.statusModerate.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SariwaColors.statusModerate.withValues(alpha: 0.16),
                ),
                child: const Icon(
                  Icons.unpublished_outlined,
                  color: SariwaColors.statusModerate,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Image Not Supported',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                        if (code != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: SariwaColors.statusModerate
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: SariwaColors.textPrimaryDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'The uploaded image could not be verified as a supported fish eye or exposed-gill photograph.',
                      style: TextStyle(
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
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SariwaColors.borderLightTeal),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serverMessage,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                if (serverMessage != guidance) ...[
                  const SizedBox(height: 4),
                  Text(
                    guidance,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: SariwaColors.textSecondaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  key: const Key('rejection_edit_crop_button'),
                  onPressed: () => controller.editCrop(),
                  icon: const Icon(Icons.crop_rotate_rounded, size: 15),
                  label: const Text('Edit Crop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    side: const BorderSide(color: SariwaColors.borderLightTeal),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  key: const Key('rejection_change_region_button'),
                  onPressed: () => controller.changeRegion(),
                  icon: const Icon(Icons.swap_vert_rounded, size: 15),
                  label: const Text('Change Region'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    side: const BorderSide(color: SariwaColors.borderLightTeal),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              OutlinedButton.icon(
                key: const Key('rejection_replace_image_button'),
                onPressed: () => controller.clearSelection(),
                icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                label: const Text('Replace Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.statusSpoiled,
                  side: const BorderSide(color: SariwaColors.borderLightTeal),
                  backgroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              if (state.isReadyToClassify)
                ElevatedButton.icon(
                  key: const Key('rejection_try_again_button'),
                  onPressed: () => controller.classify(),
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dedicated Server / Network Technical Failure Card (distinct from rejected input)
  Widget _buildTechnicalErrorCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return Container(
      key: const Key('technical_error_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboardSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: SariwaColors.textSecondaryDark,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Service or Connection Issue (${state.errorCode ?? 'ERROR'})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ??
                'Unable to reach the classification service. Please try again.',
            style: const TextStyle(
              fontSize: 12.5,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (state.isReadyToClassify)
                ElevatedButton.icon(
                  key: const Key('technical_try_again_button'),
                  onPressed: () => controller.classify(),
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  onPressed: () => controller.clearSelection(),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                  label: const Text('Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.textPrimaryDark,
                    side: const BorderSide(color: SariwaColors.borderLightTeal),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 1 Upload Dropzone View
  Widget _buildEmptyUploadDropzone(ClassificationController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'STEP 1 — UPLOAD IMAGE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
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
            'Select or capture a Tilapia image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload a whole-Tilapia photo to crop the eye or exposed gill, or upload an existing close-up (JPG, JPEG, PNG up to 5 MB).',
            style: TextStyle(
              fontSize: 12,
              color: SariwaColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                key: const Key('browse_gallery_button'),
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
              OutlinedButton.icon(
                key: const Key('use_camera_button'),
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

  // Full Live Classification Inspection Output
  Widget _buildInspectionResultView(ClassificationResult result) {
    final selectedRegionText = result.selectedRegionLabel;
    final timestampText = result.formattedTimestamp;

    return Container(
      key: const Key('classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Prediction Banner
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
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
                          if (selectedRegionText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: SariwaColors.brandPrimary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                selectedRegionText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: SariwaColors.brandPrimary,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: SariwaColors.borderLightTeal,
                              ),
                            ),
                            child: Text(
                              result.assessmentScopeLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Model Confidence: ${result.formattedConfidence}',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                      if (timestampText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Classified at: $timestampText',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: SariwaColors.textSecondaryDark,
                          ),
                        ),
                      ],
                      if (result.modelVersion != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Model: ${result.modelVersion}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: SariwaColors.textSecondaryDark,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      const Text(
                        ClassificationResult.confidenceExplanation,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: SariwaColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actual Save Status Banner
          Container(
            key: const Key('result_save_status_banner'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: result.saved
                  ? SariwaColors.brandPrimary.withValues(alpha: 0.08)
                  : SariwaColors.bgDashboardSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: result.saved
                    ? SariwaColors.brandPrimary.withValues(alpha: 0.30)
                    : SariwaColors.borderLightTeal,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.saved
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 16,
                  color: result.saved
                      ? SariwaColors.brandPrimary
                      : SariwaColors.textSecondaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.saveStatusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: result.saved
                          ? SariwaColors.brandPrimary
                          : SariwaColors.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mandatory Preliminary Disclaimer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SariwaColors.borderLightTeal),
            ),
            child: Text(
              result.disclaimer,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: SariwaColors.textSecondaryDark,
              ),
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
    } else if (_historyFilter == 'Not Fresh') {
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
                            style: const TextStyle(
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

          // Filter Segment Tabs ('All', 'Fresh', 'Not Fresh')
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Fresh', 'Not Fresh'].map((filter) {
              final isSelected = _historyFilter == filter;
              return FilterChip(
                key: Key('history_filter_${filter.toLowerCase().replaceAll(' ', '_')}'),
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
            _buildEmptyHistoryState(
              activeFilter: _historyFilter,
              hasAnyHistory: state.history.isNotEmpty,
            )
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

  Widget _buildEmptyHistoryState({
    required String activeFilter,
    required bool hasAnyHistory,
  }) {
    String emptyTitle;
    String emptySubtitle;

    if (!hasAnyHistory) {
      emptyTitle = 'No classification history';
      emptySubtitle =
          'Upload a Tilapia photo to start building your permanent quality log.';
    } else if (activeFilter == 'Fresh') {
      emptyTitle = 'No Fresh results';
      emptySubtitle =
          'No scans classified as Fresh were found in your audit history.';
    } else if (activeFilter == 'Not Fresh') {
      emptyTitle = 'No Not Fresh results';
      emptySubtitle =
          'No scans classified as Not Fresh were found in your audit history.';
    } else {
      emptyTitle = 'No matching records';
      emptySubtitle = 'Adjust your selected filter to view recorded scans.';
    }

    return Container(
      key: const Key('empty_history_state'),
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
          Text(
            emptyTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            emptySubtitle,
            style: const TextStyle(
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
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      scan.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: scan.statusColor,
                      ),
                    ),
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
                    if (scan.regionDisplayName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              SariwaColors.brandPrimary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Selected region: ${scan.regionDisplayName!}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: SariwaColors.brandPrimary,
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
                  style: const TextStyle(
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
    required ClassificationState state,
    required ClassificationController controller,
  }) {
    final color = isError
        ? (state.isInputRejection
            ? SariwaColors.statusModerate
            : SariwaColors.statusSpoiled)
        : SariwaColors.statusFresh;

    final showRecoveryActions =
        isError && state.hasSelectedImage && !state.isClassifying;

    return Container(
      key: Key(
        isError ? 'error_notification_banner' : 'success_notification_banner',
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isError
                    ? (state.isInputRejection
                        ? Icons.warning_amber_rounded
                        : Icons.error_outline_rounded)
                    : Icons.check_circle_outline_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isError && state.errorCode != null) ...[
                      Text(
                        state.isInputRejection
                            ? 'Input Rejected (${state.errorCode})'
                            : 'Request Error (${state.errorCode})',
                        style: TextStyle(
                          color: color,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: TextStyle(
                        color: SariwaColors.textPrimaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showRecoveryActions) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (state.isCropConfirmed)
                  OutlinedButton.icon(
                    key: const Key('banner_edit_crop_button'),
                    onPressed: () => controller.editCrop(),
                    icon: const Icon(Icons.crop_rotate_rounded, size: 15),
                    label: const Text('Edit Crop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SariwaColors.brandPrimary,
                      side: const BorderSide(
                        color: SariwaColors.borderLightTeal,
                      ),
                      backgroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                OutlinedButton.icon(
                  key: const Key('banner_replace_image_button'),
                  onPressed: () => controller.clearSelection(),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                  label: const Text('Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.statusSpoiled,
                    side: const BorderSide(
                      color: SariwaColors.borderLightTeal,
                    ),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (state.isReadyToClassify)
                  ElevatedButton.icon(
                    key: const Key('banner_retry_button'),
                    onPressed: () => controller.classify(),
                    icon: const Icon(Icons.refresh_rounded, size: 15),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SariwaColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} SariwaBa — Intelligent Fish Freshness Classification System. All rights reserved.',
        style: const TextStyle(fontSize: 12, color: SariwaColors.textMutedDark),
      ),
    );
  }
}
