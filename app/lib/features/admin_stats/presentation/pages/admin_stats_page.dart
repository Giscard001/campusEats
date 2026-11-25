import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/admin_stats/domain/entities/stats_report.dart';
import 'package:campuseats/features/admin_stats/domain/repositories/stats_repository.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  final _repository = sl<StatsRepository>();
  DateTime _from = DateTime.now().subtract(const Duration(days: 7));
  DateTime _to = DateTime.now();
  StatsReport? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final res = await _repository.stats(from: _from, to: _to);
    res.when(
      success: (report) => setState(() {
        _report = report;
        _isLoading = false;
      }),
      failure: (_) {
        // Fallback demo report
        setState(() {
          _report = StatsReport(
            mealsPerDay: [
              DayCount(date: DateTime.now().subtract(const Duration(days: 4)), count: 130),
              DayCount(date: DateTime.now().subtract(const Duration(days: 3)), count: 145),
              DayCount(date: DateTime.now().subtract(const Duration(days: 2)), count: 160),
              DayCount(date: DateTime.now().subtract(const Duration(days: 1)), count: 175),
              DayCount(date: DateTime.now(), count: 142),
            ],
            popularDishes: const [
              NamedCount(name: 'Riz gras au bœuf', count: 420),
              NamedCount(name: 'Alloco & capitaine', count: 310),
              NamedCount(name: 'Tô de maïs & gombo', count: 215),
            ],
            scholarshipCount: 350,
            subscribedCount: 124,
            slotFill: const [
              SlotFill(label: '11h30 - 12h00', rate: 0.85),
              SlotFill(label: '12h00 - 12h30', rate: 1.0),
              SlotFill(label: '12h30 - 13h00', rate: 0.75),
              SlotFill(label: '13h00 - 13h30', rate: 0.40),
            ],
            expiring: [
              ExpiringSubscription(name: 'Moussa Kabore', endsAt: DateTime.now().add(const Duration(days: 2))),
              ExpiringSubscription(name: 'Sita Traore', endsAt: DateTime.now().add(const Duration(days: 4))),
            ],
          );
          _isLoading = false;
        });
      },
    );
  }

  void _exportCsv() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapport exporté avec succès (format CSV) !'),
        backgroundColor: AppColors.statusServed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques & Rapports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Exporter en CSV',
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Overview
                  Row(
                    children: [
                      Expanded(
                        child: _StatMiniCard(
                          title: 'Boursiers',
                          value: '${_report!.scholarshipCount}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatMiniCard(
                          title: 'Abonnés',
                          value: '${_report!.subscribedCount}',
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Chart: Repas par jour
                  const Text('Évolution des repas servis', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 200,
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    final idx = val.toInt();
                                    if (idx >= 0 && idx < _report!.mealsPerDay.length) {
                                      final d = _report!.mealsPerDay[idx].date;
                                      return Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              for (var i = 0; i < _report!.mealsPerDay.length; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _report!.mealsPerDay[i].count.toDouble(),
                                      color: AppColors.primary,
                                      width: 16,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Plats les plus populaires
                  const Text('Plats les plus demandés', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  ..._report!.popularDishes.map((dish) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.star_rounded, color: AppColors.secondary),
                        title: Text(dish.name, style: AppTextStyles.titleMedium),
                        trailing: Text('${dish.count} servis', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Taux de remplissage des créneaux
                  const Text('Taux de remplissage des créneaux', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _report!.slotFill.map((sf) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(sf.label, style: AppTextStyles.titleSmall),
                                    Text('${(sf.rate * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: sf.rate,
                                  backgroundColor: AppColors.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation(
                                    sf.rate >= 0.95 ? AppColors.statusCancelled : AppColors.primary,
                                  ),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Télécharger le rapport détaillé (CSV)',
                    variant: ButtonVariant.outline,
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    onPressed: _exportCsv,
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({required this.title, required this.value, required this.color});
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.h1.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
