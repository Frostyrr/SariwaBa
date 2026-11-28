import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/config/app_config.dart';
import 'constants/theme/app_colors.dart';
import 'constants/theme/app_scroll_behavior.dart';
import 'constants/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/storage/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      final savedUrl = await TokenStorage().getApiBaseUrl();
      if (savedUrl != null && savedUrl.isNotEmpty) {
        AppConfig.setRuntimeApiBaseUrl(savedUrl);
      }
    } catch (_) {
      // Ignore storage read failures on startup and fall back to compile-time URL.
    }
  }

  // Set system UI overlay style for dark immersive startup experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: SariwaColors.bgObsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SariwaBaApp(),
    ),
  );
}

class SariwaBaApp extends ConsumerWidget {
  const SariwaBaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'SariwaBa — Fish Freshness',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
