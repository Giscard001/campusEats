import 'package:dio/dio.dart';

import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/utils/app_logger.dart';

/// Exécute un appel data en attrapant toutes les exceptions à la frontière data.
/// Les blocs ne reçoivent jamais de `DioException`, uniquement `Result<T>`.
Future<Result<T>> guardRequest<T>(Future<T> Function() run) async {
  try {
    final data = await run();
    return Success<T>(data);
  } on DioException catch (e) {
    return Err<T>(mapDioException(e));
  } on FormatException catch (e, st) {
    appLogger.e('FormatException lors du parsing API', error: e, stackTrace: st);
    return const Err(ServerFailure('Réponse serveur invalide.'));
  } on Failure catch (f) {
    return Err<T>(f);
  } catch (e, st) {
    appLogger.e('Erreur inattendue dans guardRequest', error: e, stackTrace: st);
    return const Err(UnknownFailure());
  }
}

Failure mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.cancel:
      return const NetworkFailure('Requête annulée.');
    case DioExceptionType.badCertificate:
      return const NetworkFailure('Certificat serveur invalide.');
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final response = e.response;
  if (response == null) {
    return const NetworkFailure();
  }

  final status = response.statusCode ?? 0;
  final body = response.data;
  final errorObj = body is Map<String, dynamic> && body['error'] is Map<String, dynamic>
      ? body['error'] as Map<String, dynamic>
      : (body is Map ? Map<String, dynamic>.from(body) : const <String, dynamic>{});

  final code = (errorObj['code'] ?? '').toString();
  final message = (errorObj['message'] ?? '').toString();

  if (status == 401) {
    return UnauthorizedFailure(
      message.isNotEmpty ? message : 'Session expirée. Veuillez vous reconnecter.',
    );
  }
  if (status == 403) {
    return ForbiddenFailure(
      message.isNotEmpty ? message : "Action non autorisée pour ce compte.",
    );
  }
  if (status == 404) {
    return NotFoundFailure(
      message.isNotEmpty ? message : 'Ressource introuvable.',
    );
  }
  if (status == 422) {
    final fieldErrors = <String, String>{};
    final rawDetails = errorObj['details'];
    if (rawDetails is List) {
      for (final item in rawDetails) {
        if (item is Map) {
          final field = item['field']?.toString() ?? '';
          final msg = item['message']?.toString() ?? '';
          if (field.isNotEmpty && msg.isNotEmpty) {
            fieldErrors[field] = msg;
          }
        }
      }
    }
    return ValidationFailure(
      message.isNotEmpty ? message : 'Veuillez vérifier les champs saisis.',
      fieldErrors: fieldErrors,
    );
  }
  if (status == 409 || (status == 400 && code.isNotEmpty)) {
    final detailsMap = <String, dynamic>{};
    if (errorObj['usedAt'] != null) {
      detailsMap['usedAt'] = errorObj['usedAt'];
    }
    final rawDetails = errorObj['details'];
    if (rawDetails is Map) {
      detailsMap.addAll(Map<String, dynamic>.from(rawDetails));
    }
    return ConflictFailure(
      code.isNotEmpty ? code : 'CONFLICT',
      message.isNotEmpty ? message : 'Conflit détecté.',
      details: detailsMap,
    );
  }
  if (status >= 500) {
    return ServerFailure(
      message.isNotEmpty ? message : 'Erreur interne du serveur.',
    );
  }
  return UnknownFailure(
    message.isNotEmpty ? message : 'Une erreur inattendue est survenue.',
  );
}
