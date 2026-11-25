import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;
        if (user == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final (eligibilityBadge, badgeBg, badgeFg) = switch (user.eligibility) {
          EligibilityType.scholarship => ('Boursier de l\'État', AppColors.primaryContainer, AppColors.primary),
          EligibilityType.subscribed => ('Abonné', AppColors.secondaryContainer, AppColors.secondaryDark),
          EligibilityType.none => ('Non éligible (Sans abonnement)', AppColors.statusCancelledBg, AppColors.statusCancelled),
        };

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Mon profil'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Identity Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(user.fullName, style: AppTextStyles.h2),
                        const SizedBox(height: 4),
                        Text('Matricule : ${user.matricule}', style: AppTextStyles.bodyMedium),
                        if (user.className != null) ...[
                          const SizedBox(height: 2),
                          Text(user.className!, style: AppTextStyles.caption),
                        ],
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            eligibilityBadge,
                            style: AppTextStyles.caption.copyWith(color: badgeFg, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subscription details card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Statut de restauration', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        if (user.isScholarship) ...[
                          const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Bourse d\'État active pour l\'année universitaire.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ] else if (user.isSubscribed && user.subscriptionEnd != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.event_available_rounded, color: AppColors.secondaryDark, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Abonnement valide jusqu\'au ${Fmt.fullDate(user.subscriptionEnd!)}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.statusCancelled, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Aucun abonnement en cours. Rendez-vous au guichet cantine pour souscrire.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Mon QR Code d\'identité (Guichet)',
                          variant: ButtonVariant.outline,
                          icon: const Icon(Icons.qr_code_rounded, size: 18),
                          onPressed: () => context.push('/student/identity-qr'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                AppButton(
                  text: 'Se déconnecter',
                  variant: ButtonVariant.text,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.statusCancelled, size: 18),
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
