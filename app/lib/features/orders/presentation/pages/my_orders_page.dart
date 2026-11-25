import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/core/widgets/error_view.dart';
import 'package:campuseats/core/widgets/skeleton_box.dart';
import 'package:campuseats/core/widgets/status_chip.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';
import 'package:campuseats/features/orders/presentation/bloc/my_orders_bloc.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyOrdersBloc(sl<OrderRepository>()),
      child: const _MyOrdersView(),
    );
  }
}

class _MyOrdersView extends StatelessWidget {
  const _MyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes commandes'),
      ),
      body: BlocConsumer<MyOrdersBloc, MyOrdersState>(
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
          if (state.status == MyOrdersStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SkeletonBox(width: double.infinity, height: 110),
                  SizedBox(height: 12),
                  SkeletonBox(width: double.infinity, height: 110),
                ],
              ),
            );
          }

          if (state.status == MyOrdersStatus.error && state.orders.isEmpty) {
            return ErrorView(
              message: state.failure?.message ?? 'Impossible de charger vos commandes',
              onRetry: () => context.read<MyOrdersBloc>().add(const LoadMyOrders()),
            );
          }

          if (state.orders.isEmpty) {
            return const EmptyView(
              title: 'Aucune commande',
              message: 'Vous n\'avez pas encore effectué de commande.',
              icon: Icons.history_rounded,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<MyOrdersBloc>().add(const RefreshMyOrders());
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _OrderHistoryCard(
                  order: order,
                  onCancel: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Annuler la commande ?'),
                        content: Text('Voulez-vous vraiment annuler votre repas du ${Fmt.shortDate(order.date)} ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            child: const Text('Non'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCancelled),
                            onPressed: () {
                              Navigator.of(dialogCtx).pop();
                              context.read<MyOrdersBloc>().add(CancelOrderRequested(order.id));
                            },
                            child: const Text('Oui, annuler'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order, required this.onCancel});
  final Order order;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Fmt.fullDate(order.date),
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
                ),
                StatusChip(status: order.status, compact: true),
              ],
            ),
            const SizedBox(height: 10),
            Text(order.dishName, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Créneau : ${order.slotLabel}', style: AppTextStyles.caption),
              ],
            ),
            if (order.canBeCancelled) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusCancelled,
                      side: const BorderSide(color: AppColors.statusCancelled, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 14),
                    label: const Text('Annuler', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
