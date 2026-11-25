import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';

class PendingAccountPage extends StatelessWidget {
  const PendingAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated && !state.user.isPending) {
          context.go('/student/home');
        } else if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.secondaryDark,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Compte en attente de validation',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Votre demande d\'inscription pour le statut boursier avec le matricule ${user?.matricule ?? ""} a bien été enregistrée.\n\nL\'administration de la cantine vérifie manuellement votre statut. Dès validation, votre espace de commande sera activé.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: BorderSide(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          'Délai moyen constaté : 24h à 48h ouvrées',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'Actualiser mon statut',
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: () {
                      context.read<AuthBloc>().add(const AppStarted());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vérification du statut en cours...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Se déconnecter',
                    variant: ButtonVariant.outline,
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
