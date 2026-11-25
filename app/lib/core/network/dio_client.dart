import 'package:dio/dio.dart';

import 'package:campuseats/core/config/app_config.dart';
import 'package:campuseats/core/network/auth_interceptor.dart';
import 'package:campuseats/core/storage/secure_token_storage.dart';

class DioClient {
  DioClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    required void Function() onSessionExpired,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    refreshDio = Dio(baseOptions);
    dio = Dio(baseOptions);
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: refreshDio,
        retryDio: dio,
        onSessionExpired: onSessionExpired,
      ),
    );
  }

  late final Dio dio;
  late final Dio refreshDio;
}
