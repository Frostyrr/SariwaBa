import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/classification/classification_result.dart';

class GuestHistoryCache {
  static const String _cacheKey = 'sariwaba_guest_scan_cache_v1';
  static const int maxCachedScans = 10;

  final FlutterSecureStorage _storage;
  List<ClassificationResult> _memoryCache = [];

  GuestHistoryCache({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<List<ClassificationResult>> getCachedHistory() async {
    try {
      final raw = await _storage.read(key: _cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _memoryCache = decoded
            .whereType<Map<String, dynamic>>()
            .map(ClassificationResult.fromJson)
            .toList();
      }
    } catch (_) {
      // Fallback to in-memory cache if platform storage is unavailable (e.g. tests)
    }
    return List<ClassificationResult>.unmodifiable(_memoryCache);
  }

  Future<List<ClassificationResult>> addScan(ClassificationResult result) async {
    await getCachedHistory();

    final localId = result.scanId ??
        -(DateTime.now().millisecondsSinceEpoch % 1000000);
    final cachedItem = ClassificationResult(
      scanId: localId,
      label: result.label,
      confidence: result.confidence,
      saved: false,
      imageUrl: result.imageUrl,
      createdAt: result.createdAt ?? DateTime.now(),
    );

    _memoryCache = [
      cachedItem,
      ..._memoryCache.where((s) => s.scanId != localId),
    ];

    if (_memoryCache.length > maxCachedScans) {
      _memoryCache = _memoryCache.sublist(0, maxCachedScans);
    }

    await _persist();
    return List<ClassificationResult>.unmodifiable(_memoryCache);
  }

  Future<List<ClassificationResult>> removeScan(int scanId) async {
    _memoryCache = _memoryCache.where((s) => s.scanId != scanId).toList();
    await _persist();
    return List<ClassificationResult>.unmodifiable(_memoryCache);
  }

  Future<void> clearCache() async {
    _memoryCache = [];
    try {
      await _storage.delete(key: _cacheKey);
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final encoded = jsonEncode(_memoryCache.map((s) => s.toJson()).toList());
      await _storage.write(key: _cacheKey, value: encoded);
    } catch (_) {
      // Ignore storage errors in test environments
    }
  }
}

final guestHistoryCacheProvider = Provider<GuestHistoryCache>((ref) {
  return GuestHistoryCache();
});
