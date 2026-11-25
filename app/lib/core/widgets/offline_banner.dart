import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.message = 'Mode hors-ligne actif. Données en cache.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.statusPendingBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: AppColors.statusPending,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.statusPending,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
