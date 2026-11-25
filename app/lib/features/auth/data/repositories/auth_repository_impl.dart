import 'dart:async';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/core/storage/cache_store.dart';
import 'package:campuseats/core/storage/secure_token_storage.dart';
import 'package:campuseats/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:campuseats/features/auth/data/models/user_model.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';
import 'package:campuseats/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
    required CacheStore cacheStore,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage,
        _cacheStore = cacheStore;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final CacheStore _cacheStore;

  final _userController = StreamController<AppUser?>.broadcast();
  AppUser? _cachedUser;

  static const String _userCacheKey = 'cached_current_user';

  @override
  Stream<AppUser?> get userStream => _userController.stream;

  @override
  Future<Result<AppUser>> login({
    required String matricule,
    required String password,
  }) async {
    final result = await guardRequest(() => _remoteDataSource.login(
          matricule: matricule,
          password: password,
        ));

    return result.when(
      success: (data) async {
        await _tokenStorage.saveTokens(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        );
        _cachedUser = data.user;
        await _cacheStore.putMap(_userCacheKey, UserModel.toJson(data.user));
        _userController.add(data.user);
        return Success(data.user);
      },
      failure: (failure) => Err(failure),
    );
  }

  @override
  Future<Result<bool>> checkScholarship({
    required String matricule,
    required String lastName,
  }) {
    return guardRequest(() => _remoteDataSource.checkScholarship(
          matricule: matricule,
          lastName: lastName,
        ));
  }

  @override
  Future<Result<AppUser>> register({
    required String matricule,
    required String firstName,
    required String lastName,
    required String password,
    String? className,
    required bool isScholarship,
  }) async {
    final result = await guardRequest(() => _remoteDataSource.register(
          matricule: matricule,
          firstName: firstName,
          lastName: lastName,
          password: password,
          className: className,
          isScholarship: isScholarship,
        ));

    return result.when(
      success: (data) async {
        if (data.accessToken != null && data.refreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: data.accessToken!,
            refreshToken: data.refreshToken!,
          );
        }
        _cachedUser = data.user;
        await _cacheStore.putMap(_userCacheKey, UserModel.toJson(data.user));
        _userController.add(data.user);
        return Success(data.user);
      },
      failure: (failure) => Err(failure),
    );
  }

  @override
  Future<Result<AppUser>> currentUser() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) {
      // Check cached user in case
      final cached = await _cacheStore.getMap(_userCacheKey);
      if (cached != null) {
        final user = UserModel.fromJson(cached);
        _cachedUser = user;
        _userController.add(user);
        return Success(user);
      }
      _cachedUser = null;
      _userController.add(null);
      return const Err(UnauthorizedFailure('Aucune session active'));
    }

    final result = await guardRequest(_remoteDataSource.currentUser);
    return result.when(
      success: (user) async {
        _cachedUser = user;
        await _cacheStore.putMap(_userCacheKey, UserModel.toJson(user));
        _userController.add(user);
        return Success(user);
      },
      failure: (failure) async {
        // Offline cache fallback
        final cached = await _cacheStore.getMap(_userCacheKey);
        if (cached != null) {
          final user = UserModel.fromJson(cached);
          _cachedUser = user;
          _userController.add(user);
          return Success(user);
        }
        return Err(failure);
      },
    );
  }

  @override
  Future<Result<void>> logout() async {
    await guardRequest(_remoteDataSource.logout);
    await _tokenStorage.clearTokens();
    await _cacheStore.delete(_userCacheKey);
    _cachedUser = null;
    _userController.add(null);
    return const Success(null);
  }
}
