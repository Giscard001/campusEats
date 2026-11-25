import 'dart:convert';

import 'package:hive_ce/hive.dart';

class CacheEntry {
  const CacheEntry({
    required this.savedAt,
    required this.data,
  });

  final DateTime savedAt;
  final dynamic data;
}

abstract interface class CacheStore {
  Future<void> put(String key, Object data, {DateTime? savedAt});
  Future<CacheEntry?> get(String key);
  Future<void> remove(String key);
  Future<void> clearAll();
}

class HiveCacheStore implements CacheStore {
  HiveCacheStore(this._box);

  final Box<String> _box;

  @override
  Future<void> put(String key, Object data, {DateTime? savedAt}) async {
    final payload = jsonEncode({
      'savedAt': (savedAt ?? DateTime.now().toUtc()).toIso8601String(),
      'data': data,
    });
    await _box.put(key, payload);
  }

  @override
  Future<CacheEntry?> get(String key) async {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final savedAt = DateTime.tryParse(decoded['savedAt']?.toString() ?? '') ??
          DateTime.now().toUtc();
      return CacheEntry(savedAt: savedAt, data: decoded['data']);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) => _box.delete(key);

  @override
  Future<void> clearAll() => _box.clear();
}

/// Implémentation en mémoire utile pour les tests ou le fallback sans disque.
class MemoryCacheStore implements CacheStore {
  final Map<String, CacheEntry> _store = {};

  @override
  Future<void> put(String key, Object data, {DateTime? savedAt}) async {
    _store[key] = CacheEntry(
      savedAt: savedAt ?? DateTime.now().toUtc(),
      data: data,
    );
  }

  @override
  Future<CacheEntry?> get(String key) async => _store[key];

  @override
  Future<void> remove(String key) async => _store.remove(key);

  @override
  Future<void> clearAll() async => _store.clear();
}
