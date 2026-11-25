import 'package:dio/dio.dart';

import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/time/server_clock.dart';

ServerClock? _globalServerClock;

/// Enregistre l'horloge serveur utilisée par les helpers JSON pour synchroniser
/// automatiquement `serverTime` à chaque réponse API qui le contient.
void attachServerClock(ServerClock clock) {
  _globalServerClock = clock;
}

extension DioRequestX on Dio {
  Future<Map<String, dynamic>> requestMap(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? data,
  }) async {
    final response = await request<dynamic>(
      path,
      data: data,
      queryParameters: query,
      options: Options(method: method),
    );
    final payload = response.data;
    if (payload == null || payload == '') {
      return <String, dynamic>{};
    }
    final map = asJsonMap(payload);
    final serverTime = map['serverTime'];
    if (serverTime is String) {
      _globalServerClock?.updateFromIsoString(serverTime);
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> requestList(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? data,
  }) async {
    final response = await request<dynamic>(
      path,
      data: data,
      queryParameters: query,
      options: Options(method: method),
    );
    final payload = response.data;
    if (payload is List) {
      return [for (final item in payload) asJsonMap(item)];
    }
    if (payload is Map && payload['items'] is List) {
      final map = asJsonMap(payload);
      final serverTime = map['serverTime'];
      if (serverTime is String) {
        _globalServerClock?.updateFromIsoString(serverTime);
      }
      return [for (final item in map['items'] as List) asJsonMap(item)];
    }
    return const [];
  }
}

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  throw const FormatException('Objet JSON attendu.');
}

String jsonString(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) return '';
  return v.toString();
}

String? jsonStringOrNull(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int jsonInt(Map<String, dynamic> j, String key, {int fallback = 0}) {
  final v = j[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

DateTime? jsonDateOrNull(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

PagedResult<T> pagedFromJson<T>(
  Map<String, dynamic> j,
  T Function(Map<String, dynamic>) fromJson,
) {
  final rawItems = j['items'];
  final items = rawItems is List
      ? [for (final e in rawItems) fromJson(asJsonMap(e))]
      : <T>[];
  return PagedResult<T>(
    items: items,
    page: jsonInt(j, 'page', fallback: 1),
    limit: jsonInt(j, 'limit', fallback: 20),
    total: jsonInt(j, 'total', fallback: items.length),
  );
}
