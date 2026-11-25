import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/qr_card.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';

class IdentityQrPage extends StatelessWidget {
  const IdentityQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QR Code d\'identité'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              QrCard(
                qrData: 'CAMPUS-USER-${user.matricule}',
                matricule: user.matricule,
                title: user.fullName,
                subtitle: 'Carte d\'identité étudiante permanente',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: BorderSide(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Présentez ce QR Code au personnel de la cantine pour renouveler votre abonnement ou régulariser votre compte.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
