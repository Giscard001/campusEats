import 'package:flutter/material.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/features/admin_scholarships/domain/entities/scholarship.dart';
import 'package:campuseats/features/admin_scholarships/domain/repositories/scholarships_repository.dart';

class PendingAccountsPage extends StatefulWidget {
  const PendingAccountsPage({super.key});

  @override
  State<PendingAccountsPage> createState() => _PendingAccountsPageState();
}

class _PendingAccountsPageState extends State<PendingAccountsPage> {
  final _repository = sl<PendingAccountsRepository>();
  List<PendingAccount> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    final res = await _repository.pending();
    res.when(
      success: (list) => setState(() {
        _pending = list;
        _isLoading = false;
      }),
      failure: (_) => setState(() => _isLoading = false),
    );
  }

  Future<void> _handleApproval(PendingAccount account, bool asScholarship) async {
    await _repository.approve(account.id, asScholarship: asScholarship);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(asScholarship
            ? 'Compte de ${account.fullName} approuvé en tant que boursier !'
            : 'Compte activé sans statut boursier.'),
      ),
    );
    _loadPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comptes en attente'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_pending.isEmpty
              ? const EmptyView(
                  title: 'Aucun compte en attente',
                  message: 'Toutes les demandes d\'inscription ont été traitées.',
                  icon: Icons.check_circle_outline_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final acc = _pending[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(acc.fullName, style: AppTextStyles.h3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusPendingBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('À valider', style: TextStyle(color: AppColors.statusPending, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Matricule : ${acc.matricule}', style: AppTextStyles.bodyMedium),
                            if (acc.className != null) Text('Promotion : ${acc.className}', style: AppTextStyles.caption),
                            const SizedBox(height: 12),
                            if (acc.candidate != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Correspondance trouvée dans la liste officielle : ${acc.candidate!.fullName}',
                                        style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _handleApproval(acc, false),
                                  child: const Text('Activer sans bourse'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  onPressed: () => _handleApproval(acc, true),
                                  child: const Text('Valider boursier'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
    );
  }
}
