import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';

class OrderConfirmedPage extends StatelessWidget {
  const OrderConfirmedPage({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Green check circle (Stitch S08)
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.statusServedBg,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.statusServed,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Commande confirmée !',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre repas a été réservé avec succès.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Order Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Plat', value: order.dishName),
                      const Divider(height: 20, color: AppColors.divider),
                      _DetailRow(label: 'Créneau', value: order.slotLabel),
                      const Divider(height: 20, color: AppColors.divider),
                      _DetailRow(label: 'Date', value: Fmt.fullDate(order.date)),
                      const Divider(height: 20, color: AppColors.divider),
                      _DetailRow(label: 'Matricule', value: order.studentMatricule),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              AppButton(
                text: 'Voir mon QR Code de retrait',
                icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                onPressed: () => context.go('/student/today-qr'),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Retour au menu',
                variant: ButtonVariant.outline,
                onPressed: () => context.go('/student/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
