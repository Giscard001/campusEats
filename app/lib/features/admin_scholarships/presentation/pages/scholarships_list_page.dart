import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/features/admin_scholarships/domain/entities/scholarship.dart';
import 'package:campuseats/features/admin_scholarships/domain/repositories/scholarships_repository.dart';

class ScholarshipsListPage extends StatefulWidget {
  const ScholarshipsListPage({super.key});

  @override
  State<ScholarshipsListPage> createState() => _ScholarshipsListPageState();
}

class _ScholarshipsListPageState extends State<ScholarshipsListPage> {
  final _repository = sl<ScholarshipsRepository>();
  List<Scholar> _scholars = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadScholars();
  }

  Future<void> _loadScholars() async {
    setState(() => _isLoading = true);
    final res = await _repository.list(query: _query);
    res.when(
      success: (paged) => setState(() {
        _scholars = paged.items;
        _isLoading = false;
      }),
      failure: (_) => setState(() => _isLoading = false),
    );
  }

  Future<void> _addSingleScholar() async {
    final matCtrl = TextEditingController();
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un boursier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: matCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Matricule *')),
            const SizedBox(height: 10),
            TextField(controller: firstCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Prénom *')),
            const SizedBox(height: 10),
            TextField(controller: lastCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nom *')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (matCtrl.text.isNotEmpty && firstCtrl.text.isNotEmpty && lastCtrl.text.isNotEmpty) {
                await _repository.add(
                  lastName: lastCtrl.text.trim(),
                  firstName: firstCtrl.text.trim(),
                  matricule: matCtrl.text.trim(),
                );
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true) _loadScholars();
  }

  Future<void> _importCsv() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (picked != null && picked.files.isNotEmpty) {
      final file = picked.files.first;
      final bytes = file.bytes ?? utf8.encode('matricule,nom,prenom\nSTU999,Diallo,Issa');

      final res = await _repository.importCsv(
        fileName: file.name,
        bytes: bytes,
      );

      res.when(
        success: (importRes) {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Rapport d\'importation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Boursiers ajoutés : ${importRes.added}'),
                  Text('• Doublons ignorés : ${importRes.duplicates}'),
                  Text('• Erreurs de ligne : ${importRes.errors.length}'),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
              ],
            ),
          );
          _loadScholars();
        },
        failure: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Liste des boursiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Importer un fichier CSV',
            onPressed: _importCsv,
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Ajouter manuellement',
            onPressed: _addSingleScholar,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (q) {
                _query = q;
                _loadScholars();
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher un boursier...',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_scholars.isEmpty
                    ? const EmptyView(
                        title: 'Aucun boursier trouvé',
                        message: 'Importez un fichier CSV ou ajoutez un boursier manuellement.',
                        icon: Icons.school_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _scholars.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final s = _scholars[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                child: Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                              ),
                              title: Text(s.fullName, style: AppTextStyles.titleMedium),
                              subtitle: Text('Matricule : ${s.matricule}', style: AppTextStyles.caption),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusCancelled),
                                onPressed: () async {
                                  await _repository.delete(s.id);
                                  _loadScholars();
                                },
                              ),
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
