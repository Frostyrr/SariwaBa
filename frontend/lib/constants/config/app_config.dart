import 'package:flutter/foundation.dart';

class AppConfig {
  static String? _runtimeApiBaseUrl;

  static String get defaultApiUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String get compileTimeApiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    return fromEnv.isNotEmpty ? fromEnv : defaultApiUrl;
  }

  static String get apiBaseUrl {
    final override = _runtimeApiBaseUrl;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return compileTimeApiBaseUrl;
  }

  static void setRuntimeApiBaseUrl(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      _runtimeApiBaseUrl = null;
      return;
    }
    final normalized = trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'http://$trimmed';
    _runtimeApiBaseUrl = normalized.endsWith('/')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '104697469786-jjf8bei38i7c535in3fgc4vppifv8aem.apps.googleusercontent.com',
  );
}
