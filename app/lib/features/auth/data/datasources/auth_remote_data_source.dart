import 'package:dio/dio.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/features/auth/data/models/user_model.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRemoteDataSource {
  Future<({AppUser user, String accessToken, String refreshToken})> login({
    required String matricule,
    required String password,
  });

  Future<bool> checkScholarship({
    required String matricule,
    required String lastName,
  });

  Future<({AppUser user, String? accessToken, String? refreshToken})> register({
    required String matricule,
    required String firstName,
    required String lastName,
    required String password,
    String? className,
    required bool isScholarship,
  });

  Future<AppUser> currentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<({AppUser user, String accessToken, String refreshToken})> login({
    required String matricule,
    required String password,
  }) async {
    final response = await _dio.requestMap(
      'POST',
      '/auth/login',
      data: {'matricule': matricule, 'password': password},
    );

    final userJson = asJsonMap(response['user']);
    return (
      user: UserModel.fromJson(userJson),
      accessToken: jsonString(response, 'accessToken'),
      refreshToken: jsonString(response, 'refreshToken'),
    );
  }

  @override
  Future<bool> checkScholarship({
    required String matricule,
    required String lastName,
  }) async {
    final response = await _dio.requestMap(
      'POST',
      '/scholarships/check',
      data: {'matricule': matricule, 'lastName': lastName},
    );
    return response['found'] == true || response['isScholarship'] == true;
  }

  @override
  Future<({AppUser user, String? accessToken, String? refreshToken})> register({
    required String matricule,
    required String firstName,
    required String lastName,
    required String password,
    String? className,
    required bool isScholarship,
  }) async {
    final response = await _dio.requestMap(
      'POST',
      '/auth/register',
      data: {
        'matricule': matricule,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        if (className != null) 'className': className,
        'isScholarship': isScholarship,
      },
    );

    final userJson = asJsonMap(response['user']);
    final user = UserModel.fromJson(userJson);
    final access = jsonStringOrNull(response, 'accessToken');
    final refresh = jsonStringOrNull(response, 'refreshToken');

    return (user: user, accessToken: access, refreshToken: refresh);
  }

  @override
  Future<AppUser> currentUser() async {
    final response = await _dio.requestMap('GET', '/auth/me');
    return UserModel.fromJson(response);
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.requestMap('POST', '/auth/logout');
    } catch (_) {
      // Best-effort logout on backend
    }
  }
}
