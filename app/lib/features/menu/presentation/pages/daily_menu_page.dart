import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/core/widgets/error_view.dart';
import 'package:campuseats/core/widgets/skeleton_box.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';
import 'package:campuseats/features/menu/presentation/bloc/menu_bloc.dart';

class DailyMenuPage extends StatelessWidget {
  const DailyMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MenuBloc>(),
      child: const _DailyMenuView(),
    );
  }
}

class _DailyMenuView extends StatelessWidget {
  const _DailyMenuView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lunch_dining_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Menu du jour', style: AppTextStyles.h2),
                Text('Cantine Universitaire', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
            tooltip: 'Mon QR Code du jour',
            onPressed: () => context.push('/student/today-qr'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.push('/student/notifications'),
          ),
        ],
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, menuState) {
          final authState = context.watch<AuthBloc>().state;
          final user = authState is Authenticated ? authState.user : null;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<MenuBloc>().add(const RefreshMenu());
            },
            child: CustomScrollView(
              slivers: [
                // 1. Date Selector Strip
                SliverToBoxAdapter(
                  child: _DateSelectorStrip(
                    selectedDate: menuState.selectedDate,
                    onDateSelected: (date) {
                      context.read<MenuBloc>().add(MenuDateChanged(date));
                    },
                  ),
                ),

                // 2. Cutoff Banner
                SliverToBoxAdapter(
                  child: _CutoffBanner(
                    isPastCutoff: menuState.isPastCutoff,
                    countdown: menuState.cutoffCountdown,
                  ),
                ),

                // 3. User Eligibility Card
                if (user != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _EligibilityHeaderCard(user: user),
                    ),
                  ),

                // 4. Dishes List or Loader
                if (menuState.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SkeletonBox(width: double.infinity, height: 160),
                          SizedBox(height: 16),
                          SkeletonBox(width: double.infinity, height: 160),
                        ],
                      ),
                    ),
                  )
                else if (menuState.failure != null)
                  SliverFillRemaining(
                    child: ErrorView(
                      message: menuState.failure!.message,
                      onRetry: () => context.read<MenuBloc>().add(const RefreshMenu()),
                    ),
                  )
                else if (menuState.menu == null || menuState.menu!.dishes.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyView(
                      title: 'Aucun plat programmé',
                      message: 'Le menu de cette date n\'a pas encore été publié par la cantine.',
                      icon: Icons.restaurant_outlined,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dish = menuState.menu!.dishes[index];
                          return _DishCard(
                            dish: dish,
                            canOrder: user?.canOrder == true && !menuState.isPastCutoff,
                            onOrder: () {
                              context.push('/student/choose-slot', extra: dish);
                            },
                          );
                        },
                        childCount: menuState.menu!.dishes.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateSelectorStrip extends StatelessWidget {
  const _DateSelectorStrip({required this.selectedDate, required this.onDateSelected});
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 5 days: today and next 4 days
    final days = List.generate(5, (i) => now.add(Duration(days: i)));

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;

          return GestureDetector(
            onTap: () => onDateSelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'fr_FR').format(day).toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CutoffBanner extends StatelessWidget {
  const _CutoffBanner({required this.isPastCutoff, required this.countdown});
  final bool isPastCutoff;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final bg = isPastCutoff ? AppColors.statusCancelledBg : AppColors.secondaryContainer;
    final fg = isPastCutoff ? AppColors.statusCancelled : AppColors.secondaryDark;
    final icon = isPastCutoff ? Icons.access_time_filled_rounded : Icons.timer_outlined;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              countdown,
              style: AppTextStyles.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          Text(
            'Clôture à 10h00',
            style: AppTextStyles.caption.copyWith(color: fg.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _EligibilityHeaderCard extends StatelessWidget {
  const _EligibilityHeaderCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final (badgeText, badgeBg, badgeFg) = switch (user.eligibility) {
      EligibilityType.scholarship => ('Boursier de l\'État', AppColors.primaryContainer, AppColors.primary),
      EligibilityType.subscribed => ('Abonnement actif', AppColors.secondaryContainer, AppColors.secondaryDark),
      EligibilityType.none => ('Non abonné', AppColors.statusCancelledBg, AppColors.statusCancelled),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text('Matricule : ${user.matricule}', style: AppTextStyles.caption),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: AppTextStyles.caption.copyWith(color: badgeFg, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.dish,
    required this.canOrder,
    required this.onOrder,
  });

  final Dish dish;
  final bool canOrder;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final isAvailable = dish.availablePortions > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dish.name, style: AppTextStyles.h3),
                      const SizedBox(height: 6),
                      Text(dish.description, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? AppColors.statusServedBg : AppColors.statusCancelledBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAvailable ? '${dish.availablePortions} restants' : 'Épuisé',
                    style: AppTextStyles.caption.copyWith(
                      color: isAvailable ? AppColors.statusServed : AppColors.statusCancelled,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                AppButton(
                  text: isAvailable ? 'Commander ce plat' : 'Indisponible',
                  fullWidth: false,
                  variant: isAvailable && canOrder ? ButtonVariant.primary : ButtonVariant.outline,
                  onPressed: isAvailable && canOrder ? onOrder : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
