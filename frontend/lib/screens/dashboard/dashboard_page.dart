import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/theme/app_colors.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/auth/user_model.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import 'sections/audit_history_section.dart';
import 'sections/freshness_trends_section.dart';
import 'sections/grade_breakdown_section.dart';
import 'sections/live_scanner_section.dart';
import 'sections/overview_section.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/dashboard_top_bar.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const Color _kMobileEmerald = Color(0xFF0F5338);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _activeSection = 'Dashboard';
  String _historyFilter = 'All';
  String _selectedTimeframe = 'Daily';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authControllerProvider).isAuthenticated) {
        ref.read(classificationControllerProvider.notifier).loadHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectSection(String section) {
    setState(() {
      _activeSection = section;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final classState = ref.watch(classificationControllerProvider);
    final classController = ref.read(classificationControllerProvider.notifier);
    final user = authState.user;
    final isGuest = authState.isGuest || user == null;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Geist'),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          textStyle: TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SariwaColors.textPrimaryDark,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 800.0;

          if (!isDesktop) {
            return _buildMobileScannerFirstLayout(
              user: user,
              isGuest: isGuest,
              authController: authController,
              classState: classState,
              classController: classController,
            );
          }

          // ---------------------------------------------------------------------
          // DESKTOP LAYOUT (>= 800.0px) — Preserved Hierarchy
          // ---------------------------------------------------------------------
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: SariwaColors.bgDashboard,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Left Persistent Sidebar (250px)
                SizedBox(
                  width: 250,
                  child: DashboardSidebar(
                    activeSection: _activeSection,
                    user: user,
                    isGuest: isGuest,
                    onSelectSection: _selectSection,
                    onQuickScan: () {
                      _selectSection('Live Scanner');
                      classController.pickImage(ImageSource.gallery);
                    },
                    onOpenDownloads: () => authController.goToDownloads(),
                    onOpenHome: () => authController.goToLanding(),
                    onSignIn: () => authController.goToLogin(),
                    onSignOut: () => authController.signOut(),
                  ),
                ),

                // 2. Main Desktop Workspace
                Expanded(
                  child: Column(
                    children: [
                      DashboardTopBar(
                        isDesktop: true,
                        activeSection: _activeSection,
                        user: user,
                        isGuest: isGuest,
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        onSearchChanged: (val) =>
                            setState(() => _searchQuery = val),
                        onClearSearch: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        onOpenDrawer: () {},
                        onSyncHistory: () => classController.loadHistory(),
                        onOpenHome: () => authController.goToLanding(),
                        onSignIn: () => authController.goToLogin(),
                        onSignOut: () => authController.signOut(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 20,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1240),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StaggeredReveal(
                                    staggerIndex: 0,
                                    child: DashboardGreetingHeader(
                                      user: user,
                                      isGuest: isGuest,
                                      selectedTimeframe: _selectedTimeframe,
                                      onTimeframeChanged: (val) => setState(
                                        () => _selectedTimeframe = val,
                                      ),
                                      onConnectGoogle: () =>
                                          authController.continueWithGoogle(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  if (classState.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child: _buildNotificationBanner(
                                        message: classState.errorMessage!,
                                        isError: true,
                                      ),
                                    ),
                                  if (classState.successMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child: _buildNotificationBanner(
                                        message: classState.successMessage!,
                                        isError: false,
                                      ),
                                    ),

                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    child: _buildActiveSectionContent(
                                      classState: classState,
                                      classController: classController,
                                      isGuest: isGuest,
                                      authController: authController,
                                    ),
                                  ),

                                  const SizedBox(height: 36),
                                  _buildSimpleFooter(),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE "SCANNER-FIRST" FIELD INSPECTION LAYOUT (< 800.0px)
  // ---------------------------------------------------------------------------
  Widget _buildMobileScannerFirstLayout({
    required UserModel? user,
    required bool isGuest,
    required AuthController authController,
    required ClassificationState classState,
    required ClassificationController classController,
  }) {
    final history = classState.history;
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final cautionCount = history.where((s) => s.isNotFresh).length;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 0.0;
    final freshRate = total > 0 ? (freshCount / total) * 100 : 0.0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: SariwaColors.bgDashboard,
        // 1. Compact AppBar (56px height)
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: SariwaColors.borderLightTeal,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Left: SariwaBa AI emerald logo icon + title & subtitle
                  Container(
                    width: 34,
                    height: 34,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _kMobileEmerald,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/SariwaBa logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.waves_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SariwaBa',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.3,
                            color: SariwaColors.textPrimaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Fish Freshness Scanner',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.15,
                            color: SariwaColors.textMutedDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Right: Date pill + User Avatar / Guest action
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.bgDashboard,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SariwaColors.borderLightTeal),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: _kMobileEmerald,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '23 Oct, 2026',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (user != null && !isGuest)
                    GestureDetector(
                      onTap: () => authController.signOut(),
                      child: DashboardUserAvatar(user: user, size: 32),
                    )
                  else
                    GestureDetector(
                      onTap: () => authController.goToLogin(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _kMobileEmerald.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 17,
                          color: _kMobileEmerald,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Scrollable Mobile Field Inspection Workspace
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Guest Mode Callout Banner when browsing as Guest
              if (isGuest) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: SariwaColors.brandPrimary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: _kMobileEmerald,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Guest Evaluation Mode',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: SariwaColors.textPrimaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'You are currently a guest. Log in to save your classification history.',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.15,
                          color: SariwaColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppButton.primary(
                        label: 'Connect with Google',
                        icon: SvgPicture.asset(
                          'assets/icons/google.svg',
                          width: 14,
                          height: 14,
                        ),
                        height: 34,
                        width: double.infinity,
                        borderRadius: 999,
                        onPressed: () => authController.continueWithGoogle(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (classState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotificationBanner(
                    message: classState.errorMessage!,
                    isError: true,
                  ),
                ),
              if (classState.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotificationBanner(
                    message: classState.successMessage!,
                    isError: false,
                  ),
                ),

              // 2. DOM/Widget Order #1 — Hero LiveScannerCard(isMobile: true)
              LiveScannerSection(
                state: classState,
                controller: classController,
                isMobile: true,
                isGuest: isGuest,
                onSignInToSave: () => authController.goToLogin(),
              ),
              const SizedBox(height: 14),

              // 3. Widget Order #2 — Condensed 2x2 KPI Bento Grid
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.55,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  NotchedKpiCard(
                    title: 'Total Inspections',
                    value: total.toString(),
                    trendText: 'Available',
                    comparisonText: 'vs last mo',
                    waveColor: SariwaColors.textPrimaryDark,
                    trendColor: SariwaColors.statusFresh,
                    points: const [0.42, 0.25, 0.58, 0.64, 0.32, 0.18, 0.72],
                    showSparkline: false,
                    isCompact: true,
                    onTap: () {},
                  ),
                  NotchedKpiCard(
                    title: 'Sariwa (Fresh)',
                    value: freshCount.toString(),
                    trendText: '${freshRate.toStringAsFixed(0)}%',
                    comparisonText: 'of scans',
                    waveColor: SariwaColors.statusFresh,
                    trendColor: SariwaColors.statusFresh,
                    points: const [0.22, 0.45, 0.30, 0.55, 0.38, 0.48, 0.85],
                    showSparkline: false,
                    isCompact: true,
                    onTap: () {},
                  ),
                  NotchedKpiCard(
                    title: 'Not Fresh',
                    value: cautionCount.toString(),
                    trendText: total > 0
                        ? '${((cautionCount / total) * 100).toStringAsFixed(0)}%'
                        : '0%',
                    comparisonText: 'of scans',
                    waveColor: SariwaColors.statusModerate,
                    trendColor: SariwaColors.statusModerate,
                    points: const [0.18, 0.48, 0.28, 0.32, 0.62, 0.44, 0.78],
                    showSparkline: false,
                    isCompact: true,
                    onTap: () {},
                  ),
                  NotchedKpiCard(
                    title: 'Avg. Confidence',
                    value: total == 0
                        ? '—'
                        : '${avgConfidence.toStringAsFixed(1)}%',
                    trendText: 'Model score',
                    comparisonText: 'not accuracy',
                    waveColor: SariwaColors.brandPrimary,
                    trendColor: SariwaColors.statusFresh,
                    points: const [0.25, 0.68, 0.74, 0.45, 0.20, 0.35, 0.82],
                    showSparkline: false,
                    isCompact: true,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Widget Order #3 — Tabbed Bottom Container (Audit History | Overview Trends)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SariwaColors.borderLightTeal),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SariwaColors.bgDashboard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: _kMobileEmerald,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: SariwaColors.textSecondaryDark,
                        labelStyle: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                        tabs: [
                          Tab(text: 'Audit History'),
                          Tab(text: 'Overview Trends'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 430,
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(8),
                            child: AuditHistorySection(
                              state: classState,
                              controller: classController,
                              historyFilter: _historyFilter,
                              onFilterChanged: (val) =>
                                  setState(() => _historyFilter = val),
                              searchQuery: _searchQuery,
                              isGuest: isGuest,
                              onSignIn: () => authController.goToLogin(),
                            ),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(8),
                            child: FreshnessTrendsSection(history: history),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 5. Floating Shutter Bottom Navigation
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: _kMobileEmerald,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          tooltip: 'Capture Fish Photo',
          onPressed: () => classController.pickImage(ImageSource.camera),
          child: const Icon(Icons.camera_alt_rounded, size: 26),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                },
                icon: const Icon(
                  Icons.document_scanner_outlined,
                  color: _kMobileEmerald,
                ),
                tooltip: 'Scanner',
              ),
              IconButton(
                onPressed: () => classController.pickImage(ImageSource.gallery),
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: SariwaColors.textSecondaryDark,
                ),
                tooltip: 'Gallery',
              ),
              const SizedBox(width: 40), // Space for center-docked shutter FAB
              IconButton(
                onPressed: () => authController.goToLanding(),
                icon: const Icon(
                  Icons.home_outlined,
                  color: SariwaColors.textSecondaryDark,
                ),
                tooltip: 'Home',
              ),
              IconButton(
                onPressed: () => isGuest
                    ? authController.goToLogin()
                    : authController.signOut(),
                icon: Icon(
                  isGuest ? Icons.login_rounded : Icons.logout_rounded,
                  color: SariwaColors.textSecondaryDark,
                ),
                tooltip: isGuest ? 'Sign in' : 'Sign out',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSectionContent({
    required ClassificationState classState,
    required ClassificationController classController,
    required bool isGuest,
    required AuthController authController,
  }) {
    switch (_activeSection) {
      case 'Live Scanner':
        return LiveScannerSection(
          key: const ValueKey('section_live_scanner'),
          state: classState,
          controller: classController,
          isMobile: false,
          isGuest: isGuest,
          onSignInToSave: () => authController.goToLogin(),
        );
      case 'Scan Logs':
        return AuditHistorySection(
          key: const ValueKey('section_scan_logs'),
          state: classState,
          controller: classController,
          historyFilter: _historyFilter,
          onFilterChanged: (val) => setState(() => _historyFilter = val),
          searchQuery: _searchQuery,
          isGuest: isGuest,
          onSignIn: () => authController.goToLogin(),
        );
      case 'Freshness Trends':
        return FreshnessTrendsSection(
          key: const ValueKey('section_freshness_trends'),
          history: classState.history,
        );
      case 'Classification Summary':
        return GradeBreakdownSection(
          key: const ValueKey('section_grade_breakdown'),
          history: classState.history,
        );
      case 'Dashboard':
      default:
        return OverviewSection(
          key: const ValueKey('section_overview'),
          classState: classState,
          classController: classController,
          historyFilter: _historyFilter,
          onFilterChanged: (val) => setState(() => _historyFilter = val),
          searchQuery: _searchQuery,
          isGuest: isGuest,
          onSignIn: () => authController.goToLogin(),
          onNavigateSection: _selectSection,
        );
    }
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
        style: const TextStyle(fontSize: 12, color: SariwaColors.textMutedDark),
      ),
    );
  }
}
