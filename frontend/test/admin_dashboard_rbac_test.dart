import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/admin/admin_controller.dart';
import 'package:frontend/models/admin/admin_audit_model.dart';
import 'package:frontend/models/admin/admin_health_model.dart';
import 'package:frontend/models/admin/admin_security_model.dart';
import 'package:frontend/models/admin/admin_telemetry_model.dart';
import 'package:frontend/models/admin/admin_user_model.dart';
import 'package:frontend/models/auth/user_model.dart';
import 'package:frontend/pages/dashboard/sections/admin_page_section.dart';
import 'package:frontend/services/admin/admin_service.dart';
import 'package:frontend/widgets/dashboard/dashboard_mobile_top_bar.dart';
import 'package:frontend/widgets/dashboard/dashboard_sidebar.dart';

void main() {
  const normalUser = UserModel(
    id: '1',
    email: 'inspector@sariwaba.ph',
    firstName: 'Juan',
    lastName: 'Dela Cruz',
    role: 'user',
    isAdmin: false,
  );

  const adminUser = UserModel(
    id: '2',
    email: 'admin@sariwaba.ph',
    firstName: 'Maria',
    lastName: 'Santos',
    role: 'admin',
    isAdmin: true,
  );

  group('Dashboard RBAC Navigation Visibility Tests', () {
    testWidgets('DashboardSidebar hides Administration for non-admin user', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSidebar(
              user: normalUser,
              isGuestUser: false,
              historyCount: 5,
              activeNav: 'Inspection',
              onNavSelected: (_) {},
              onSignOut: () {},
              onSignIn: () {},
              onGoHome: () {},
              onGoDownloads: () {},
              onConnectGoogle: () {},
              onOpenGuidelines: () {},
            ),
          ),
        ),
      );

      // Workspace items should be present
      expect(find.text('WORKSPACE'), findsOneWidget);
      expect(find.text('Inspection'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);

      // Administration item must NOT be present
      expect(find.text('ADMINISTRATION'), findsNothing);
      expect(find.text('Admin Console'), findsNothing);
    });

    testWidgets('DashboardSidebar displays Administration for admin user', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSidebar(
              user: adminUser,
              isGuestUser: false,
              historyCount: 12,
              activeNav: 'Admin',
              onNavSelected: (_) {},
              onSignOut: () {},
              onSignIn: () {},
              onGoHome: () {},
              onGoDownloads: () {},
              onConnectGoogle: () {},
              onOpenGuidelines: () {},
            ),
          ),
        ),
      );

      expect(find.text('ADMINISTRATION'), findsOneWidget);
      expect(find.text('Admin Console'), findsOneWidget);
    });

    testWidgets('DashboardMobileTopBar hides Admin tab for non-admin user', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardMobileTopBar(
              user: normalUser,
              isGuestUser: false,
              activeNav: 'Inspection',
              onNavSelected: (_) {},
              onGoHome: () {},
              onSignOut: () {},
              onSignIn: () {},
              onSyncHistory: () {},
              onOpenDrawer: () {},
            ),
          ),
        ),
      );

      expect(find.text('Inspection'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Admin'), findsNothing);
    });

    testWidgets('DashboardMobileTopBar displays Admin tab for admin user', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardMobileTopBar(
              user: adminUser,
              isGuestUser: false,
              activeNav: 'Admin',
              onNavSelected: (_) {},
              onGoHome: () {},
              onSignOut: () {},
              onSignIn: () {},
              onSyncHistory: () {},
              onOpenDrawer: () {},
            ),
          ),
        ),
      );

      expect(find.text('Inspection'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });
  });

  group('AdminPageSection Rendering & Telemetry Tests', () {
    final mockStats = AdminTelemetryStatsModel(
      totals: const AdminTelemetryTotals(
        totalScans: 142,
        scansToday: 28,
        totalInspectors: 8,
        activeInspectorsToday: 4,
      ),
      distribution: const AdminTelemetryDistribution(
        freshCount: 110,
        notFreshCount: 32,
        freshnessRate: 77.5,
        eyeScans: 85,
        gillScans: 57,
      ),
      confidence: const AdminTelemetryConfidence(
        averageConfidence: 0.942,
        freshAvgConfidence: 0.965,
        notFreshAvgConfidence: 0.884,
      ),
      rejections: const AdminTelemetryRejections(
        totalRequests: 160,
        totalRejections: 18,
        rejectionRate: 11.25,
        rejectionsByReason: {
          'unsupported_type': 6,
          'dimensions': 4,
          'size': 5,
          'corrupted': 3,
        },
      ),
      latency: const AdminTelemetryLatency(
        averageLatencyMs: 42.5,
        medianLatencyMs: 38.0,
        p95LatencyMs: 65.2,
      ),
    );

    final mockUsers = [
      const AdminUserModel(
        id: 1,
        email: 'inspector@sariwaba.ph',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        role: 'user',
        isAdmin: false,
        isSuspended: false,
        scanCount: 45,
      ),
      const AdminUserModel(
        id: 2,
        email: 'admin@sariwaba.ph',
        firstName: 'Maria',
        lastName: 'Santos',
        role: 'admin',
        isAdmin: true,
        isSuspended: false,
        scanCount: 97,
      ),
      const AdminUserModel(
        id: 3,
        email: 'badactor@sariwaba.ph',
        firstName: 'Suspended',
        lastName: 'User',
        role: 'user',
        isAdmin: false,
        isSuspended: true,
        scanCount: 2,
      ),
    ];

    final mockSecurity = AdminSecurityModel(
      metrics: const SecurityMetricsModel(
        totalAttempts: 84,
        successfulAttempts: 79,
        failedAttempts: 5,
        failedLast24h: 3,
        failureRate: 5.95,
        suspiciousPatternDetected: true,
      ),
      suspiciousEvents: const [
        SuspiciousEventModel(
          type: 'RAPID_FAILURES_BY_IP',
          target: '192.168.1.100',
          failureCount: 4,
          window: '15m',
          severity: 'HIGH',
        ),
      ],
      recentLogs: [
        LoginAuditModel(
          id: 1,
          email: 'admin@sariwaba.ph',
          ipAddress: '127.0.0.1',
          status: 'SUCCESS',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        LoginAuditModel(
          id: 2,
          email: 'badactor@sariwaba.ph',
          ipAddress: '192.168.1.100',
          status: 'SUSPENDED_BLOCKED',
          failureReason: 'Account suspended by administrator.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ],
    );

    final mockHealth = AdminHealthModel(
      database: const DatabaseHealthModel(
        status: 'HEALTHY',
        latencyMs: 1.45,
        vendor: 'sqlite',
      ),
      mlModel: const MlModelHealthModel(
        status: 'READY',
        architecture: 'MobileNetV3-Small',
        checkpointName: 'sariwaba_mobilenetv3_best.pth',
        checkpointSizeBytes: 8900000,
        device: 'cpu',
      ),
      apiThroughput: const ApiThroughputHealthModel(
        totalRequestsTracked: 160,
        successCount: 142,
        clientErrorCount: 18,
        serverErrorCount: 0,
      ),
    );

    final mockAudits = [
      AdminAuditModel(
        scanId: 101,
        inspector: const AdminAuditInspector(
          id: 1,
          email: 'inspector@sariwaba.ph',
          name: 'Juan Dela Cruz',
        ),
        regionType: 'eye',
        label: 'Fresh',
        confidence: 0.965,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      AdminAuditModel(
        scanId: 102,
        inspector: const AdminAuditInspector(
          id: 2,
          email: 'admin@sariwaba.ph',
          name: 'Maria Santos',
        ),
        regionType: 'gill',
        label: 'Not Fresh',
        confidence: 0.884,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    testWidgets('AdminPageSection renders Bento KPIs and switches tabs', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final stateWithData = AdminState(
        stats: mockStats,
        users: mockUsers,
        security: mockSecurity,
        health: mockHealth,
        audits: mockAudits,
        totalAudits: 2,
        activeTab: AdminTab.inspectors,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminControllerProvider.overrideWith(
              (ref) => _MockAdminController(stateWithData),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AdminPageSection(isDesktop: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top banner checks
      expect(find.text('Admin Console & Telemetry'), findsOneWidget);
      expect(find.text('RBAC ADMINISTRATION'), findsOneWidget);
      expect(find.text('STRICT APPEND-ONLY'), findsOneWidget);

      // Bento KPI checks
      expect(find.text('INSPECTORS'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('GLOBAL INFERENCES'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('FRESHNESS COMPLIANCE'), findsOneWidget);
      expect(find.text('77.5%'), findsOneWidget);

      // Inspectors tab content
      expect(find.text('Registered Inspectors (3)'), findsOneWidget);
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('SUSPENDED'), findsOneWidget);
      expect(find.text('ACTIVE'), findsNWidgets(2));

      // Switch to Classification Telemetry tab
      await tester.ensureVisible(find.text('Classification Telemetry'));
      await tester.tap(find.text('Classification Telemetry'));
      await tester.pumpAndSettle();

      expect(find.text('Diagnostic Freshness Distribution'), findsOneWidget);
      expect(find.text('Unsupported Image Rejections'), findsOneWidget);
      expect(find.text('Inference Latency & Confidence'), findsOneWidget);
      expect(find.text('11.3% rate'), findsOneWidget);

      // Switch to Security & Audits tab
      await tester.ensureVisible(find.text('Security & Audits'));
      await tester.tap(find.text('Security & Audits'));
      await tester.pumpAndSettle();

      expect(find.text('Suspicious Authentication Patterns Detected'), findsOneWidget);
      expect(find.text('Append-Only Login Audit Trail'), findsOneWidget);
      expect(find.text('ZERO CREDENTIAL PERSISTENCE'), findsOneWidget);
      expect(find.text('admin@sariwaba.ph'), findsOneWidget);
      expect(find.text('badactor@sariwaba.ph'), findsOneWidget);

      // Switch to System Health tab
      await tester.ensureVisible(find.text('System Health'));
      await tester.tap(find.text('System Health'));
      await tester.pumpAndSettle();

      expect(find.text('Database Engine Health'), findsOneWidget);
      expect(find.text('Machine Learning Model Bundle'), findsOneWidget);
      expect(find.text('MobileNetV3-Small'), findsOneWidget);

      // Switch to Global Scan Trail tab
      await tester.ensureVisible(find.text('Global Scan Trail'));
      await tester.tap(find.text('Global Scan Trail'));
      await tester.pumpAndSettle();

      expect(find.text('Global Inspection Logs (2)'), findsOneWidget);
      expect(find.text('Scan #101'), findsOneWidget);
      expect(find.text('Scan #102'), findsOneWidget);
      expect(find.text('Append-Only · Deletion Protected'), findsOneWidget);
      // Zero delete icon or button on audit items!
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}

class _MockAdminController extends AdminController {
  _MockAdminController(AdminState initialState)
      : super(_EmptyAdminService()) {
    state = initialState;
  }

  @override
  Future<void> loadDashboard() async {
    // Keep existing mock state
  }

  @override
  void setTab(AdminTab tab) {
    state = state.copyWith(activeTab: tab);
  }
}

class _EmptyAdminService extends AdminService {
  _EmptyAdminService() : super(Dio());
}
