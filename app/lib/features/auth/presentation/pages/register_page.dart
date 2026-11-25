import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/auth/domain/repositories/auth_repository.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:campuseats/features/auth/presentation/cubit/register_cubit.dart';
import 'package:campuseats/features/auth/presentation/pages/scholarship_not_found_dialog.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(sl<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (prev, curr) =>
          prev.scholarshipNotFound != curr.scholarshipNotFound ||
          prev.status != curr.status ||
          prev.failure != curr.failure,
      listener: (context, state) {
        final cubit = context.read<RegisterCubit>();

        // Scholarship Not Found Dialog
        if (state.scholarshipNotFound) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => ScholarshipNotFoundDialog(
              matricule: state.matricule,
              onContinueAsNonScholarship: () {
                Navigator.of(context).pop();
                cubit.continueAsNonScholarship();
              },
              onRequestManualValidation: () {
                Navigator.of(context).pop();
                cubit.requestManualValidation();
              },
              onCancel: () {
                Navigator.of(context).pop();
                cubit.dismissScholarshipDialog();
              },
            ),
          );
        }

        if (state.status == RegisterStatus.success && state.user != null) {
          final user = state.user!;
          context.read<AuthBloc>().add(LoggedIn(user));
          if (user.isPending) {
            context.go('/pending');
          } else {
            context.go('/student/home');
          }
        } else if (state.status == RegisterStatus.error && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppColors.statusCancelled,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (state.currentStep > 0) {
                  cubit.previousStep();
                } else {
                  context.pop();
                }
              },
            ),
            title: const Text('Inscription étudiant'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Step Progress Indicator (Stitch S02, S03, S04)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      _StepCircle(step: 1, title: 'Identité', active: state.currentStep >= 0, current: state.currentStep == 0),
                      _StepLine(active: state.currentStep >= 1),
                      _StepCircle(step: 2, title: 'Bourse', active: state.currentStep >= 1, current: state.currentStep == 1),
                      _StepLine(active: state.currentStep >= 2),
                      _StepCircle(step: 3, title: 'Sécurité', active: state.currentStep >= 2, current: state.currentStep == 2),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),

                // Form Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: switch (state.currentStep) {
                      0 => _Step0Identity(state: state, cubit: cubit),
                      1 => _Step1Scholarship(state: state, cubit: cubit),
                      _ => _Step2Security(state: state, cubit: cubit),
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.step, required this.title, required this.active, required this.current});
  final int step;
  final String title;
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: current ? Border.all(color: AppColors.secondary, width: 2.5) : null,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            fontWeight: current ? FontWeight.bold : FontWeight.normal,
            color: current ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
        color: active ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

// Step 1: Identité
class _Step0Identity extends StatelessWidget {
  const _Step0Identity({required this.state, required this.cubit});
  final RegisterState state;
  final RegisterCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Étape 1 : Vos informations', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        const Text(
          'Ces données doivent correspondre fidèlement à votre carte d\'étudiant.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('Matricule étudiant *', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.matricule,
          onChanged: cubit.matriculeChanged,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'Ex: STU001'),
        ),
        const SizedBox(height: 16),
        Text('Nom *', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.lastName,
          onChanged: cubit.lastNameChanged,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Votre nom de famille'),
        ),
        const SizedBox(height: 16),
        Text('Prénom *', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.firstName,
          onChanged: cubit.firstNameChanged,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Votre prénom'),
        ),
        const SizedBox(height: 16),
        Text('Filière ou Promotion (facultatif)', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.className,
          onChanged: cubit.classNameChanged,
          decoration: const InputDecoration(hintText: 'Ex: Licence 2 Informatique'),
        ),
        if (state.failure != null) ...[
          const SizedBox(height: 16),
          Text(state.failure!.message, style: const TextStyle(color: AppColors.statusCancelled, fontSize: 13)),
        ],
        const SizedBox(height: 32),
        AppButton(
          text: 'Suivant',
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          onPressed: () => cubit.validateStep0(),
        ),
      ],
    );
  }
}

// Step 2: Bourse
class _Step1Scholarship extends StatelessWidget {
  const _Step1Scholarship({required this.state, required this.cubit});
  final RegisterState state;
  final RegisterCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Étape 2 : Statut boursier', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        const Text(
          'Indiquez si vous bénéficiez d\'une bourse nationale pour vos repas universitaires.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Je suis étudiant boursier', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Vos repas seront subventionnés après vérification de votre matricule.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.claimsScholarship,
                  activeColor: AppColors.primary,
                  onChanged: cubit.claimsScholarshipToggled,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (state.claimsScholarship) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.secondaryDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Votre statut sera immédiatement vérifié auprès de la base du CENOU.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_membership_rounded, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'En tant qu\'étudiant non-boursier, vous pourrez souscrire un abonnement mensuel au guichet de la cantine.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        AppButton(
          text: state.claimsScholarship ? 'Vérifier ma bourse' : 'Continuer',
          isLoading: state.status == RegisterStatus.checkingScholarship,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          onPressed: () => cubit.validateStep1(),
        ),
      ],
    );
  }
}

// Step 3: Sécurité
class _Step2Security extends StatelessWidget {
  const _Step2Security({required this.state, required this.cubit});
  final RegisterState state;
  final RegisterCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Étape 3 : Mot de passe', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        const Text(
          'Définissez un mot de passe sécurisé pour accéder à votre compte.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('Mot de passe (minimum 6 caractères) *', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.password,
          onChanged: cubit.passwordChanged,
          obscureText: !state.isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Votre mot de passe',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
            suffixIcon: IconButton(
              icon: Icon(
                state.isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: cubit.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Confirmer le mot de passe *', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.confirmPassword,
          onChanged: cubit.confirmPasswordChanged,
          obscureText: !state.isPasswordVisible,
          decoration: const InputDecoration(
            hintText: 'Répétez le mot de passe',
            prefixIcon: Icon(Icons.lock_clock_outlined, color: AppColors.textMuted),
          ),
        ),
        if (state.failure != null) ...[
          const SizedBox(height: 16),
          Text(state.failure!.message, style: const TextStyle(color: AppColors.statusCancelled, fontSize: 13)),
        ],
        const SizedBox(height: 32),
        AppButton(
          text: 'Créer mon compte',
          isLoading: state.status == RegisterStatus.submitting,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          onPressed: () => cubit.submit(),
        ),
      ],
    );
  }
}
