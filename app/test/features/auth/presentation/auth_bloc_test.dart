import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/storage/secure_token_storage.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';
import 'package:campuseats/features/auth/domain/repositories/auth_repository.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? mockUser;
  final _ctrl = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> get userStream => _ctrl.stream;

  @override
  Future<Result<AppUser>> currentUser() async {
    if (mockUser != null) return Success(mockUser!);
    return const Err(UnauthorizedFailure('Non authentifié'));
  }

  @override
  Future<Result<AppUser>> login({required String matricule, required String password}) async {
    return Success(mockUser!);
  }

  @override
  Future<Result<bool>> checkScholarship({required String matricule, required String lastName}) async {
    return const Success(true);
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
    return Success(mockUser!);
  }

  @override
  Future<Result<void>> logout() async {
    mockUser = null;
    return const Success(null);
  }
}

class MockTokenStorage implements TokenStorage {
  final _ctrl = StreamController<void>.broadcast();

  @override
  Stream<void> get sessionExpiredStream => _ctrl.stream;

  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'mock_token';

  @override
  Future<String?> getFcmToken() async => null;

  @override
  Future<String?> getRefreshToken() async => 'mock_refresh';

  @override
  Future<bool> hasTokens() async => true;

  @override
  Future<void> notifySessionExpired() async => _ctrl.add(null);

  @override
  Future<void> saveFcmToken(String token) async {}

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
}

void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockRepo;
    late MockTokenStorage mockStorage;
    late AuthBloc authBloc;

    final testUser = const AppUser(
      id: 'usr_test_1',
      firstName: 'Ousmane',
      lastName: 'Sawadogo',
      matricule: 'STU001',
      role: UserRole.student,
    );

    setUp(() {
      mockRepo = MockAuthRepository();
      mockStorage = MockTokenStorage();
      authBloc = AuthBloc(authRepository: mockRepo, tokenStorage: mockStorage);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthUnknown', () {
      expect(authBloc.state, const AuthUnknown());
    });

    test('AppStarted emits Authenticated when user exists', () async {
      mockRepo.mockUser = testUser;

      authBloc.add(const AppStarted());

      await expectLater(
        authBloc.stream,
        emits(Authenticated(testUser)),
      );
    });

    test('LogoutRequested emits Unauthenticated', () async {
      authBloc.add(const LogoutRequested());

      await expectLater(
        authBloc.stream,
        emits(const Unauthenticated()),
      );
    });
  });
}
