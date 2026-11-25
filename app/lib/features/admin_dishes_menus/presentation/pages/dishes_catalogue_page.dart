import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/repositories/dishes_repository.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

class DishesCataloguePage extends StatefulWidget {
  const DishesCataloguePage({super.key});

  @override
  State<DishesCataloguePage> createState() => _DishesCataloguePageState();
}

class _DishesCataloguePageState extends State<DishesCataloguePage> {
  final _repository = sl<DishesRepository>();
  List<Dish> _dishes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);
    final res = await _repository.list();
    res.when(
      success: (dishes) => setState(() {
        _dishes = dishes;
        _isLoading = false;
      }),
      failure: (_) => setState(() => _isLoading = false),
    );
  }

  Future<void> _deleteDish(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce plat ?'),
        content: Text('Voulez-vous vraiment supprimer "$name" du catalogue ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCancelled),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.delete(id);
      _loadDishes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catalogue des plats'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter un plat'),
        onPressed: () async {
          await context.push('/admin/dishes/add');
          _loadDishes();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_dishes.isEmpty
              ? const EmptyView(
                  title: 'Aucun plat dans le catalogue',
                  message: 'Cliquez sur "Ajouter un plat" pour créer la première recette.',
                  icon: Icons.restaurant_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _dishes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dish = _dishes[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.restaurant_rounded, color: AppColors.primary),
                        ),
                        title: Text(dish.name, style: AppTextStyles.titleMedium),
                        subtitle: Text(dish.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusCancelled),
                          onPressed: () => _deleteDish(dish.id, dish.name),
                        ),
                      ),
                    );
                  },
                )),
    );
  }
}
