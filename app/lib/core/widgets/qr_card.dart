import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class QrCard extends StatelessWidget {
  const QrCard({
    super.key,
    required this.qrData,
    required this.matricule,
    this.title = 'Mon QR Code',
    this.subtitle,
    this.badge,
    this.isServed = false,
    this.onRefresh,
  });

  final String qrData;
  final String matricule;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final bool isServed;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              badge!,
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: BorderSide(
                      color: isServed ? AppColors.statusServed : AppColors.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isServed ? AppColors.statusServed : AppColors.primary).withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: isServed ? AppColors.statusServed : AppColors.primaryDark,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: isServed ? AppColors.statusServed : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isServed)
                  Container(
                    width: 252,
                    height: 252,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.statusServed,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PLAT SERVI',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.statusServed,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Matricule : $matricule',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Actualiser le QR'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
