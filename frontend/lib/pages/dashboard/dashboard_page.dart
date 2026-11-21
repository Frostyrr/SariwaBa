import '../../widgets/dashboard/dashboard_light_theme.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final isNewUnconfirmedImage =
          next.hasSelectedImage &&
          !next.isCropConfirmed &&
          previous?.selectedImageBytes != next.selectedImageBytes;
      final isReopenedCropEditor =
          next.hasSelectedImage &&
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

    final isModalEffectivelyOpen =
        _isCropModalOpen && classState.hasSelectedImage;

    final sidebar = DashboardSidebar(
      user: user,
      isGuestUser: isGuestUser,
      historyCount: classState.history.length,
      activeNav: _activeNav,
      isCollapsed: _isSidebarCollapsed,
      onToggleCollapse: () =>
          setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
      onNavSelected: (nav) {
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
      onSignOut: () => authController.signOut(),
      onSignIn: () => authController.goToLogin(),
      onGoHome: () => authController.goToLanding(),
      onGoDownloads: () => authController.goToDownloads(),
      onConnectGoogle: () => authController.continueWithGoogle(),
      onOpenGuidelines: () => OrganolepticGuidelinesDialog.show(context),
    );

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
                : Drawer(child: sidebar),
            bottomNavigationBar:
                AppBreakpoints.isDesktop(MediaQuery.of(context).size.width)
                    ? null
                    : _buildMobileBottomNav(isAdmin: isAdmin),
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
                    builder: (context, _) => secondaryView,
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
                        child: sidebar,
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

  Widget _buildMobileBottomNav({required bool isAdmin}) {
    final tabs = <String>[
      'Inspection',
      'History',
      'Analytics',
      'Settings',
      if (isAdmin) 'Admin',
    ];
    final currentIndex = tabs.indexOf(_activeNav);

    return NavigationBar(
      selectedIndex: currentIndex >= 0 ? currentIndex : 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: SariwaColors.brandPrimary.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        HapticFeedback.selectionClick();
        setState(() => _activeNav = tabs[index]);
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.document_scanner_outlined),
          selectedIcon: Icon(
            Icons.document_scanner_rounded,
            color: SariwaColors.brandPrimary,
          ),
          label: 'Inspect',
        ),
        const NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(
            Icons.history_rounded,
            color: SariwaColors.brandPrimary,
          ),
          label: 'History',
        ),
        const NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(
            Icons.analytics_rounded,
            color: SariwaColors.brandPrimary,
          ),
          label: 'Analytics',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(
            Icons.settings_rounded,
            color: SariwaColors.brandPrimary,
          ),
          label: 'Settings',
        ),
        if (isAdmin)
          const NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(
              Icons.admin_panel_settings_rounded,
              color: SariwaColors.brandPrimary,
            ),
            label: 'Admin',
          ),
      ],
    );
  }
}
