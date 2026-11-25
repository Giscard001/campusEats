import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getFcmToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> saveFcmToken(String token);
  Future<void> clearFcmToken();
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _accessKey = 'campuseats_access_token';
  static const _refreshKey = 'campuseats_refresh_token';
  static const _fcmKey = 'campuseats_fcm_token';

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<String?> getFcmToken() => _storage.read(key: _fcmKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> saveFcmToken(String token) =>
      _storage.write(key: _fcmKey, value: token);

  @override
  Future<void> clearFcmToken() => _storage.delete(key: _fcmKey);

  @override
  Future<void> clear() => _storage.deleteAll();
}
