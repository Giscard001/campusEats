import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';
import 'package:campuseats/features/auth/domain/repositories/auth_repository.dart';

enum LoginStatus { initial, submitting, success, error }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.matricule = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.failure,
    this.user,
  });

  final LoginStatus status;
  final String matricule;
  final String password;
  final bool isPasswordVisible;
  final Failure? failure;
  final AppUser? user;

  LoginState copyWith({
    LoginStatus? status,
    String? matricule,
    String? password,
    bool? isPasswordVisible,
    Failure? failure,
    AppUser? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      matricule: matricule ?? this.matricule,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      failure: failure ?? this.failure,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, matricule, password, isPasswordVisible, failure, user];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  void matriculeChanged(String value) {
    emit(state.copyWith(matricule: value, status: LoginStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> submit() async {
    final mat = state.matricule.trim();
    final pwd = state.password.trim();

    if (mat.isEmpty || pwd.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.error,
        failure: const ValidationFailure('Veuillez remplir tous les champs obligatoires.'),
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting));

    final result = await _authRepository.login(matricule: mat, password: pwd);
    result.when(
      success: (user) => emit(state.copyWith(status: LoginStatus.success, user: user)),
      failure: (failure) => emit(state.copyWith(status: LoginStatus.error, failure: failure)),
    );
  }
}
