import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  Future<Result<AppUser>> login({
    required String matricule,
    required String password,
  });

  Future<Result<bool>> checkScholarship({
    required String matricule,
    required String lastName,
  });

  Future<Result<AppUser>> register({
    required String matricule,
    required String firstName,
    required String lastName,
    required String password,
    String? className,
    required bool isScholarship,
  });

  Future<Result<AppUser>> currentUser();

  Future<Result<void>> logout();

  Stream<AppUser?> get userStream;
}
