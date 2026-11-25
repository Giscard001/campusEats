import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/features/admin_users/data/datasources/users_remote_data_source.dart';
import 'package:campuseats/features/admin_users/domain/repositories/users_repository.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl(this._remote);

  final UsersRemoteDataSource _remote;

  @override
  Future<Result<PagedResult<AppUser>>> list({UserFilter filter = UserFilter.all, String? query, int page = 1}) =>
      guardRequest(() => _remote.list(filter: filter, query: query, page: page));

  @override
  Future<Result<AppUser>> detail(String id) => guardRequest(() => _remote.detail(id));

  @override
  Future<Result<AppUser>> createStaff({
    required String firstName,
    required String lastName,
    required String matricule,
    required String password,
  }) =>
      guardRequest(
        () => _remote.createStaff(firstName: firstName, lastName: lastName, matricule: matricule, password: password),
      );
}
