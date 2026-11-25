import 'package:flutter/material.dart';
import '../domain/order_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final OrderStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg, icon) = switch (status) {
      OrderStatus.received => (
          'Reçue',
          AppColors.statusPending,
          AppColors.statusPendingBg,
          Icons.hourglass_top_rounded,
        ),
      OrderStatus.preparing => (
          'En préparation',
          AppColors.secondaryDark,
          AppColors.secondaryContainer,
          Icons.soup_kitchen_rounded,
        ),
      OrderStatus.ready => (
          'Prête',
          AppColors.statusReady,
          AppColors.statusReadyBg,
          Icons.check_circle_outline_rounded,
        ),
      OrderStatus.collected => (
          'Récupérée',
          AppColors.statusServed,
          AppColors.statusServedBg,
          Icons.done_all_rounded,
        ),
      OrderStatus.cancelled => (
          'Annulée',
          AppColors.statusCancelled,
          AppColors.statusCancelledBg,
          Icons.cancel_outlined,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
