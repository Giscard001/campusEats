import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/repositories/dishes_repository.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

class AddDishPage extends StatefulWidget {
  const AddDishPage({super.key});

  @override
  State<AddDishPage> createState() => _AddDishPageState();
}

class _AddDishPageState extends State<AddDishPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      setState(() => _errorMessage = 'Veuillez renseigner le nom et la description du plat.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final res = await sl<DishesRepository>().save(
      input: DishInput(name: name, description: desc),
    );

    res.when(
      success: (_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plat ajouté au catalogue avec succès !')),
        );
      },
      failure: (f) => setState(() {
        _isSaving = false;
        _errorMessage = f.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajouter un plat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Informations sur la recette', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            const Text(
              'Ce plat sera disponible dans le planificateur de menu.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text('Nom du plat *', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ex: Riz gras au bœuf & légumes locaux',
                prefixIcon: Icon(Icons.lunch_dining_rounded),
              ),
            ),
            const SizedBox(height: 18),

            Text('Description & Ingrédients *', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Détaillez les ingrédients, accompagnements et allergènes éventuels...',
              ),
            ),
            const SizedBox(height: 24),

            // Photo placeholder / picker
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary),
                  const SizedBox(height: 10),
                  const Text('Photo du plat (facultatif)', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  const Text('Format JPG ou PNG jusqu\'à 5 Mo', style: AppTextStyles.caption),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.statusCancelled, fontSize: 13)),
            ],
            const SizedBox(height: 32),

            AppButton(
              text: 'Enregistrer le plat',
              isLoading: _isSaving,
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
