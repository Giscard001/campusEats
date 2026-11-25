import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/core/network/error_mapper.dart';

void main() {
  group('mapDioException', () {
    test('maps 422 to ValidationFailure with fieldErrors', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/orders'),
          statusCode: 422,
          data: {
            'message': 'Données non valides',
            'errors': {'dishId': 'Plat introuvable'},
          },
        ),
      );

      final failure = mapDioException(dioException);
      expect(failure, isA<ValidationFailure>());
      final vf = failure as ValidationFailure;
      expect(vf.message, 'Données non valides');
      expect(vf.fieldErrors?['dishId'], 'Plat introuvable');
    });

    test('maps 409 to ConflictFailure with details', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/orders'),
          statusCode: 409,
          data: {
            'message': 'Créneau complet',
            'code': 'SLOT_FULL',
          },
        ),
      );

      final failure = mapDioException(dioException);
      expect(failure, isA<ConflictFailure>());
      final cf = failure as ConflictFailure;
      expect(cf.message, 'Créneau complet');
      expect(cf.code, 'SLOT_FULL');
    });

    test('maps 401 to UnauthorizedFailure', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 401,
          data: {'message': 'Session expirée'},
        ),
      );

      final failure = mapDioException(dioException);
      expect(failure, isA<UnauthorizedFailure>());
    });
  });
}
