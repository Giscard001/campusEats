import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';
import 'package:campuseats/features/auth/domain/repositories/auth_repository.dart';

enum RegisterStatus { initial, checkingScholarship, submitting, success, error }

class RegisterState extends Equatable {
  const RegisterState({
    this.currentStep = 0, // 0: Identity, 1: Scholarship, 2: Security
    this.status = RegisterStatus.initial,
    this.firstName = '',
    this.lastName = '',
    this.matricule = '',
    this.className = '',
    this.claimsScholarship = false,
    this.scholarshipVerified = false,
    this.scholarshipNotFound = false,
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordVisible = false,
    this.failure,
    this.user,
  });

  final int currentStep;
  final RegisterStatus status;
  final String firstName;
  final String lastName;
  final String matricule;
  final String className;
  final bool claimsScholarship;
  final bool scholarshipVerified;
  final bool scholarshipNotFound;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;
  final Failure? failure;
  final AppUser? user;

  RegisterState copyWith({
    int? currentStep,
    RegisterStatus? status,
    String? firstName,
    String? lastName,
    String? matricule,
    String? className,
    bool? claimsScholarship,
    bool? scholarshipVerified,
    bool? scholarshipNotFound,
    String? password,
    String? confirmPassword,
    bool? isPasswordVisible,
    Failure? failure,
    AppUser? user,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      matricule: matricule ?? this.matricule,
      className: className ?? this.className,
      claimsScholarship: claimsScholarship ?? this.claimsScholarship,
      scholarshipVerified: scholarshipVerified ?? this.scholarshipVerified,
      scholarshipNotFound: scholarshipNotFound ?? this.scholarshipNotFound,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      failure: failure,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        status,
        firstName,
        lastName,
        matricule,
        className,
        claimsScholarship,
        scholarshipVerified,
        scholarshipNotFound,
        password,
        confirmPassword,
        isPasswordVisible,
        failure,
        user,
      ];
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._authRepository) : super(const RegisterState());

  final AuthRepository _authRepository;

  void firstNameChanged(String v) => emit(state.copyWith(firstName: v, failure: null));
  void lastNameChanged(String v) => emit(state.copyWith(lastName: v, failure: null));
  void matriculeChanged(String v) => emit(state.copyWith(matricule: v, failure: null));
  void classNameChanged(String v) => emit(state.copyWith(className: v, failure: null));
  void claimsScholarshipToggled(bool v) => emit(state.copyWith(claimsScholarship: v, failure: null));
  void passwordChanged(String v) => emit(state.copyWith(password: v, failure: null));
  void confirmPasswordChanged(String v) => emit(state.copyWith(confirmPassword: v, failure: null));
  void togglePasswordVisibility() => emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  void dismissScholarshipDialog() => emit(state.copyWith(scholarshipNotFound: false));

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1, failure: null));
    }
  }

  bool validateStep0() {
    if (state.firstName.trim().isEmpty || state.lastName.trim().isEmpty || state.matricule.trim().isEmpty) {
      emit(state.copyWith(failure: const ValidationFailure('Veuillez remplir le prénom, le nom et le matricule.')));
      return false;
    }
    emit(state.copyWith(currentStep: 1, failure: null));
    return true;
  }

  Future<void> validateStep1() async {
    if (!state.claimsScholarship) {
      // Non-boursier -> proceed directly to step 2
      emit(state.copyWith(currentStep: 2, scholarshipVerified: false, failure: null));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.checkingScholarship));
    final result = await _authRepository.checkScholarship(
      matricule: state.matricule.trim(),
      lastName: state.lastName.trim(),
    );

    result.when(
      success: (isScholar) {
        if (isScholar) {
          emit(state.copyWith(
            status: RegisterStatus.initial,
            scholarshipVerified: true,
            scholarshipNotFound: false,
            currentStep: 2,
          ));
        } else {
          // Boursier non trouvé dans la liste -> popup dialog S04
          emit(state.copyWith(
            status: RegisterStatus.initial,
            scholarshipVerified: false,
            scholarshipNotFound: true,
          ));
        }
      },
      failure: (f) {
        emit(state.copyWith(status: RegisterStatus.error, failure: f));
      },
    );
  }

  void continueAsNonScholarship() {
    emit(state.copyWith(
      claimsScholarship: false,
      scholarshipNotFound: false,
      scholarshipVerified: false,
      currentStep: 2,
    ));
  }

  void requestManualValidation() {
    // Keeps claimsScholarship = true, proceeds to step 2. Account will be created with status 'pending'
    emit(state.copyWith(
      claimsScholarship: true,
      scholarshipNotFound: false,
      scholarshipVerified: false,
      currentStep: 2,
    ));
  }

  Future<void> submit() async {
    final pwd = state.password.trim();
    final confirm = state.confirmPassword.trim();

    if (pwd.length < 6) {
      emit(state.copyWith(
        failure: const ValidationFailure('Le mot de passe doit contenir au moins 6 caractères.'),
      ));
      return;
    }
    if (pwd != confirm) {
      emit(state.copyWith(
        failure: const ValidationFailure('Les deux mots de passe ne correspondent pas.'),
      ));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.submitting));

    final result = await _authRepository.register(
      matricule: state.matricule.trim(),
      firstName: state.firstName.trim(),
      lastName: state.lastName.trim(),
      password: pwd,
      className: state.className.trim().isNotEmpty ? state.className.trim() : null,
      isScholarship: state.claimsScholarship,
    );

    result.when(
      success: (user) => emit(state.copyWith(status: RegisterStatus.success, user: user)),
      failure: (failure) => emit(state.copyWith(status: RegisterStatus.error, failure: failure)),
    );
  }
}
