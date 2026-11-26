import '../../widgets/dashboard/dashboard_light_theme.dart';

import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../controllers/classification/classification_controller.dart';

import '../../constants/config/app_breakpoints.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../widgets/classification/roi_cropper_widget.dart';
import '../../widgets/common/sariwa_scrollbar.dart';
import '../../widgets/dashboard/dashboard_mobile_top_bar.dart';
import '../../widgets/dashboard/dashboard_sidebar.dart';
import '../../widgets/dashboard/organoleptic_guidelines_dialog.dart';
import 'sections/admin_page_section.dart';
import 'sections/analytics_page_section.dart';
import 'sections/account_settings_page_section.dart';
import 'sections/help_faq_dashboard_section.dart';
import 'sections/history_page_section.dart';
import 'sections/how_it_works_dashboard_section.dart';
import 'sections/inspection_workspace_section.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final ScrollController _inspectionScrollController = ScrollController();
  final ScrollController _historyScrollController = ScrollController();
  final ScrollController _analyticsScrollController = ScrollController();
  final ScrollController _settingsScrollController = ScrollController();
  final ScrollController _secondaryScrollController = ScrollController();
  String _activeNav = 'Inspection'; // 'Inspection', 'History', 'Analytics'
  bool _isSidebarCollapsed = false;
  bool _isCropModalOpen = false;
  BuildContext? _cropModalContext;
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
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);

    final Future<void> modalFuture;
    if (isMobile) {
      modalFuture = Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (modalContext) {
            _cropModalContext = modalContext;
            return DashboardLightTheme(
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.dark,
                child: Scaffold(
                  key: const Key('roi_cropper_modal'),
                  backgroundColor: const Color(0xFFF8FAFC),
                  body: SafeArea(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final modalState =
                            ref.watch(classificationControllerProvider);
                        final modalController = ref.read(
                          classificationControllerProvider.notifier,
                        );

                        if (!_isCropModalOpen || !modalState.hasSelectedImage) {
                          return const SizedBox.shrink();
                        }

                        return RoiCropperWidget(
                          state: modalState,
                          controller: modalController,
                          isModal: true,
                          onCloseModal: _closeRoiCropperModal,
                          onOpenModal: _showRoiCropperModal,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      modalFuture = showDialog<void>(
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
                final modalController = ref.read(
                  classificationControllerProvider.notifier,
                );

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
      );
    }

    modalFuture.whenComplete(() {
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
    _inspectionScrollController.dispose();
    _historyScrollController.dispose();
    _analyticsScrollController.dispose();
    _settingsScrollController.dispose();
    _secondaryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final classState = ref.watch(classificationControllerProvider);
    final classController = ref.read(classificationControllerProvider.notifier);
    final user = authState.user;
    final isGuestUser = authState.isGuest || user == null || user.isGuest;

    ref.listen<ClassificationState>(classificationControllerProvider, (
      previous,
      next,
    ) {
      if (!next.hasSelectedImage && _isCropModalOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _closeRoiCropperModal();
          }
        });
      }

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        final msg = next.successMessage!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: Color(0xFF6EE7B7),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        msg,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF0A2229),
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          ref.read(classificationControllerProvider.notifier).clearNotification();
        });
      }

      if (next.latestResult != null &&
          next.latestResult != previous?.latestResult &&
          !_isCropModalOpen) {
        final result = next.latestResult!;
        final cropBytes = next.confirmedImageBytes ?? next.selectedImageBytes;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (AppBreakpoints.isMobile(MediaQuery.of(context).size.width)) {
            _showMobileVerdictSheet(
              result: result,
              cropBytes: cropBytes,
              controller: ref.read(classificationControllerProvider.notifier),
            );
          }
        });
      }
    });

    final isModalEffectivelyOpen =
        _isCropModalOpen && classState.hasSelectedImage;

    Widget buildSidebar({required bool inDrawer}) {
      return DashboardSidebar(
        user: user,
        isGuestUser: isGuestUser,
        historyCount: classState.history.length,
        activeNav: _activeNav,
        isCollapsed: inDrawer ? false : _isSidebarCollapsed,
        onToggleCollapse: inDrawer
            ? () => Navigator.of(context).pop()
            : () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
        onNavSelected: (nav) {
          if (inDrawer) {
            Navigator.of(context).pop();
          }
          if (nav == 'Admin' && user?.isAdmin != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Administrator privileges required.'),
                backgroundColor: Color(0xFFEF4444),
              ),
            );
            return;
          }
          setState(() => _activeNav = nav);
        },
        onSignOut: () {
          if (inDrawer) Navigator.of(context).pop();
          authController.signOut();
        },
        onSignIn: () {
          if (inDrawer) Navigator.of(context).pop();
          authController.goToLogin();
        },
        onGoHome: () {
          if (inDrawer) Navigator.of(context).pop();
          authController.goToLanding();
        },
        onGoDownloads: () {
          if (inDrawer) Navigator.of(context).pop();
          authController.goToDownloads();
        },
        onConnectGoogle: () {
          if (inDrawer) Navigator.of(context).pop();
          authController.continueWithGoogle();
        },
        onOpenGuidelines: () {
          if (inDrawer) Navigator.of(context).pop();
          OrganolepticGuidelinesDialog.show(context);
        },
      );
    }

    final isAdmin = user?.isAdmin == true;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DashboardLightTheme(
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontFamily: 'Geist',
            letterSpacing: AppTypography.defaultLetterSpacing,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            drawer: AppBreakpoints.isDesktop(MediaQuery.of(context).size.width)
                ? null
                : Drawer(child: buildSidebar(inDrawer: true)),
            bottomNavigationBar:
                AppBreakpoints.isDesktop(MediaQuery.of(context).size.width)
                    ? null
                    : _buildMobileBottomNav(
                        isAdmin: isAdmin,
                        onQuickScan: () async {
                          HapticFeedback.mediumImpact();
                          final picked = await classController.pickImage(
                            ImageSource.camera,
                          );
                          if (mounted && picked) {
                            setState(() => _activeNav = 'Inspection');
                          }
                        },
                        onQuickScanLongPress: () => _showQuickCaptureOptions(
                          classController,
                        ),
                      ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = AppBreakpoints.isDesktop(constraints.maxWidth);

                int? coreTabIndex;
                if (_activeNav == 'Inspection' || _activeNav == 'Scanner') {
                  coreTabIndex = 0;
                } else if (_activeNav == 'History') {
                  coreTabIndex = 1;
                } else if (_activeNav == 'Analytics' ||
                    _activeNav == 'Summary') {
                  coreTabIndex = 2;
                } else if (_activeNav == 'Settings' ||
                    _activeNav == 'Account') {
                  coreTabIndex = 3;
                } else if (_activeNav == 'Admin' && !isAdmin) {
                  coreTabIndex = 0;
                }

                Widget contentView;
                if (coreTabIndex != null) {
                  contentView = IndexedStack(
                    index: coreTabIndex,
                    children: [
                      SariwaScrollbar(
                        controller: _inspectionScrollController,
                        builder: (context, controller) =>
                            InspectionWorkspaceSection(
                          user: user,
                          isGuestUser: isGuestUser,
                          isDesktop: isDesktop,
                          isModalEffectivelyOpen: isModalEffectivelyOpen,
                          classState: classState,
                          classController: classController,
                          onConnectGoogle: () =>
                              authController.continueWithGoogle(),
                          onBackHome: () => authController.goToLanding(),
                          onOpenCropModal: _showRoiCropperModal,
                          onViewMore: () =>
                              setState(() => _activeNav = 'History'),
                          onViewAnalytics: () =>
                              setState(() => _activeNav = 'Analytics'),
                          scrollController: controller,
                        ),
                      ),
                      SariwaScrollbar(
                        controller: _historyScrollController,
                        builder: (context, controller) => HistoryPageSection(
                          history: classState.history,
                          controller: classController,
                          isDesktop: isDesktop,
                          scrollController: controller,
                        ),
                      ),
                      SariwaScrollbar(
                        controller: _analyticsScrollController,
                        builder: (context, controller) => AnalyticsPageSection(
                          history: classState.history,
                          isDesktop: isDesktop,
                          scrollController: controller,
                        ),
                      ),
                      SariwaScrollbar(
                        controller: _settingsScrollController,
                        builder: (context, controller) =>
                            AccountSettingsPageSection(
                          user: user,
                          isGuestUser: isGuestUser,
                          isDesktop: isDesktop,
                          scrollController: controller,
                          authController: authController,
                          classificationController: classController,
                          onSignIn: () => authController.goToLogin(),
                        ),
                      ),
                    ],
                  );
                } else {
                  Widget secondaryView;
                  if (_activeNav == 'Admin' && isAdmin) {
                    secondaryView = AdminPageSection(
                      isDesktop: isDesktop,
                      scrollController: _secondaryScrollController,
                    );
                  } else if (_activeNav == 'HowItWorks' ||
                      _activeNav == 'How It Works') {
                    secondaryView = HowItWorksDashboardSection(
                      isDesktop: isDesktop,
                      scrollController: _secondaryScrollController,
                      onStartInspection: () =>
                          setState(() => _activeNav = 'Inspection'),
                    );
                  } else {
                    secondaryView = HelpFaqDashboardSection(
                      isDesktop: isDesktop,
                      scrollController: _secondaryScrollController,
                    );
                  }

                  contentView = SariwaScrollbar(
                    controller: _secondaryScrollController,
                    builder: (context, _) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      child: KeyedSubtree(
                        key: ValueKey(_activeNav),
                        child: secondaryView,
                      ),
                    ),
                  );
                }

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeInOutCubic,
                        width: _isSidebarCollapsed ? 76 : 264,
                        child: buildSidebar(inDrawer: false),
                      ),
                      Expanded(child: contentView),
                    ],
                  );
                }

                return Column(
                  children: [
                    DashboardMobileTopBar(
                      user: user,
                      isGuestUser: isGuestUser,
                      activeNav: _activeNav,
                      showTopTabs: false,
                      onNavSelected: (nav) => setState(() => _activeNav = nav),
                      onGoHome: () => authController.goToLanding(),
                      onSignOut: () => authController.signOut(),
                      onSignIn: () => authController.goToLogin(),
                      onSyncHistory: () => classController.loadHistory(),
                      onOpenDrawer: () => Scaffold.of(context).openDrawer(),
                    ),
                    Expanded(child: contentView),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickCaptureOptions(
    ClassificationController classController,
  ) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'New Freshness Scan',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: SariwaColors.brandPrimary,
              ),
              title: const Text('Take a Photo'),
              subtitle: const Text('Open device camera for immediate capture'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                final picked =
                    await classController.pickImage(ImageSource.camera);
                if (mounted && picked) {
                  setState(() => _activeNav = 'Inspection');
                }
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.photo_on_rectangle,
                color: SariwaColors.brandPrimary,
              ),
              title: const Text('Upload from Gallery'),
              subtitle: const Text('Select one or multiple Tilapia photos'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                setState(() => _activeNav = 'Inspection');
                await classController.pickBatch();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMobileVerdictSheet({
    required dynamic result,
    required Uint8List? cropBytes,
    required ClassificationController controller,
  }) async {
    final isFresh = result.isFresh == true;
    final primaryColor =
        isFresh ? SariwaColors.statusFresh : SariwaColors.notFreshPrimary;
    final bgColor =
        isFresh ? SariwaColors.freshIconBg : SariwaColors.notFreshIconBg;
    final borderColor =
        isFresh ? SariwaColors.freshBorder : SariwaColors.notFreshBorder;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (cropBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            cropBytes,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.label as String,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Model confidence: ${result.formattedConfidence}',
                              style: const TextStyle(
                                fontSize: 13.5,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (result.confidence as double).clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Model confidence reflects the classifier prediction score, not a freshness percentage or food-safety guarantee.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: SariwaColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      controller.clearSelection();
                    },
                    icon: const Icon(Icons.camera_alt_rounded, size: 17),
                    label: const Text('Scan Another'),
                    style: FilledButton.styleFrom(
                      backgroundColor: SariwaColors.brandPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    controller.editCrop();
                    _showRoiCropperModal();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.textPrimaryDark,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Adjust crop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomNav({
    required bool isAdmin,
    required VoidCallback onQuickScan,
    required VoidCallback onQuickScanLongPress,
  }) {
    Widget buildTabItem({
      required String navKey,
      required String label,
      required IconData icon,
      required IconData activeIcon,
    }) {
      final isSelected = _activeNav == navKey ||
          (navKey == 'Inspection' && _activeNav == 'Scanner') ||
          (navKey == 'Analytics' && _activeNav == 'Summary') ||
          (navKey == 'Settings' && _activeNav == 'Account');

      final color =
          isSelected ? SariwaColors.brandPrimary : const Color(0xFF64748B);

      return Expanded(
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _activeNav = navKey);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isSelected ? activeIcon : icon, size: 22, color: color),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.1,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final navBar = Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: kIsWeb ? 0.96 : 0.86),
        border: Border(
          top: BorderSide(
            color: SariwaColors.borderLightTeal.withValues(alpha: 0.85),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTabItem(
                    navKey: 'Inspection',
                    label: 'Inspect',
                    icon: CupertinoIcons.viewfinder,
                    activeIcon: CupertinoIcons.viewfinder,
                  ),
                  buildTabItem(
                    navKey: 'History',
                    label: 'History',
                    icon: CupertinoIcons.clock,
                    activeIcon: CupertinoIcons.clock_fill,
                  ),
                  // Center Quick Classify / Camera Scan Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      key: const Key('mobile_quick_scan_button'),
                      onTap: onQuickScan,
                      onLongPress: onQuickScanLongPress,
                      child: Container(
                        width: 52,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              SariwaColors.brandGlow,
                              SariwaColors.brandPrimary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: SariwaColors.brandPrimary.withValues(
                                alpha: 0.30,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  buildTabItem(
                    navKey: 'Analytics',
                    label: 'Analytics',
                    icon: CupertinoIcons.chart_bar,
                    activeIcon: CupertinoIcons.chart_bar_fill,
                  ),
                  if (isAdmin)
                    buildTabItem(
                      navKey: 'Admin',
                      label: 'Admin',
                      icon: CupertinoIcons.shield,
                      activeIcon: CupertinoIcons.shield_fill,
                    )
                  else
                    buildTabItem(
                      navKey: 'Settings',
                      label: 'Settings',
                      icon: CupertinoIcons.gear,
                      activeIcon: CupertinoIcons.gear_solid,
                    ),
                ],
              ),
            ),
          ),
        );

    if (kIsWeb) return navBar;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: navBar,
      ),
    );
  }
}
