import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/admin_users/domain/repositories/users_repository.dart';

class CreateStaffAccountPage extends StatefulWidget {
  const CreateStaffAccountPage({super.key});

  @override
  State<CreateStaffAccountPage> createState() => _CreateStaffAccountPageState();
}

class _CreateStaffAccountPageState extends State<CreateStaffAccountPage> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _matriculeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSaving = false;
  String? _error;

  Future<void> _submit() async {
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    final mat = _matriculeCtrl.text.trim();
    final pwd = _passwordCtrl.text.trim();

    if (first.isEmpty || last.isEmpty || mat.isEmpty || pwd.isEmpty) {
      setState(() => _error = 'Veuillez remplir tous les champs obligatoires.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final res = await sl<UsersRepository>().createStaff(
      firstName: first,
      lastName: last,
      matricule: mat,
      password: pwd,
    );

    res.when(
      success: (_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte du personnel cantine créé avec succès !')),
        );
      },
      failure: (f) => setState(() {
        _isSaving = false;
        _error = f.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un compte personnel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Accès Agent Cantine', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            const Text(
              'Ce compte permettra à l\'agent de scanner les QR codes et de gérer les abonnements au guichet.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            TextField(controller: _matriculeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Matricule / Identifiant agent *')),
            const SizedBox(height: 16),
            TextField(controller: _firstNameCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Prénom *')),
            const SizedBox(height: 16),
            TextField(controller: _lastNameCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nom *')),
            const SizedBox(height: 16),
            TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe temporaire *')),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.statusCancelled, fontSize: 13)),
            ],
            const SizedBox(height: 32),
            AppButton(
              text: 'Créer le compte agent',
              isLoading: _isSaving,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
