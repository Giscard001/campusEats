import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/core/widgets/error_view.dart';
import 'package:campuseats/core/widgets/qr_card.dart';
import 'package:campuseats/core/widgets/skeleton_box.dart';
import 'package:campuseats/core/widgets/status_chip.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';
import 'package:campuseats/features/orders/presentation/cubit/today_qr_cubit.dart';

class TodayQrPage extends StatelessWidget {
  const TodayQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodayQrCubit(sl<OrderRepository>()),
      child: const _TodayQrView(),
    );
  }
}

class _TodayQrView extends StatelessWidget {
  const _TodayQrView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon QR Code du jour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () => context.read<TodayQrCubit>().loadTodayQr(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<TodayQrCubit, TodayQrState>(
          builder: (context, state) {
            if (state.status == TodayQrStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: SkeletonBox(width: 320, height: 420, borderRadius: 20),
                ),
              );
            }

            if (state.status == TodayQrStatus.error && state.order == null) {
              return ErrorView(
                message: state.failure?.message ?? 'Impossible de charger votre QR code',
                onRetry: () => context.read<TodayQrCubit>().loadTodayQr(),
              );
            }

            if (state.status == TodayQrStatus.empty || state.order == null) {
              return EmptyView(
                title: 'Pas de commande aujourd\'hui',
                message: 'Vous n\'avez pas encore réservé de repas pour aujourd\'hui.',
                icon: Icons.qr_code_rounded,
                actionLabel: 'Commander mon repas',
                onAction: () => context.go('/student/home'),
              );
            }

            final order = state.order!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  QrCard(
                    qrData: order.qrCode,
                    matricule: order.studentMatricule,
                    title: order.dishName,
                    subtitle: 'Créneau : ${order.slotLabel}',
                    isServed: order.isServed,
                    badge: StatusChip(status: order.status),
                    onRefresh: () => context.read<TodayQrCubit>().loadTodayQr(),
                  ),
                  const SizedBox(height: 20),

                  // Tips card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: BorderSide(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Présentez ce QR Code au guichet lors de votre créneau (${order.slotLabel}) pour retirer votre repas.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
