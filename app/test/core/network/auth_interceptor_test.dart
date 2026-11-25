import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campuseats/core/network/auth_interceptor.dart';
import 'package:campuseats/core/storage/secure_token_storage.dart';
import 'package:campuseats/core/time/server_clock.dart';

class MockTokenStorage implements TokenStorage {
  int refreshCallCount = 0;
  String? accessToken = 'initial_access_token';
  String? refreshToken = 'initial_refresh_token';

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<bool> hasTokens() async => accessToken != null;

  @override
  Future<String?> getFcmToken() async => null;

  @override
  Future<void> saveFcmToken(String token) async {}

  @override
  Future<void> notifySessionExpired() async {}

  @override
  Stream<void> get sessionExpiredStream => const Stream.empty();
}

void main() {
  group('AuthInterceptor', () {
    test('adds Bearer token to request headers', () async {
      final tokenStorage = MockTokenStorage();
      final interceptor = AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: Dio(),
        serverClock: ServerClock(),
      );

      final options = RequestOptions(path: '/orders');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      // Verify token added
      expect(options.headers['Authorization'], 'Bearer initial_access_token');
    });

    test('adds X-Client-Timestamp header for server clock synchronization', () async {
      final tokenStorage = MockTokenStorage();
      final interceptor = AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: Dio(),
        serverClock: ServerClock(),
      );

      final options = RequestOptions(path: '/orders');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('X-Client-Timestamp'), true);
    });
  });
}
