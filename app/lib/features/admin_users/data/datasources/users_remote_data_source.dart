import 'package:dio/dio.dart';

import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/features/admin_users/domain/repositories/users_repository.dart';
import 'package:campuseats/features/auth/data/models/user_model.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

abstract interface class UsersRemoteDataSource {
  Future<PagedResult<AppUser>> list({UserFilter filter = UserFilter.all, String? query, int page = 1});
  Future<AppUser> detail(String id);
  Future<AppUser> createStaff({
    required String firstName,
    required String lastName,
    required String matricule,
    required String password,
  });
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  UsersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedResult<AppUser>> list({UserFilter filter = UserFilter.all, String? query, int page = 1}) async =>
      pagedFromJson(
        await _dio.requestMap(
          'GET',
          '/users',
          query: {
            'filter': filter.name,
            if (query != null && query.isNotEmpty) 'q': query,
            'page': page,
            'limit': 20,
          },
        ),
        UserModel.fromJson,
      );

  @override
  Future<AppUser> detail(String id) async => UserModel.fromJson(await _dio.requestMap('GET', '/users/$id'));

  @override
  Future<AppUser> createStaff({
    required String firstName,
    required String lastName,
    required String matricule,
    required String password,
  }) async =>
      UserModel.fromJson(
        await _dio.requestMap(
          'POST',
          '/users/staff',
          data: {'firstName': firstName, 'lastName': lastName, 'matricule': matricule, 'password': password},
        ),
      );
}
