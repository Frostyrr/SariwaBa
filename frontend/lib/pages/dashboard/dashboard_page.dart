import '../../widgets/dashboard/dashboard_light_theme.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../controllers/classification/classification_controller.dart';

import '../../constants/theme/app_typography.dart';
import '../../widgets/classification/roi_cropper_widget.dart';
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
  final ScrollController _scrollController = ScrollController();
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

    return DashboardLightTheme(
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: 'Geist',
          letterSpacing: AppTypography.defaultLetterSpacing,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          drawer: MediaQuery.of(context).size.width >= 900
              ? null
              : Drawer(child: sidebar),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              Widget activeView;
              if (_activeNav == 'Admin') {
                if (user?.isAdmin != true) {
                  activeView = InspectionWorkspaceSection(
                    user: user,
                    isGuestUser: isGuestUser,
                    isDesktop: isDesktop,
                    isModalEffectivelyOpen: isModalEffectivelyOpen,
                    classState: classState,
                    classController: classController,
                    onConnectGoogle: () => authController.continueWithGoogle(),
                    onBackHome: () => authController.goToLanding(),
                    onOpenCropModal: _showRoiCropperModal,
                    onViewMore: () => setState(() => _activeNav = 'History'),
                    scrollController: _scrollController,
                  );
                } else {
                  activeView = AdminPageSection(
                    isDesktop: isDesktop,
                    scrollController: _scrollController,
                  );
                }
              } else if (_activeNav == 'History') {
                activeView = HistoryPageSection(
                  history: classState.history,
                  controller: classController,
                  isDesktop: isDesktop,
                  scrollController: _scrollController,
                );
              } else if (_activeNav == 'Analytics' || _activeNav == 'Summary') {
                activeView = AnalyticsPageSection(
                  history: classState.history,
                  isDesktop: isDesktop,
                  scrollController: _scrollController,
                );
              } else if (_activeNav == 'Settings' || _activeNav == 'Account') {
                activeView = AccountSettingsPageSection(
                  user: user,
                  isGuestUser: isGuestUser,
                  isDesktop: isDesktop,
                  scrollController: _scrollController,
                  authController: authController,
                  classificationController: classController,
                  onSignIn: () => authController.goToLogin(),
                );
              } else if (_activeNav == 'HowItWorks' ||
                  _activeNav == 'How It Works') {
                activeView = HowItWorksDashboardSection(
                  isDesktop: isDesktop,
                  scrollController: _scrollController,
                  onStartInspection: () =>
                      setState(() => _activeNav = 'Inspection'),
                );
              } else if (_activeNav == 'Help' ||
                  _activeNav == 'FAQs' ||
                  _activeNav == 'Help & FAQs') {
                activeView = HelpFaqDashboardSection(
                  isDesktop: isDesktop,
                  scrollController: _scrollController,
                );
              } else {
                activeView = InspectionWorkspaceSection(
                  user: user,
                  isGuestUser: isGuestUser,
                  isDesktop: isDesktop,
                  isModalEffectivelyOpen: isModalEffectivelyOpen,
                  classState: classState,
                  classController: classController,
                  onConnectGoogle: () => authController.continueWithGoogle(),
                  onBackHome: () => authController.goToLanding(),
                  onOpenCropModal: _showRoiCropperModal,
                  onViewMore: () => setState(() => _activeNav = 'History'),
                  scrollController: _scrollController,
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
                    Expanded(child: activeView),
                  ],
                );
              }

              return Column(
                children: [
                  DashboardMobileTopBar(
                    user: user,
                    isGuestUser: isGuestUser,
                    activeNav: _activeNav,
                    onNavSelected: (nav) => setState(() => _activeNav = nav),
                    onGoHome: () => authController.goToLanding(),
                    onSignOut: () => authController.signOut(),
                    onSignIn: () => authController.goToLogin(),
                    onSyncHistory: () => classController.loadHistory(),
                    onOpenDrawer: () => Scaffold.of(context).openDrawer(),
                  ),
                  Expanded(child: activeView),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
