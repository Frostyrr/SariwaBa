import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
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

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _historyFilter = 'All'; // 'All', 'Fresh', 'Not Fresh'
  String _searchQuery = '';
  String _activeNav = 'Scanner'; // 'Scanner', 'History', 'Summary'
  bool _isCropModalOpen = false;
  BuildContext? _cropModalContext;
  bool _isHistorySelectionMode = false;
  final Set<int> _selectedHistoryScanIds = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authControllerProvider).isAuthenticated) {
        ref.read(classificationControllerProvider.notifier).loadHistory();
      }
    });
  }

  void _showRoiCropperModal() {
    if (!mounted || _isCropModalOpen) return;
    final current = ref.read(classificationControllerProvider);
    if (!current.hasSelectedImage) return;

    setState(() => _isCropModalOpen = true);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x330A1926),
      builder: (dialogContext) {
        _cropModalContext = dialogContext;
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Consumer(
            builder: (context, ref, _) {
              final modalState = ref.watch(classificationControllerProvider);
              final modalController =
                  ref.read(classificationControllerProvider.notifier);

              if (!_isCropModalOpen || !modalState.hasSelectedImage) {
                return const SizedBox.shrink();
              }

              return Dialog(
                key: const Key('roi_cropper_modal'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: RoiCropperWidget(
                    state: modalState,
                    controller: modalController,
                    isModal: true,
                    onCloseModal: _closeRoiCropperModal,
                    onOpenModal: _showRoiCropperModal,
                  ),
                ),
              );
            },
          ),
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
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFrostedGlassCard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
    double borderRadius = 24,
    Color fillColor = const Color(0xD9FFFFFF),
    Color borderColor = const Color(0xFFE2E8F0),
    double borderWidth = 1.0,
    double blurSigma = 6,
  }) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final classState = ref.watch(classificationControllerProvider);
    final classController = ref.read(classificationControllerProvider.notifier);
    final user = authState.user;
    final isGuestUser = authState.isGuest || user == null || user.isGuest;

    ref.listen<ClassificationState>(classificationControllerProvider,
        (previous, next) {
      final isNewUnconfirmedImage = next.hasSelectedImage &&
          !next.isCropConfirmed &&
          previous?.selectedImageBytes != next.selectedImageBytes;
      final isReopenedCropEditor = next.hasSelectedImage &&
          !next.isCropConfirmed &&
          previous?.isEditingCrop == false &&
          next.isEditingCrop == true;

      if (isNewUnconfirmedImage || isReopenedCropEditor) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final latest = ref.read(classificationControllerProvider);
          if (latest.hasSelectedImage && !latest.isCropConfirmed) {
            _showRoiCropperModal();
          }
        });
      } else if (!next.hasSelectedImage) {
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
        classState.hasSelectedImage;

    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontFamily: 'Geist',
        letterSpacing: AppTypography.defaultLetterSpacing,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F9),
        body: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        SariwaColors.brandPrimary.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: 120,
              child: IgnorePointer(
                child: Container(
                  width: 460,
                  height: 460,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF38BDF8).withValues(alpha: 0.11),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 264,
                        child: _buildSidebar(
                          user: user,
                          isGuestUser: isGuestUser,
                          historyCount: classState.history.length,
                          authController: authController,
                          classController: classController,
                        ),
                      ),
                      Expanded(
                        child: _buildMainWorkspace(
                          user: user,
                          isGuestUser: isGuestUser,
                          isDesktop: true,
                          isModalEffectivelyOpen: isModalEffectivelyOpen,
                          classState: classState,
                          classController: classController,
                          authController: authController,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildMobileTopBar(
                      user: user,
                      isGuestUser: isGuestUser,
                      authController: authController,
                      classController: classController,
                    ),
                    Expanded(
                      child: _buildMainWorkspace(
                        user: user,
                        isGuestUser: isGuestUser,
                        isDesktop: false,
                        isModalEffectivelyOpen: isModalEffectivelyOpen,
                        classState: classState,
                        classController: classController,
                        authController: authController,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar({
    required dynamic user,
    required bool isGuestUser,
    required int historyCount,
    required AuthController authController,
    required ClassificationController classController,
  }) {
    final firstName =
        (user?.displayName ?? 'Evaluator').toString().split(' ').first;
    final email = (user?.email ?? 'Guest Session').toString();

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xD9FFFFFF),
            border: Border(
              right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => authController.goToLanding(),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/SariwaBa logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          CupertinoIcons.sparkles,
                          color: SariwaColors.brandPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SariwaBa',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.search,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        style: const TextStyle(
                          fontSize: 13,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search scans...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: Color(0xFF94A3B8),
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSidebarNavItem(
                icon: CupertinoIcons.viewfinder,
                label: 'Freshness Scanner',
                isActive: _activeNav == 'Scanner',
                onTap: () => setState(() => _activeNav = 'Scanner'),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.clock,
                label: 'Scan History',
                badgeCount: historyCount,
                isActive: _activeNav == 'History',
                onTap: () => setState(() => _activeNav = 'History'),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.chart_bar_square,
                label: 'Overview Stats',
                isActive: _activeNav == 'Summary',
                onTap: () => setState(() => _activeNav = 'Summary'),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.house,
                label: 'Back to Home',
                isActive: false,
                onTap: () => authController.goToLanding(),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.arrow_down_circle,
                label: 'Download App',
                isActive: false,
                onTap: () => authController.goToDownloads(),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGuestUser
                            ? CupertinoIcons.person_crop_circle_badge_exclam
                            : CupertinoIcons.sparkles,
                        size: 16,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGuestUser
                          ? 'Guest Evaluation Mode'
                          : 'Quick Tilapia Tip',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGuestUser
                          ? 'Sign in with Google to save your freshness scans to your history.'
                          : 'Clear, well-lit close-ups of the eye or exposed gill give the best results.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                    if (isGuestUser) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => authController.continueWithGoogle(),
                        child: const Text(
                          'Connect with Google',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        SariwaColors.brandPrimary.withValues(alpha: 0.14),
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textPrimaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textSecondaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isGuestUser ? 'Sign in' : 'Sign out',
                    onPressed: () => isGuestUser
                        ? authController.goToLogin()
                        : authController.signOut(),
                    icon: const Icon(
                      CupertinoIcons.square_arrow_right,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? SariwaColors.brandPrimary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? SariwaColors.brandPrimary
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: isActive
                        ? SariwaColors.brandPrimary
                        : SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTopBar({
    required dynamic user,
    required bool isGuestUser,
    required AuthController authController,
    required ClassificationController classController,
  }) {
    final firstName =
        (user?.displayName ?? 'Evaluator').toString().split(' ').first;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xD9FFFFFF),
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => authController.goToLanding(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/SariwaBa logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          CupertinoIcons.sparkles,
                          color: SariwaColors.brandPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'SariwaBa',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      firstName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => classController.loadHistory(),
                    icon: const Icon(CupertinoIcons.refresh, size: 17),
                    color: SariwaColors.brandPrimary,
                    tooltip: 'Sync History',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainWorkspace({
    required dynamic user,
    required bool isGuestUser,
    required bool isDesktop,
    required bool isModalEffectivelyOpen,
    required ClassificationState classState,
    required ClassificationController classController,
    required AuthController authController,
  }) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 18,
        vertical: isDesktop ? 28 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredReveal(
                staggerIndex: 0,
                child: _buildDashboardHeader(
                  user,
                  classController,
                  isGuestSession: isGuestUser,
                  onConnectGoogle: () => authController.continueWithGoogle(),
                  onBackHome: () => authController.goToLanding(),
                ),
              ),
              const SizedBox(height: 20),
              _buildKpiMetrics(classState.history),
              const SizedBox(height: 22),
              if (classState.errorMessage != null && !isModalEffectivelyOpen)
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
                const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoCol = constraints.maxWidth >= 820;

                  if (isTwoCol) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: StaggeredReveal(
                            staggerIndex: 5,
                            child: _buildScannerCard(
                              classState,
                              classController,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 5,
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
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        staggerIndex: 6,
                        child: _buildHistoryCard(
                          classState,
                          classController,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
              _buildSimpleFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(
    dynamic user,
    ClassificationController controller, {
    bool isGuestSession = false,
    VoidCallback? onConnectGoogle,
    VoidCallback? onBackHome,
  }) {
    final name = (user?.displayName ?? 'Evaluator').toString().split(' ').first;
    final isGuestUser = isGuestSession || user?.isGuest == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final headerInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onBackHome,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.chevron_left,
                          size: 13,
                          color: SariwaColors.brandPrimary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCCFFFFFF),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
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
                        isGuestUser
                            ? 'Guest Evaluation Mode'
                            : 'Account Synced',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome back, $name!',
              style: AppTypography.displayLarge.copyWith(
                color: SariwaColors.textPrimaryDark,
                fontSize: isCompact ? 23 : 28,
                fontWeight: FontWeight.w800,
                letterSpacing: AppTypography.defaultLetterSpacing,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload a Tilapia photo, frame the eye or exposed gill, and check its freshness in seconds.',
              style: AppTypography.bodyMedium.copyWith(
                color: SariwaColors.textSecondaryDark,
                fontSize: 13.5,
                letterSpacing: AppTypography.defaultLetterSpacing,
              ),
            ),
          ],
        );

        final actionsRow = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCircularHeaderIconButton(
              icon: CupertinoIcons.question,
              tooltip:
                  'Eye is selected by default. Hover over an uploaded photo for framing guidance.',
              onTap: () {},
            ),
            _buildCircularHeaderIconButton(
              icon: CupertinoIcons.slider_horizontal_3,
              tooltip: 'Filter scan history',
              onTap: () {
                setState(() {
                  _historyFilter = _historyFilter == 'All'
                      ? 'Fresh'
                      : (_historyFilter == 'Fresh' ? 'Not Fresh' : 'All');
                });
              },
            ),
            if (isGuestUser)
              OutlinedButton.icon(
                onPressed: onConnectGoogle,
                icon: const Icon(CupertinoIcons.person_badge_plus, size: 15),
                label: const Text('Connect with Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.brandPrimary,
                  side: const BorderSide(
                    color: SariwaColors.brandPrimary,
                    width: 0.8,
                  ),
                  backgroundColor: const Color(0xD9FFFFFF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => controller.loadHistory(),
                icon: const Icon(CupertinoIcons.refresh, size: 14),
                label: const Text('Sync History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.textPrimaryDark,
                  side: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                  backgroundColor: const Color(0xD9FFFFFF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerInfo,
              const SizedBox(height: 12),
              actionsRow,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: headerInfo),
            const SizedBox(width: 16),
            actionsRow,
          ],
        );
      },
    );
  }

  Widget _buildCircularHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: const Color(0xD9FFFFFF),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiMetrics(List<ClassificationResult> history) {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final cautionCount = total - freshCount;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;

        final cards = [
          _buildMetricBox(
            title: 'Total Scans',
            value: total.toString(),
            subtitle: 'Saved inspections',
            icon: CupertinoIcons.chart_bar_square,
            iconColor: SariwaColors.brandPrimary,
            iconBg: SariwaColors.brandPrimary.withValues(alpha: 0.10),
          ),
          _buildMetricBox(
            title: 'Sariwa (Fresh)',
            value: freshCount.toString(),
            subtitle: total > 0
                ? '${((freshCount / total) * 100).toStringAsFixed(0)}% of total scans'
                : 'Fresh Tilapia count',
            icon: CupertinoIcons.checkmark_seal,
            iconColor: SariwaColors.statusFresh,
            iconBg: SariwaColors.statusFresh.withValues(alpha: 0.10),
          ),
          _buildMetricBox(
            title: 'Not Fresh Alerts',
            value: cautionCount.toString(),
            subtitle: 'Needs attention',
            icon: CupertinoIcons.exclamationmark_triangle,
            iconColor: SariwaColors.statusModerate,
            iconBg: SariwaColors.statusModerate.withValues(alpha: 0.10),
          ),
          _buildMetricBox(
            title: 'Avg. Confidence',
            value: total > 0 ? '${avgConfidence.toStringAsFixed(1)}%' : '—',
            subtitle: 'Average across scans',
            icon: CupertinoIcons.speedometer,
            iconColor: SariwaColors.statusInfo,
            iconBg: SariwaColors.statusInfo.withValues(alpha: 0.10),
          ),
        ];

        if (isDesktop) {
          return Row(
            children: List.generate(
              cards.length,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 6,
                    right: i == cards.length - 1 ? 0 : 6,
                  ),
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
    return _buildFrostedGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      blurSigma: 18,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textMutedDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return _buildFrostedGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      blurSigma: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.viewfinder,
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
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Check freshness from a Tilapia eye or exposed gill photo',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: AppTypography.defaultLetterSpacing,
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
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Tilapia',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (state.isUploadingImage)
            _buildImageUploadingCard()
          else if (state.selectedImageBytes == null)
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
          if (state.selectedImageBytes != null &&
              !(_isCropModalOpen && !state.isCropConfirmed)) ...[
            const SizedBox(height: 16),
            _buildStep4ClassifySection(state, controller),
          ],
          if (state.errorMessage != null &&
              state.isInputRejection &&
              !const {
                'MISSING_IMAGE',
                'INVALID_REGION_TYPE',
                'CONFIRMATION_REQUIRED',
              }.contains(state.errorCode)) ...[
            const SizedBox(height: 20),
            _buildImageRejectionCard(state, controller),
          ] else if (state.errorMessage != null && !state.isInputRejection) ...[
            const SizedBox(height: 20),
            _buildTechnicalErrorCard(state, controller),
          ],
          if (state.latestResult != null) ...[
            const SizedBox(height: 20),
            _buildInspectionResultView(state.latestResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyUploadDropzone(ClassificationController controller) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.pickImage(ImageSource.gallery),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xE6FFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: SariwaColors.brandPrimary.withValues(alpha: 0.42),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  CupertinoIcons.cloud_upload,
                  size: 26,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 14),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 15,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  children: [
                    TextSpan(
                      text: 'Click here ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'to select or capture a Tilapia image',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Supported Format: JPG, JPEG, PNG, HEIC (5 MB max · Eye pre-selected by default)',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.textSecondaryDark,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    key: const Key('browse_gallery_button'),
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                    icon:
                        const Icon(CupertinoIcons.photo_on_rectangle, size: 15),
                    label: const Text('Browse Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SariwaColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const Key('use_camera_button'),
                    onPressed: () => controller.pickImage(ImageSource.camera),
                    icon: const Icon(CupertinoIcons.camera, size: 15),
                    label: const Text('Use Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SariwaColors.textPrimaryDark,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadingCard() {
    return Container(
      key: const Key('image_uploading_state'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SariwaColors.brandPrimary.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: SariwaColors.brandPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
            ),
            child: const Center(
              child: CupertinoActivityIndicator(radius: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Uploading & Processing Photo...',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verifying image headers and preparing viewer...',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: const LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Color(0xFFE2E8F0),
                color: SariwaColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveModalPlaceholderCard(ClassificationState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.crop,
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
                    fontWeight: FontWeight.w600,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  state.latestResult != null
                      ? 'Viewing freshness results in inspection modal...'
                      : (state.isClassifying
                          ? 'Evaluating image freshness in modal...'
                          : 'Adjusting photo in crop view...'),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: AppTypography.defaultLetterSpacing,
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

  Widget _buildStep4ClassifySection(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final statusText = state.processingStage ?? 'Analyzing image...';

    Future<void> handleClassifyTap() async {
      if (state.isClassifying) return;
      if (state.selectedRegion == null) {
        await controller.classify();
        return;
      }
      if (!state.isCropConfirmed) {
        controller.confirmFullImageAsCloseUp();
      }
      await controller.classify();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton.primary(
          key: const Key('validate_and_classify_button'),
          label: state.isClassifying
              ? statusText
              : 'Validate & Classify Freshness',
          isLoading: state.isClassifying,
          height: 50,
          borderRadius: 16,
          icon: const Icon(
            CupertinoIcons.sparkles,
            size: 18,
            color: Colors.white,
          ),
          onPressed: state.isClassifying ? null : handleClassifyTap,
        ),
        if (state.isClassifying) ...[
          const SizedBox(height: 10),
          Container(
            key: const Key('analyzing_image_status'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const CupertinoActivityIndicator(radius: 8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Color(0xFFE2E8F0),
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SariwaColors.statusSpoiled.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
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
                  color: SariwaColors.statusSpoiled.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.xmark_octagon,
                  color: SariwaColors.statusSpoiled,
                  size: 20,
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
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: AppTypography.defaultLetterSpacing,
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
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: SariwaColors.statusSpoiled
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.statusSpoiled,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        value: 0.72,
                        minHeight: 6,
                        backgroundColor: Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SariwaColors.statusSpoiled,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The uploaded image could not be verified as a supported fish eye or exposed-gill photograph.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serverMessage,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                if (serverMessage != guidance) ...[
                  const SizedBox(height: 4),
                  Text(
                    guidance,
                    style: const TextStyle(
                      fontSize: 11.5,
                      letterSpacing: AppTypography.defaultLetterSpacing,
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
                  onPressed: () {
                    controller.editCrop();
                    _showRoiCropperModal();
                  },
                  icon: const Icon(CupertinoIcons.crop, size: 14),
                  label: const Text('Edit Crop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  key: const Key('rejection_change_region_button'),
                  onPressed: () {
                    controller.changeRegion();
                    _showRoiCropperModal();
                  },
                  icon:
                      const Icon(CupertinoIcons.arrow_up_arrow_down, size: 14),
                  label: const Text('Change Region'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                key: const Key('rejection_replace_image_button'),
                onPressed: () => controller.clearSelection(),
                icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 14),
                label: const Text('Replace Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.statusSpoiled,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  backgroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              if (state.isReadyToClassify)
                ElevatedButton.icon(
                  key: const Key('rejection_try_again_button'),
                  onPressed: () => controller.classify(),
                  icon: const Icon(CupertinoIcons.refresh, size: 14),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalErrorCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return Container(
      key: const Key('technical_error_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.wifi_exclamationmark,
                color: SariwaColors.textSecondaryDark,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Service or Connection Issue (${state.errorCode ?? 'ERROR'})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: AppTypography.defaultLetterSpacing,
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
              letterSpacing: AppTypography.defaultLetterSpacing,
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
                  icon: const Icon(CupertinoIcons.refresh, size: 14),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  onPressed: () => controller.clearSelection(),
                  icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 14),
                  label: const Text('Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.textPrimaryDark,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionResultView(ClassificationResult result) {
    final selectedRegionText = result.selectedRegionLabel;
    final timestampText = result.formattedTimestamp;

    return Container(
      key: const Key('classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: result.statusColor.withValues(alpha: 0.30),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: result.statusColor.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        result.isFresh
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.exclamationmark_triangle,
                        color: result.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      result.label,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: result.statusColor,
                                      ),
                                    ),
                                    if (selectedRegionText != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          selectedRegionText,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: AppTypography.defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        result.assessmentScopeLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: AppTypography.defaultLetterSpacing,
                                          color:
                                              SariwaColors.textSecondaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                result.isFresh
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons.exclamationmark_circle_fill,
                                color: result.statusColor,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                result.statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Model Confidence: ${result.formattedConfidence}',
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing:
                                        AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.textPrimaryDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                result.formattedConfidence,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: result.statusColor,
                                ),
                              ),
                            ],
                          ),
                          if (timestampText != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Classified at: $timestampText',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
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
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          const Text(
                            ClassificationResult.confidenceExplanation,
                            style: TextStyle(
                              fontSize: 11.5,
                              letterSpacing:
                                  AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            key: const Key('result_save_status_banner'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.saved
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.info_circle,
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
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: result.saved
                          ? SariwaColors.brandPrimary
                          : SariwaColors.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Text(
              result.disclaimer,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
                letterSpacing: AppTypography.defaultLetterSpacing,
                color: SariwaColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    // Keep selection synchronized with current history
    final existingIds = state.history.map((s) => s.scanId).whereType<int>().toSet();
    _selectedHistoryScanIds.removeWhere((id) => !existingIds.contains(id));

    var filtered = state.history;
    if (_historyFilter == 'Fresh') {
      filtered = filtered.where((s) => s.isFresh).toList();
    } else if (_historyFilter == 'Not Fresh') {
      filtered = filtered.where((s) => !s.isFresh).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((s) {
        return s.label.toLowerCase().contains(q) ||
            (s.regionDisplayName?.toLowerCase().contains(q) ?? false) ||
            (s.scanId?.toString().contains(q) ?? false);
      }).toList();
    }

    return _buildFrostedGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      blurSigma: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.clock,
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
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            state.history.length == 1
                                ? '1 saved scan'
                                : '${state.history.length} saved scans',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: AppTypography.defaultLetterSpacing,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.history.isNotEmpty) ...[
                    TextButton.icon(
                      key: const Key('history_toggle_selection_mode_button'),
                      onPressed: () {
                        setState(() {
                          _isHistorySelectionMode = !_isHistorySelectionMode;
                          if (!_isHistorySelectionMode) {
                            _selectedHistoryScanIds.clear();
                          }
                        });
                      },
                      icon: Icon(
                        _isHistorySelectionMode
                            ? CupertinoIcons.xmark_circle
                            : CupertinoIcons.checkmark_circle,
                        size: 15,
                      ),
                      label: Text(_isHistorySelectionMode ? 'Done' : 'Select'),
                      style: TextButton.styleFrom(
                        foregroundColor: SariwaColors.brandPrimary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w600,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  IconButton(
                    onPressed: () => controller.loadHistory(),
                    icon: const Icon(CupertinoIcons.refresh, size: 18),
                    tooltip: 'Refresh history from server',
                    color: SariwaColors.brandPrimary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEF2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: ['All', 'Fresh', 'Not Fresh'].map((filter) {
                final isSelected = _historyFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    key: Key(
                      'history_filter_${filter.toLowerCase().replaceAll(' ', '_')}',
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _historyFilter = filter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: isSelected
                                ? SariwaColors.textPrimaryDark
                                : const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isHistorySelectionMode && filtered.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              key: const Key('history_bulk_action_bar'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${_selectedHistoryScanIds.length} of ${filtered.length} selected',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: SariwaColors.textPrimaryDark,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        key: const Key('history_select_all_button'),
                        onPressed: () {
                          setState(() {
                            final validIds = filtered
                                .map((s) => s.scanId)
                                .whereType<int>()
                                .toSet();
                            if (_selectedHistoryScanIds.containsAll(validIds)) {
                              _selectedHistoryScanIds.removeAll(validIds);
                            } else {
                              _selectedHistoryScanIds.addAll(validIds);
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          foregroundColor: SariwaColors.brandPrimary,
                        ),
                        child: Text(
                          filtered.isNotEmpty &&
                                  _selectedHistoryScanIds.containsAll(
                                    filtered
                                        .map((s) => s.scanId)
                                        .whereType<int>()
                                        .toSet(),
                                  )
                              ? 'Deselect All'
                              : 'Select All',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        key: const Key('history_bulk_delete_button'),
                        onPressed: _selectedHistoryScanIds.isEmpty
                            ? null
                            : () {
                                _confirmBulkDelete(
                                  context,
                                  _selectedHistoryScanIds.toList(),
                                  controller,
                                );
                              },
                        icon: const Icon(CupertinoIcons.trash, size: 13),
                        label:
                            Text('Delete (${_selectedHistoryScanIds.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SariwaColors.statusSpoiled,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              SariwaColors.statusSpoiled.withValues(alpha: 0.35),
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (state.isLoadingHistory && state.history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CupertinoActivityIndicator(radius: 14),
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
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/SariwaBa logo.png',
            height: 56,
            errorBuilder: (_, _, _) => const Icon(
              CupertinoIcons.tray,
              size: 42,
              color: SariwaColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            emptyTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            emptySubtitle,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: AppTypography.defaultLetterSpacing,
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
    final isSelected =
        scan.scanId != null && _selectedHistoryScanIds.contains(scan.scanId);

    return GestureDetector(
      key: Key('history_item_${scan.scanId}'),
      onTap: _isHistorySelectionMode && scan.scanId != null
          ? () {
              setState(() {
                if (isSelected) {
                  _selectedHistoryScanIds.remove(scan.scanId);
                } else {
                  _selectedHistoryScanIds.add(scan.scanId!);
                }
              });
            }
          : null,
      onLongPress: !_isHistorySelectionMode && scan.scanId != null
          ? () {
              setState(() {
                _isHistorySelectionMode = true;
                _selectedHistoryScanIds.add(scan.scanId!);
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? SariwaColors.brandPrimary.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? SariwaColors.brandPrimary
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 0.9,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x050F172A),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isHistorySelectionMode) ...[
              GestureDetector(
                key: Key('history_item_checkbox_${scan.scanId}'),
                onTap: () {
                  if (scan.scanId != null) {
                    setState(() {
                      if (isSelected) {
                        _selectedHistoryScanIds.remove(scan.scanId);
                      } else {
                        _selectedHistoryScanIds.add(scan.scanId!);
                      }
                    });
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected ? SariwaColors.brandPrimary : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? SariwaColors.brandPrimary
                          : const Color(0xFFCBD5E1),
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            CupertinoIcons.checkmark,
                            size: 13,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                color: scan.statusColor.withValues(alpha: 0.12),
                child: scan.imageUrl != null && scan.imageUrl!.isNotEmpty
                    ? Image.network(
                        scan.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          scan.isFresh
                              ? CupertinoIcons.checkmark_alt
                              : CupertinoIcons.exclamationmark_triangle,
                          color: scan.statusColor,
                          size: 20,
                        ),
                      )
                    : Icon(
                        scan.isFresh
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.exclamationmark_triangle,
                        color: scan.statusColor,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              scan.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: scan.statusColor,
                              ),
                            ),
                            if (scan.regionDisplayName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  'Selected region: ${scan.regionDisplayName!}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing:
                                        AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.brandPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (scan.scanId != null && !_isHistorySelectionMode)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: isDeleting
                              ? const CupertinoActivityIndicator(radius: 8)
                              : const Icon(CupertinoIcons.trash, size: 16),
                          color: const Color(0xFF94A3B8),
                          tooltip: 'Delete scan',
                          onPressed: isDeleting
                              ? null
                              : () {
                                  _confirmDelete(
                                    context,
                                    scan.scanId!,
                                    controller,
                                  );
                                },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: scan.confidence.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(scan.statusColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          scan.createdAt != null
                              ? '${scan.createdAt!.month}/${scan.createdAt!.day}/${scan.createdAt!.year} at ${scan.createdAt!.hour}:${scan.createdAt!.minute.toString().padLeft(2, '0')}'
                              : 'Audit Scan #${scan.scanId ?? ''}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textSecondaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        scan.formattedConfidence,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: scan.statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
      builder: (dialogCtx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SariwaColors.statusSpoiled.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: SariwaColors.statusSpoiled,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Delete Scan Record?',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete Scan #$scanId from your history?',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: SariwaColors.textSecondaryDark,
              letterSpacing: AppTypography.defaultLetterSpacing,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: TextButton.styleFrom(
                foregroundColor: SariwaColors.textSecondaryDark,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                  color: SariwaColors.textSecondaryDark,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
            ElevatedButton(
              key: const Key('confirm_delete_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SariwaColors.statusSpoiled,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                setState(() {
                  _selectedHistoryScanIds.remove(scanId);
                });
                controller.deleteScan(scanId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBulkDelete(
    BuildContext context,
    List<int> scanIds,
    ClassificationController controller,
  ) {
    if (scanIds.isEmpty) return;
    final count = scanIds.length;
    showDialog(
      context: context,
      builder: (dialogCtx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SariwaColors.statusSpoiled.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: SariwaColors.statusSpoiled,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Delete Scan Record?'
                      : 'Delete $count Scan Records?',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            count == 1
                ? 'Are you sure you want to permanently delete Scan #${scanIds.first} from your history?'
                : 'Are you sure you want to permanently delete $count selected scans from your history?',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: SariwaColors.textSecondaryDark,
              letterSpacing: AppTypography.defaultLetterSpacing,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: TextButton.styleFrom(
                foregroundColor: SariwaColors.textSecondaryDark,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                  color: SariwaColors.textSecondaryDark,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
            ElevatedButton(
              key: const Key('confirm_bulk_delete_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SariwaColors.statusSpoiled,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                setState(() {
                  _selectedHistoryScanIds.clear();
                  _isHistorySelectionMode = false;
                });
                await controller.deleteMultipleScans(scanIds);
              },
              child: Text(
                count == 1 ? 'Delete' : 'Delete ($count)',
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
          ],
        ),
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

    return _buildFrostedGlassCard(
      key: Key(
        isError ? 'error_notification_banner' : 'success_notification_banner',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      borderRadius: 18,
      borderColor: color.withValues(alpha: 0.35),
      blurSigma: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isError
                    ? (state.isInputRejection
                        ? CupertinoIcons.exclamationmark_circle_fill
                        : CupertinoIcons.xmark_octagon_fill)
                    : CupertinoIcons.checkmark_circle_fill,
                color: color,
                size: 19,
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
                          letterSpacing: AppTypography.defaultLetterSpacing,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: const TextStyle(
                        color: SariwaColors.textPrimaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppTypography.defaultLetterSpacing,
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
                    onPressed: () {
                      controller.editCrop();
                      _showRoiCropperModal();
                    },
                    icon: const Icon(CupertinoIcons.crop, size: 14),
                    label: const Text('Edit Crop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SariwaColors.brandPrimary,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      backgroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  key: const Key('banner_replace_image_button'),
                  onPressed: () => controller.clearSelection(),
                  icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 14),
                  label: const Text('Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.statusSpoiled,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                if (state.isReadyToClassify)
                  ElevatedButton.icon(
                    key: const Key('banner_retry_button'),
                    onPressed: () => controller.classify(),
                    icon: const Icon(CupertinoIcons.refresh, size: 14),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SariwaColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
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
        '© ${DateTime.now().year} SariwaBa — Fish Freshness Classification. All rights reserved.',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: AppTypography.defaultLetterSpacing,
          color: SariwaColors.textMutedDark,
        ),
      ),
    );
  }
}
