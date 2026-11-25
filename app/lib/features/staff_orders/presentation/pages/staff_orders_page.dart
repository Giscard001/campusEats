import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/core/widgets/error_view.dart';
import 'package:campuseats/core/widgets/skeleton_box.dart';
import 'package:campuseats/core/widgets/status_chip.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/staff_orders/domain/repositories/staff_orders_repository.dart';
import 'package:campuseats/features/staff_orders/presentation/bloc/staff_orders_bloc.dart';

class StaffOrdersPage extends StatelessWidget {
  const StaffOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffOrdersBloc(sl<StaffOrdersRepository>()),
      child: const _StaffOrdersView(),
    );
  }
}

class _StaffOrdersView extends StatelessWidget {
  const _StaffOrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commandes du jour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () => context.read<StaffOrdersBloc>().add(const LoadStaffOrders()),
          ),
        ],
      ),
      body: BlocConsumer<StaffOrdersBloc, StaffOrdersState>(
        listenWhen: (prev, curr) => curr.snackBarMessage != null && curr.snackBarMessage != prev.snackBarMessage,
        listener: (context, state) {
          if (state.snackBarMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.snackBarMessage!),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final summary = state.summary;

          return Column(
            children: [
              // Summary Banner (portions served vs total)
              if (summary != null)
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service du midi : ${summary.served} / ${summary.total} servis',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: summary.progressRate,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${summary.remaining} restants',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (q) => context.read<StaffOrdersBloc>().add(SearchQueryChanged(q)),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom ou matricule...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => context.read<StaffOrdersBloc>().add(const SearchQueryChanged('')),
                          )
                        : null,
                  ),
                ),
              ),

              // Slot Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Tous les créneaux',
                      isSelected: state.selectedSlotId == null || state.selectedSlotId == 'all',
                      onSelected: () => context.read<StaffOrdersBloc>().add(const SlotFilterChanged(null)),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '11h30 - 12h00',
                      isSelected: state.selectedSlotId == 'slot_1',
                      onSelected: () => context.read<StaffOrdersBloc>().add(const SlotFilterChanged('slot_1')),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '12h00 - 12h30',
                      isSelected: state.selectedSlotId == 'slot_2',
                      onSelected: () => context.read<StaffOrdersBloc>().add(const SlotFilterChanged('slot_2')),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '12h30 - 13h00',
                      isSelected: state.selectedSlotId == 'slot_3',
                      onSelected: () => context.read<StaffOrdersBloc>().add(const SlotFilterChanged('slot_3')),
                    ),
                  ],
                ),
              ),

              // Orders List
              Expanded(
                child: state.status == StaffOrdersStatus.loading && state.orders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SkeletonBox(width: double.infinity, height: 90),
                            SizedBox(height: 10),
                            SkeletonBox(width: double.infinity, height: 90),
                          ],
                        ),
                      )
                    : (state.status == StaffOrdersStatus.error && state.orders.isEmpty
                        ? ErrorView(
                            message: state.failure?.message ?? 'Erreur de chargement',
                            onRetry: () => context.read<StaffOrdersBloc>().add(const LoadStaffOrders()),
                          )
                        : (state.orders.isEmpty
                            ? const EmptyView(
                                title: 'Aucune commande trouvée',
                                message: 'Aucune commande ne correspond aux filtres actuels.',
                                icon: Icons.dinner_dining_outlined,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                itemCount: state.orders.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final order = state.orders[index];
                                  return _StaffOrderRowCard(
                                    order: order,
                                    onMarkReady: () => context.read<StaffOrdersBloc>().add(
                                          UpdateOrderStatusRequested(
                                            orderId: order.id,
                                            newStatus: OrderStatus.ready,
                                          ),
                                        ),
                                    onMarkServed: () => context.read<StaffOrdersBloc>().add(
                                          UpdateOrderStatusRequested(
                                            orderId: order.id,
                                            newStatus: OrderStatus.served,
                                          ),
                                        ),
                                  );
                                },
                              ))),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primaryContainer,
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _StaffOrderRowCard extends StatelessWidget {
  const _StaffOrderRowCard({
    required this.order,
    required this.onMarkReady,
    required this.onMarkServed,
  });

  final Order order;
  final VoidCallback onMarkReady;
  final VoidCallback onMarkServed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.studentName} (${order.studentMatricule})',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                StatusChip(status: order.status, compact: true),
              ],
            ),
            const SizedBox(height: 4),
            Text(order.dishName, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text('Créneau : ${order.slotLabel}', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == OrderStatus.pending) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusReady,
                      side: const BorderSide(color: AppColors.statusReady),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onMarkReady,
                    icon: const Icon(Icons.check_rounded, size: 14),
                    label: const Text('Marquer Prêt', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                ],
                if (order.status != OrderStatus.served && order.status != OrderStatus.cancelled) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusServed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onMarkServed,
                    icon: const Icon(Icons.done_all_rounded, size: 14),
                    label: const Text('Servir', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
