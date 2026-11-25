import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administration Cantine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            const Text('Aperçu en temps réel', style: AppTextStyles.h2),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    title: 'Repas servis',
                    value: '142',
                    total: '/ 180 prévus',
                    icon: Icons.done_all_rounded,
                    color: AppColors.statusServed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    title: 'Comptes en attente',
                    value: '3',
                    total: 'à valider',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.statusPending,
                    onTap: () => context.push('/admin/pending-accounts'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    title: 'Boursiers actifs',
                    value: '350',
                    total: 'étudiants',
                    icon: Icons.school_rounded,
                    color: AppColors.primary,
                    onTap: () => context.push('/admin/scholarships'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    title: 'Abonnements',
                    value: '124',
                    total: 'ce mois-ci',
                    icon: Icons.card_membership_rounded,
                    color: AppColors.secondaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Modules Grid / List
            const Text('Gestion des opérations', style: AppTextStyles.h2),
            const SizedBox(height: 14),

            _AdminModuleTile(
              title: 'Catalogue des plats',
              subtitle: 'Créer, modifier et gérer les recettes du menu',
              icon: Icons.restaurant_menu_rounded,
              color: AppColors.primary,
              onTap: () => context.push('/admin/dishes'),
            ),
            const SizedBox(height: 10),
            _AdminModuleTile(
              title: 'Planificateur hebdomadaire',
              subtitle: 'Assigner les plats aux jours et publier le calendrier',
              icon: Icons.calendar_month_rounded,
              color: AppColors.secondaryDark,
              onTap: () => context.push('/admin/menu-planner'),
            ),
            const SizedBox(height: 10),
            _AdminModuleTile(
              title: 'Créneaux & Heure limite',
              subtitle: 'Ajuster les jauges de passage et l\'heure de clôture (10h00)',
              icon: Icons.more_time_rounded,
              color: Colors.teal,
              onTap: () => context.push('/admin/slots-config'),
            ),
            const SizedBox(height: 10),
            _AdminModuleTile(
              title: 'Liste des boursiers & Import CSV',
              subtitle: 'Synchroniser le fichier des boursiers de l\'État',
              icon: Icons.upload_file_rounded,
              color: Colors.blueAccent,
              onTap: () => context.push('/admin/scholarships'),
            ),
            const SizedBox(height: 10),
            _AdminModuleTile(
              title: 'Comptes en attente de validation',
              subtitle: 'Examiner et approuver les demandes d\'inscription',
              icon: Icons.how_to_reg_rounded,
              color: Colors.deepOrange,
              badgeCount: 3,
              onTap: () => context.push('/admin/pending-accounts'),
            ),
            const SizedBox(height: 10),
            _AdminModuleTile(
              title: 'Utilisateurs & Personnel',
              subtitle: 'Gérer les comptes et créer les accès du personnel cantine',
              icon: Icons.people_alt_rounded,
              color: Colors.indigo,
              onTap: () => context.push('/admin/users'),
            ),
            const SizedBox(height: 10),
            _AdminModuleTile(
              title: 'Statistiques & Rapports d\'activité',
              subtitle: 'Remplissage des créneaux, plats populaires et export CSV',
              icon: Icons.bar_chart_rounded,
              color: Colors.purple,
              onTap: () => context.push('/admin/stats'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.total,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final String total;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary, fontSize: 24),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      total,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminModuleTile extends StatelessWidget {
  const _AdminModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusPending,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      ),
    );
  }
}
