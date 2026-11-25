import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/storage/secure_token_storage.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';
import 'package:campuseats/features/auth/domain/repositories/auth_repository.dart';

// Events
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class AppStarted extends AuthEvent {
  const AppStarted();
}

final class LoggedIn extends AuthEvent {
  const LoggedIn(this.user);
  final AppUser user;
  @override
  List<Object?> get props => [user];
}

final class UserRefreshed extends AuthEvent {
  const UserRefreshed(this.user);
  final AppUser user;
  @override
  List<Object?> get props => [user];
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

final class SessionExpired extends AuthEvent {
  const SessionExpired();
}

// States
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);
  final AppUser user;
  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.message});
  final String? message;
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage = tokenStorage,
        super(const AuthUnknown()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<UserRefreshed>(_onUserRefreshed);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);

    _sessionSubscription = _tokenStorage.sessionExpiredStream.listen((_) {
      add(const SessionExpired());
    });
  }

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  StreamSubscription<void>? _sessionSubscription;

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final result = await _authRepository.currentUser();
    result.when(
      success: (user) => emit(Authenticated(user)),
      failure: (_) => emit(const Unauthenticated()),
    );
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    emit(Authenticated(event.user));
  }

  void _onUserRefreshed(UserRefreshed event, Emitter<AuthState> emit) {
    emit(Authenticated(event.user));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const Unauthenticated());
  }

  Future<void> _onSessionExpired(SessionExpired event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const Unauthenticated(message: 'Votre session a expiré. Veuillez vous reconnecter.'));
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
