import 'package:flutter/material.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';

class ScholarshipNotFoundDialog extends StatelessWidget {
  const ScholarshipNotFoundDialog({
    super.key,
    required this.matricule,
    required this.onContinueAsNonScholarship,
    required this.onRequestManualValidation,
    required this.onCancel,
  });

  final String matricule;
  final VoidCallback onContinueAsNonScholarship;
  final VoidCallback onRequestManualValidation;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.secondaryDark,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Statut boursier non vérifié',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 10),
            Text(
              'Le matricule "$matricule" ne figure pas actuellement sur la liste officielle des boursiers enregistrée auprès de l\'administration.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Demander validation manuelle',
              variant: ButtonVariant.primary,
              icon: const Icon(Icons.assignment_ind_outlined, size: 18),
              onPressed: onRequestManualValidation,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Continuer sans statut boursier',
              variant: ButtonVariant.outline,
              onPressed: onContinueAsNonScholarship,
            ),
            const SizedBox(height: 6),
            AppButton(
              text: 'Modifier mes informations',
              variant: ButtonVariant.text,
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
