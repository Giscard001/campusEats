import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/empty_view.dart';
import 'package:campuseats/features/admin_users/domain/repositories/users_repository.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final _repository = sl<UsersRepository>();
  UserFilter _filter = UserFilter.all;
  String _query = '';
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final res = await _repository.list(filter: _filter, query: _query);
    res.when(
      success: (paged) => setState(() {
        _users = paged.items;
        _isLoading = false;
      }),
      failure: (_) => setState(() => _isLoading = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Créer compte personnel'),
        onPressed: () async {
          await context.push('/admin/users/create-staff');
          _loadUsers();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (q) {
                _query = q;
                _loadUsers();
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher par nom ou matricule...',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _TabChip('Tous', _filter == UserFilter.all, () => _setFilter(UserFilter.all)),
                const SizedBox(width: 8),
                _TabChip('Étudiants', _filter == UserFilter.student, () => _setFilter(UserFilter.student)),
                const SizedBox(width: 8),
                _TabChip('Personnel cantine', _filter == UserFilter.staff, () => _setFilter(UserFilter.staff)),
                const SizedBox(width: 8),
                _TabChip('Administrateurs', _filter == UserFilter.admin, () => _setFilter(UserFilter.admin)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_users.isEmpty
                    ? const EmptyView(
                        title: 'Aucun utilisateur trouvé',
                        icon: Icons.people_outline_rounded,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final u = _users[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: switch (u.role) {
                                  UserRole.admin => Colors.purple.shade100,
                                  UserRole.staff => AppColors.secondaryContainer,
                                  UserRole.student => AppColors.primaryContainer,
                                },
                                child: Text(
                                  u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: switch (u.role) {
                                      UserRole.admin => Colors.purple,
                                      UserRole.staff => AppColors.secondaryDark,
                                      UserRole.student => AppColors.primary,
                                    },
                                  ),
                                ),
                              ),
                              title: Text(u.fullName, style: AppTextStyles.titleMedium),
                              subtitle: Text('${u.role.label} • ${u.matricule}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: u.isActive ? AppColors.statusServedBg : AppColors.statusCancelledBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  u.status.label,
                                  style: TextStyle(
                                    color: u.isActive ? AppColors.statusServed : AppColors.statusCancelled,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

  void _setFilter(UserFilter f) {
    setState(() => _filter = f);
    _loadUsers();
  }

  Widget _TabChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
