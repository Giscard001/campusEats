import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/entities/menu_item_input.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/repositories/dishes_repository.dart';

class MenuPlannerPage extends StatefulWidget {
  const MenuPlannerPage({super.key});

  @override
  State<MenuPlannerPage> createState() => _MenuPlannerPageState();
}

class _MenuPlannerPageState extends State<MenuPlannerPage> {
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isPublished = true;

  final List<Map<String, dynamic>> _plannedDishes = [
    {'dishId': 'dish_1', 'name': 'Riz gras au bœuf & légumes locaux', 'portions': 120},
    {'dishId': 'dish_2', 'name': 'Tô de maïs & sauce gombo frais', 'portions': 80},
    {'dishId': 'dish_4', 'name': 'Alloco & poisson capitaine braisé', 'portions': 100},
  ];

  Future<void> _savePlan() async {
    setState(() => _isSaving = true);
    final items = [
      for (final p in _plannedDishes)
        MenuItemInput(dishId: p['dishId'], portions: p['portions']),
    ];

    final res = await sl<MenuPlannerRepository>().saveMenu(
      date: _selectedDate,
      items: items,
      published: _isPublished,
    );

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu hebdomadaire enregistré avec succès !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planificateur de menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Selector Row
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date de programmation', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 7)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Published switch
            Card(
              child: SwitchListTile(
                title: const Text('Publier ce menu aux étudiants', style: AppTextStyles.titleMedium),
                subtitle: const Text('Si désactivé, le menu reste en brouillon invisible.'),
                value: _isPublished,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isPublished = v),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Plats proposés ce jour', style: AppTextStyles.h2),
            const SizedBox(height: 12),

            ..._plannedDishes.map((dish) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dish['name'], style: AppTextStyles.titleSmall),
                            const SizedBox(height: 2),
                            Text('Portions prévues : ${dish['portions']}', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: dish['portions'] > 10
                            ? () => setState(() => dish['portions'] -= 10)
                            : null,
                      ),
                      Text('${dish['portions']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: () => setState(() => dish['portions'] += 10),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            AppButton(
              text: 'Enregistrer et publier le menu',
              isLoading: _isSaving,
              icon: const Icon(Icons.save_rounded, size: 18),
              onPressed: _savePlan,
            ),
          ],
        ),
      ),
    );
  }
}
