import 'dart:async';

import 'package:dio/dio.dart';

import 'package:campuseats/core/storage/secure_token_storage.dart';

/// Intercepteur HTTP gérant le Bearer token et le renouvellement atomique sur 401.
/// Si 3 requêtes concurrentes échouent en 401, un seul appel `/auth/refresh` est effectué
/// grâce au `Completer` partagé, puis les requêtes en attente réessaient avec le nouveau token.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio refreshDio,
    required Dio retryDio,
    required void Function() onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _refreshDio = refreshDio,
        _retryDio = retryDio,
        _onSessionExpired = onSessionExpired;

  final TokenStorage _tokenStorage;
  final Dio _refreshDio;
  final Dio _retryDio;
  final void Function() _onSessionExpired;

  Completer<String?>? _refreshing;

  static const _publicAuthPaths = <String>{
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/scholarship-check',
  };

  bool _isPublicAuthPath(String path) {
    return _publicAuthPaths.any((p) => path.endsWith(p) || path.contains(p));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicAuthPath(options.path)) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final options = err.requestOptions;

    final alreadyRetried = options.extra['retried'] == true;
    final skipRefresh = options.path.endsWith('/auth/login') ||
        options.path.endsWith('/auth/refresh') ||
        options.path.endsWith('/auth/register');

    if (status != 401 || alreadyRetried || skipRefresh) {
      handler.next(err);
      return;
    }

    final newToken = await _refreshAccessToken();
    if (newToken == null) {
      handler.next(err);
      return;
    }

    final retryOptions = options.copyWith(
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $newToken',
      },
      extra: {
        ...options.extra,
        'retried': true,
      },
    );

    try {
      final response = await _retryDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  Future<String?> _refreshAccessToken() async {
    // Un rafraîchissement déjà en cours : toutes les autres requêtes attendent le même résultat.
    if (_refreshing != null) {
      return _refreshing!.future;
    }

    final completer = Completer<String?>();
    _refreshing = completer;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _tokenStorage.clear();
        _onSessionExpired();
        completer.complete(null);
        return null;
      }

      final response = await _refreshDio.post<dynamic>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      if (data is! Map) {
        throw const FormatException('Réponse refresh invalide');
      }
      final newAccess = data['accessToken']?.toString();
      final newRefresh = data['refreshToken']?.toString();
      if (newAccess == null ||
          newAccess.isEmpty ||
          newRefresh == null ||
          newRefresh.isEmpty) {
        throw const FormatException('Paire de tokens manquante');
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      completer.complete(newAccess);
      return newAccess;
    } catch (_) {
      await _tokenStorage.clear();
      _onSessionExpired();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    } finally {
      _refreshing = null;
    }
  }
}
