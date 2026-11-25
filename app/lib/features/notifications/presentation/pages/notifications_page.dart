import 'package:flutter/material.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      (
        title: 'Repas prêt à être servi !',
        message: 'Votre commande pour le créneau 11h30 - 12h00 est prête au comptoir.',
        time: 'Il y a 10 minutes',
        isRead: false,
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.statusReady,
      ),
      (
        title: 'Rappel clôture des commandes',
        message: 'Plus que 30 minutes avant la fermeture des commandes de midi (10h00).',
        time: 'Il y a 2 heures',
        isRead: true,
        icon: Icons.alarm_rounded,
        color: AppColors.secondaryDark,
      ),
      (
        title: 'Menu de la semaine publié',
        message: 'Découvrez les plats proposés à la cantine universitaire cette semaine.',
        time: 'Hier',
        isRead: true,
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.primary,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Card(
            color: n.isRead ? AppColors.surface : AppColors.primaryContainer.withValues(alpha: 0.25),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: n.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(n.icon, color: n.color, size: 22),
              ),
              title: Text(n.title, style: AppTextStyles.titleMedium),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(n.message, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  Text(n.time, style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
