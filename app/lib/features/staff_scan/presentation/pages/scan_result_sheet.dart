import 'package:flutter/material.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/staff_scan/domain/entities/scan_result.dart';

class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({
    super.key,
    required this.result,
    required this.isServing,
    required this.onValidateServed,
    required this.onDismiss,
  });

  final ScanResult result;
  final bool isServing;
  final VoidCallback onValidateServed;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final (bgIcon, iconColor, icon) = switch (result.statusType) {
      ScanStatusType.valid => (AppColors.statusServedBg, AppColors.statusServed, Icons.check_circle_rounded),
      ScanStatusType.alreadyUsed => (AppColors.statusPendingBg, AppColors.statusPending, Icons.history_rounded),
      ScanStatusType.expired => (AppColors.statusCancelledBg, AppColors.statusCancelled, Icons.timer_off_rounded),
      ScanStatusType.subscriptionExpired => (AppColors.statusCancelledBg, AppColors.statusCancelled, Icons.card_membership_rounded),
      ScanStatusType.noOrder || ScanStatusType.error => (AppColors.statusCancelledBg, AppColors.statusCancelled, Icons.error_outline_rounded),
    };

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgIcon, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 48),
          ),
          const SizedBox(height: 16),
          Text(result.statusType.label, style: AppTextStyles.h2),
          const SizedBox(height: 6),

          if (result.isValid && result.order != null) ...[
            Text(
              '${result.studentName} (${result.studentMatricule})',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Row('Plat', result.order!.dishName),
                    const Divider(height: 16, color: AppColors.divider),
                    _Row('Créneau', result.order!.slotLabel),
                    const Divider(height: 16, color: AppColors.divider),
                    _Row('Date', Fmt.shortDate(result.order!.date)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Valider la distribution (Servi)',
              isLoading: isServing,
              icon: const Icon(Icons.done_all_rounded, size: 20),
              onPressed: onValidateServed,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                result.message ??
                    (result.isAlreadyUsed && result.servedAt != null
                        ? 'Servi le ${Fmt.time(result.servedAt!)}'
                        : 'Cette commande ne peut pas être distribuée.'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Fermer',
              variant: ButtonVariant.outline,
              onPressed: onDismiss,
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.val);
  final String label;
  final String val;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Flexible(
          child: Text(
            val,
            style: AppTextStyles.titleSmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
