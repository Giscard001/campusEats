import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

enum UserFilter { all, student, staff, admin }

abstract interface class UsersRepository {
  Future<Result<PagedResult<AppUser>>> list({UserFilter filter = UserFilter.all, String? query, int page = 1});
  Future<Result<AppUser>> detail(String id);
  Future<Result<AppUser>> createStaff({
    required String firstName,
    required String lastName,
    required String matricule,
    required String password,
  });
}
