import '../../widgets/dashboard/dashboard_light_theme.dart';

import 'dart:async';
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
import '../../constants/config/platform_env.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../widgets/classification/roi_cropper_widget.dart';
import '../../widgets/common/media_permission_gate.dart';
import '../../widgets/common/sariwa_scrollbar.dart';
import '../../widgets/dashboard/dashboard_sidebar.dart';
import '../../widgets/dashboard/organoleptic_guidelines_dialog.dart';
import 'sections/admin_page_section.dart';
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
  final ScrollController _settingsScrollController = ScrollController();
  final ScrollController _secondaryScrollController = ScrollController();
  String _activeNav = 'Inspection'; // 'Inspection', 'History', 'Settings', 'Admin'
  int _slideDirection = 1; // +1 = slide in from right, -1 = slide in from left
  bool _isPushTransition = false; // true = full iOS Settings push/pop slide
  bool _isSidebarCollapsed = false;
  bool _isCropModalOpen = false;
  bool _isNavScrolling = false;
  bool _isNavIdle = false;
  bool _hasInputFocus = false;
  Timer? _navIdleTimer;
  BuildContext? _cropModalContext;

  int _navOrder(String nav) {
    if (nav == 'Inspection' || nav == 'Scanner') return 0;
    if (nav == 'History' || nav == 'Analytics' || nav == 'Summary') return 1;
    if (nav == 'Settings' || nav == 'Account') return 2;
    return 3; // Sub-pages pushed from Settings ('HowItWorks', 'Help', 'Admin')
  }

  void _wakeBottomNav() {
    _navIdleTimer?.cancel();
    if (_isNavScrolling || _isNavIdle) {
      setState(() {
        _isNavScrolling = false;
        _isNavIdle = false;
      });
    }
    _scheduleNavIdle();
  }

  void _scheduleNavIdle() {
    _navIdleTimer?.cancel();
    if (!mounted) return;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) return;
    _navIdleTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted && !_isNavIdle) {
        setState(() => _isNavIdle = true);
      }
    });
  }

  void _handleFocusManagerChange() {
    if (!mounted) return;
    final primary = FocusManager.instance.primaryFocus;
    final focusedWidget = primary?.context?.widget;
    final inputFocused =
        primary != null && primary.hasFocus && focusedWidget is EditableText;
    if (inputFocused != _hasInputFocus) {
      setState(() => _hasInputFocus = inputFocused);
      if (!inputFocused) {
        _wakeBottomNav();
      }
    }
  }

  bool _handleMobileScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0.0;
      final pixels = notification.metrics.pixels;
      if (delta > 1.2 && pixels > 12) {
        _navIdleTimer?.cancel();
        if (!_isNavScrolling) {
          setState(() => _isNavScrolling = true);
        }
      } else if (delta < -2.5 || pixels <= 8) {
        _wakeBottomNav();
      }
    } else if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels <= 8) {
        _wakeBottomNav();
      } else if (_isNavScrolling) {
        setState(() {
          _isNavScrolling = false;
          _isNavIdle = true;
        });
      }
    }
    return false;
  }

  void _navigateTo(String nextNav) {
    _wakeBottomNav();
    if (nextNav == _activeNav) return;
    final prevOrder = _navOrder(_activeNav);
    final nextOrder = _navOrder(nextNav);
    setState(() {
      _isPushTransition = prevOrder == 3 || nextOrder == 3;
      _slideDirection = nextOrder >= prevOrder ? 1 : -1;
      _activeNav = nextNav;
    });
  }

  Future<bool> _checkMobileMediaPermission(ImageSource source) async {
    final width = MediaQuery.sizeOf(context).width;
    if (!isNativeMobileDevice && !AppBreakpoints.isMobile(width)) {
      return true;
    }
    return MediaPermissionGate.ensureAllowed(context, source: source);
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handleFocusManagerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleNavIdle();
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
                  backgroundColor: SariwaColors.surfaceSlateTint,
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
    _navIdleTimer?.cancel();
    FocusManager.instance.removeListener(_handleFocusManagerChange);
    _inspectionScrollController.dispose();
    _historyScrollController.dispose();
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        msg,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF111111),
                elevation: 8,
                duration: const Duration(seconds: 3),
                width: AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width)
                    ? null
                    : 360,
                margin: AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width)
                    ? const EdgeInsets.fromLTRB(24, 0, 24, 24)
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: const StadiumBorder(),
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

    final isAdmin = user?.isAdmin == true;
    final viewportWidth = MediaQuery.of(context).size.width;
    final isMobileViewport = AppBreakpoints.isMobile(viewportWidth);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DashboardLightTheme(
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontFamily: 'Geist',
            letterSpacing: AppTypography.defaultLetterSpacing,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F5F7),
            extendBody: isMobileViewport,
            bottomNavigationBar: isMobileViewport
                ? _buildMobileBottomNav(
                    onQuickScan: () async {
                      HapticFeedback.mediumImpact();
                      final allowed = await _checkMobileMediaPermission(
                        ImageSource.camera,
                      );
                      if (!mounted || !allowed) return;
                      final picked = await classController.pickImage(
                        ImageSource.camera,
                      );
                      if (mounted && picked) {
                        _navigateTo('Inspection');
                      }
                    },
                    onQuickScanLongPress: () => _showQuickCaptureOptions(
                      classController,
                    ),
                  )
                : null,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);
                final isTablet = AppBreakpoints.isTablet(constraints.maxWidth);
                final isDesktop = AppBreakpoints.isDesktop(constraints.maxWidth);
                final railCollapsed = isTablet ? true : _isSidebarCollapsed;

                int? coreTabIndex;
                if (_activeNav == 'Inspection' || _activeNav == 'Scanner') {
                  coreTabIndex = 0;
                } else if (_activeNav == 'History' ||
                    _activeNav == 'Analytics' ||
                    _activeNav == 'Summary') {
                  coreTabIndex = 1;
                } else if (_activeNav == 'Settings' ||
                    _activeNav == 'Account') {
                  coreTabIndex = 2;
                } else if (_activeNav == 'Admin' && !isAdmin) {
                  coreTabIndex = 0;
                }

                Widget activeScreen;
                if (coreTabIndex == 0) {
                  activeScreen = SariwaScrollbar(
                    key: const ValueKey('tab_inspection'),
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
                      onViewMore: () => _navigateTo('History'),
                      onViewAnalytics: () => _navigateTo('History'),
                      onOpenSettings: () => _navigateTo('Settings'),
                      scrollController: controller,
                      onRequestPermission: (isNativeMobileDevice || isMobile)
                          ? _checkMobileMediaPermission
                          : null,
                    ),
                  );
                } else if (coreTabIndex == 1) {
                  activeScreen = SariwaScrollbar(
                    key: const ValueKey('tab_history'),
                    controller: _historyScrollController,
                    builder: (context, controller) => HistoryPageSection(
                      history: classState.history,
                      controller: classController,
                      isDesktop: isDesktop,
                      scrollController: controller,
                    ),
                  );
                } else if (coreTabIndex == 2) {
                  activeScreen = SariwaScrollbar(
                    key: const ValueKey('tab_settings'),
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
                      onOpenGuidelines: () =>
                          OrganolepticGuidelinesDialog.show(context),
                      onOpenHowItWorks: () => _navigateTo('HowItWorks'),
                      onOpenHelpFaq: () => _navigateTo('Help'),
                      onOpenAdmin:
                          isAdmin ? () => _navigateTo('Admin') : null,
                      onGoDownloads: () => authController.goToDownloads(),
                      onGoHome: () => authController.goToLanding(),
                    ),
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
                      onStartInspection: () => _navigateTo('Inspection'),
                    );
                  } else {
                    secondaryView = HelpFaqDashboardSection(
                      isDesktop: isDesktop,
                      scrollController: _secondaryScrollController,
                    );
                  }

                  activeScreen = SariwaScrollbar(
                    key: ValueKey('sub_$_activeNav'),
                    controller: _secondaryScrollController,
                    builder: (context, _) => secondaryView,
                  );
                }

                final disableAnimations =
                    MediaQuery.maybeOf(context)?.disableAnimations ?? false;
                final isPoppingSubpage =
                    _isPushTransition && _slideDirection < 0;

                final contentView = ClipRect(
                  child: AnimatedSwitcher(
                    duration: disableAnimations
                        ? Duration.zero
                        : Duration(
                            milliseconds: _isPushTransition ? 280 : 180,
                          ),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      if (isPoppingSubpage) {
                        // Keep exiting sub-page on top while it slides out to the right
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ?currentChild,
                            ...previousChildren,
                          ],
                        );
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ...previousChildren,
                          ?currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final isEntering = child.key == activeScreen.key;
                      if (_isPushTransition) {
                        if (isEntering) {
                          // Pushing sub-page: slides in from +1.0 -> 0.0 on top
                          // Popping to Settings: slides in from -0.28 -> 0.0 underneath
                          final beginX = _slideDirection > 0 ? 1.0 : -0.28;
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(beginX, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: _slideDirection > 0
                                ? ColoredBox(
                                    color: SariwaColors.surfaceSlateTint,
                                    child: child,
                                  )
                                : child,
                          );
                        } else {
                          // Note: for exiting widgets, AnimatedSwitcher runs animation 1.0 -> 0.0
                          // Pushing sub-page: Settings shifts 0.0 -> -0.28 underneath
                          // Popping sub-page: Sub-page slides 0.0 -> +1.0 off to the right on top
                          final endExitX = _slideDirection > 0 ? -0.28 : 1.0;
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(endExitX, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: _slideDirection < 0
                                ? ColoredBox(
                                    color: SariwaColors.surfaceSlateTint,
                                    child: child,
                                  )
                                : child,
                          );
                        }
                      }

                      // Peer tabs (Inspect <-> History <-> Settings):
                      // Quick exit + subtle 2.5% glide so tabs never double-expose or ghost.
                      if (isEntering) {
                        final fadeIn = CurvedAnimation(
                          parent: animation,
                          curve: const Interval(
                            0.15,
                            1.0,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(_slideDirection * 0.025, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: fadeIn,
                            child: child,
                          ),
                        );
                      } else {
                        // Exiting animation runs 1.0 -> 0.0; fade out cleanly in first 35%
                        final fadeOut = CurvedAnimation(
                          parent: animation,
                          curve: const Interval(
                            0.65,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        );
                        return FadeTransition(
                          opacity: fadeOut,
                          child: child,
                        );
                      }
                    },
                    child: activeScreen,
                  ),
                );

                // Tablet (NavigationRail-style collapsed sidebar) & Desktop/Web (full sidebar)
                if (!isMobile) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOutCubic,
                        width: railCollapsed ? 76 : 264,
                        child: DashboardSidebar(
                          user: user,
                          isGuestUser: isGuestUser,
                          historyCount: classState.history.length,
                          activeNav: _activeNav,
                          isCollapsed: railCollapsed,
                          onToggleCollapse: isTablet
                              ? null
                              : () => setState(
                                    () => _isSidebarCollapsed =
                                        !_isSidebarCollapsed,
                                  ),
                          onNavSelected: (nav) {
                            if (nav == 'Admin' && !isAdmin) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Administrator privileges required.',
                                  ),
                                  backgroundColor: SariwaColors.statusSpoiled,
                                ),
                              );
                              return;
                            }
                            _navigateTo(nav);
                          },
                          onSignOut: () => authController.signOut(),
                          onSignIn: () => authController.goToLogin(),
                          onGoHome: () => authController.goToLanding(),
                          onGoDownloads: () => authController.goToDownloads(),
                          onConnectGoogle: () =>
                              authController.continueWithGoogle(),
                          onOpenGuidelines: () =>
                              OrganolepticGuidelinesDialog.show(context),
                        ),
                      ),
                      Expanded(child: contentView),
                    ],
                  );
                }

                // Mobile: no top bar on primary tabs; iOS 26 swipe-back + glass Back pill on sub-pages
                final isSecondaryPage = coreTabIndex == null;
                return GestureDetector(
                  onHorizontalDragEnd: isSecondaryPage
                      ? (details) {
                          if ((details.primaryVelocity ?? 0) > 280) {
                            HapticFeedback.selectionClick();
                            _navigateTo('Settings');
                          }
                        }
                      : null,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SafeArea(
                          bottom: false,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: _handleMobileScrollNotification,
                            child: contentView,
                          ),
                        ),
                      ),
                      if (isSecondaryPage)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: _buildFloatingGlassBackPill(
                                label: 'Settings',
                                onPressed: () => _navigateTo('Settings'),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingGlassBackPill({
    required String label,
    required VoidCallback onPressed,
  }) {
    final pill = Material(
      color: SariwaColors.cardSurfaceLight.withValues(
        alpha: kIsWeb ? 0.90 : 0.84,
      ),
      shape: const StadiumBorder(
        side: BorderSide(color: SariwaColors.colorLine, width: 1.0),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.chevron_left,
                size: 16,
                color: SariwaColors.brandPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: SariwaColors.shadowSubtle,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: pill,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                fontWeight: FontWeight.w500,
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
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                final allowed =
                    await _checkMobileMediaPermission(ImageSource.camera);
                if (!mounted || !allowed) return;
                final picked =
                    await classController.pickImage(ImageSource.camera);
                if (mounted && picked) {
                  _navigateTo('Inspection');
                }
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.photo_on_rectangle,
                color: SariwaColors.brandPrimary,
              ),
              title: const Text('Upload from Gallery'),
              subtitle: const Text('Select one or multiple photos'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                final allowed =
                    await _checkMobileMediaPermission(ImageSource.gallery);
                if (!mounted || !allowed) return;
                _navigateTo('Inspection');
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (cropBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Model confidence: ${result.formattedConfidence}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
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
                    borderRadius: BorderRadius.circular(999),
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
                      fontSize: 12,
                      height: 1.35,
                      color: SariwaColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    controller.editCrop();
                    _showRoiCropperModal();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.textPrimaryDark,
                    side: const BorderSide(color: SariwaColors.lineSlate),
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
    required VoidCallback onQuickScan,
    required VoidCallback onQuickScanLongPress,
  }) {
    int activeIndex = 0;
    if (_activeNav == 'History' ||
        _activeNav == 'Analytics' ||
        _activeNav == 'Summary') {
      activeIndex = 1;
    } else if (_activeNav == 'Settings' ||
        _activeNav == 'Account' ||
        _activeNav == 'Admin' ||
        _activeNav == 'HowItWorks' ||
        _activeNav == 'How It Works' ||
        _activeNav == 'Help' ||
        _activeNav == 'FAQs') {
      activeIndex = 2;
    }

    final alignments = [
      Alignment.centerLeft,
      Alignment.center,
      Alignment.centerRight,
    ];

    Widget buildPillTab({
      required int index,
      required String navKey,
      required String label,
      required IconData icon,
      required IconData activeIcon,
    }) {
      final isSelected = activeIndex == index;
      final color =
          isSelected ? const Color(0xFF111111) : const Color(0xFF737373);

      return Expanded(
        child: Semantics(
          button: true,
          selected: isSelected,
          label: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _navigateTo(navKey);
              },
              borderRadius: BorderRadius.circular(999),
              splashColor: SariwaColors.brandPrimary.withValues(alpha: 0.08),
              highlightColor: SariwaColors.brandPrimary.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        letterSpacing: -0.1,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final navPillInner = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight.withValues(
          alpha: kIsWeb ? 0.90 : 0.84,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: SariwaColors.colorLine,
          width: 1.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Smoothly sliding iOS-style frosted active capsule
              Positioned.fill(
                child: AnimatedAlign(
                  alignment: alignments[activeIndex],
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: tabWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  buildPillTab(
                    index: 0,
                    navKey: 'Inspection',
                    label: 'Inspect',
                    icon: CupertinoIcons.viewfinder,
                    activeIcon: CupertinoIcons.viewfinder_circle_fill,
                  ),
                  buildPillTab(
                    index: 1,
                    navKey: 'History',
                    label: 'History',
                    icon: CupertinoIcons.clock,
                    activeIcon: CupertinoIcons.clock_fill,
                  ),
                  buildPillTab(
                    index: 2,
                    navKey: 'Settings',
                    label: 'Settings',
                    icon: CupertinoIcons.settings,
                    activeIcon: CupertinoIcons.settings_solid,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final navPill = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: SariwaColors.shadowSubtle,
            blurRadius: 20,
            offset: Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: navPillInner,
        ),
      ),
    );

    final detachedCameraFab = Semantics(
      button: true,
      label: 'Quick freshness scan',
      child: Tooltip(
        message: 'Quick Scan (hold for gallery)',
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 16,
                offset: Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: const Color(0xFF111111),
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1.0,
              ),
            ),
            child: InkWell(
              key: const Key('mobile_quick_scan_button'),
              onTap: onQuickScan,
              onLongPress: onQuickScanLongPress,
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(
                  CupertinoIcons.camera_fill,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isShrunkStrong = _isNavScrolling || _hasInputFocus || keyboardOpen;
    final isShrunkMild = !isShrunkStrong && _isNavIdle;

    final double targetScale = disableAnimations
        ? 1.0
        : (isShrunkStrong ? 0.86 : (isShrunkMild ? 0.92 : 1.0));
    final Offset targetOffset = disableAnimations
        ? Offset.zero
        : (isShrunkStrong
            ? const Offset(0, 0.14)
            : (isShrunkMild ? const Offset(0, 0.06) : Offset.zero));
    final double targetOpacity = disableAnimations
        ? 1.0
        : (isShrunkStrong ? 0.80 : (isShrunkMild ? 0.88 : 1.0));

    return SafeArea(
      top: false,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _wakeBottomNav(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AnimatedSlide(
            offset: targetOffset,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: AnimatedScale(
              scale: targetScale,
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: targetOpacity,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: navPill),
                    const SizedBox(width: 12),
                    detachedCameraFab,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
