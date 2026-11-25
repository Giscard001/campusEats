import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/core/widgets/error_view.dart';
import 'package:campuseats/core/widgets/skeleton_box.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';
import 'package:campuseats/features/orders/presentation/cubit/place_order_cubit.dart';

class ChooseSlotPage extends StatelessWidget {
  const ChooseSlotPage({super.key, required this.dish});
  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlaceOrderCubit(
        dish: dish,
        date: DateTime.now(),
        orderRepository: sl<OrderRepository>(),
      ),
      child: const _ChooseSlotView(),
    );
  }
}

class _ChooseSlotView extends StatelessWidget {
  const _ChooseSlotView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaceOrderCubit, PlaceOrderState>(
      listener: (context, state) {
        if (state.status == PlaceOrderStatus.success && state.createdOrder != null) {
          context.go('/student/order-confirmed', extra: state.createdOrder);
        } else if (state.status == PlaceOrderStatus.error && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppColors.statusCancelled,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PlaceOrderCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Choix du créneau'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Dish Summary Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.restaurant_rounded, color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(state.dish.name, style: AppTextStyles.titleMedium),
                                      const SizedBox(height: 4),
                                      Text('Repas pour aujourd\'hui', style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text('Sélectionnez votre heure de passage', style: AppTextStyles.h3),
                        const SizedBox(height: 6),
                        const Text(
                          'Les créneaux permettent d\'éviter les files d\'attente à la cantine.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 18),

                        if (state.status == PlaceOrderStatus.loadingSlots)
                          const Column(
                            children: [
                              SkeletonBox(width: double.infinity, height: 72),
                              SizedBox(height: 12),
                              SkeletonBox(width: double.infinity, height: 72),
                            ],
                          )
                        else if (state.status == PlaceOrderStatus.error && state.slots.isEmpty)
                          ErrorView(
                            message: state.failure?.message ?? 'Impossible de charger les créneaux',
                            onRetry: cubit.loadSlots,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.slots.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final slot = state.slots[index];
                              final isSelected = state.selectedSlot?.id == slot.id;

                              return _SlotSelectionCard(
                                slot: slot,
                                isSelected: isSelected,
                                onSelect: () => cubit.selectSlot(slot),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Bottom Confirmation Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: AppButton(
                    text: 'Confirmer ma commande',
                    isLoading: state.status == PlaceOrderStatus.submitting,
                    onPressed: state.selectedSlot != null ? cubit.submitOrder : null,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SlotSelectionCard extends StatelessWidget {
  const _SlotSelectionCard({
    required this.slot,
    required this.isSelected,
    required this.onSelect,
  });

  final Slot slot;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final isFull = slot.isFull;

    return GestureDetector(
      onTap: isFull ? null : onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFull
              ? AppColors.surfaceVariant.withValues(alpha: 0.6)
              : (isSelected ? AppColors.primaryContainer.withValues(alpha: 0.4) : AppColors.surface),
          borderRadius: BorderRadius.circular(14),
          border: BorderSide(
            color: isSelected
                ? AppColors.primary
                : (isFull ? AppColors.border : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : (isFull ? Icons.block_rounded : Icons.radio_button_unchecked_rounded),
              color: isSelected
                  ? AppColors.primary
                  : (isFull ? AppColors.textMuted : AppColors.border),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.label,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isFull ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${slot.startTime} à ${slot.endTime}',
                    style: AppTextStyles.caption.copyWith(
                      color: isFull ? AppColors.textMuted : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isFull ? AppColors.statusCancelledBg : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isFull ? 'Complet' : '${slot.remaining} places',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFull ? AppColors.statusCancelled : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
