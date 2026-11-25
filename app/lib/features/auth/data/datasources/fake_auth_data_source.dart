import 'dart:async';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

class FakeAuthDataSource implements AuthRemoteDataSource {
  FakeAuthDataSource() {
    _initMockUsers();
  }

  final Map<String, ({AppUser user, String password})> _users = {};
  final Set<String> _scholarshipMatricules = {'STU001', 'STU002', 'BOURSE2026', '2024-BF-001'};

  void _initMockUsers() {
    // 1. Student - Boursier
    _users['STU001'] = (
      user: AppUser(
        id: 'usr_stu_1',
        firstName: 'Ousmane',
        lastName: 'Sawadogo',
        matricule: 'STU001',
        role: UserRole.student,
        status: AccountStatus.active,
        eligibility: EligibilityType.scholarship,
        className: 'Licence 3 Informatique',
        email: 'ousmane.sawadogo@univ-ouaga.bf',
        phone: '+226 70 12 34 56',
      ),
      password: 'password123',
    );

    // 2. Student - Abonné non-boursier
    _users['STU002'] = (
      user: AppUser(
        id: 'usr_stu_2',
        firstName: 'Aminata',
        lastName: 'Ouedraogo',
        matricule: 'STU002',
        role: UserRole.student,
        status: AccountStatus.active,
        eligibility: EligibilityType.subscribed,
        className: 'Master 1 Gestion',
        subscriptionEnd: DateTime.now().add(const Duration(days: 25)),
        email: 'aminata.ouedraogo@univ-ouaga.bf',
        phone: '+226 76 98 76 54',
      ),
      password: 'password123',
    );

    // 3. Student - Non éligible (abonnement expiré)
    _users['STU003'] = (
      user: AppUser(
        id: 'usr_stu_3',
        firstName: 'Moussa',
        lastName: 'Kabore',
        matricule: 'STU003',
        role: UserRole.student,
        status: AccountStatus.active,
        eligibility: EligibilityType.none,
        className: 'Licence 1 Droit',
        subscriptionEnd: DateTime.now().subtract(const Duration(days: 5)),
        email: 'moussa.kabore@univ-ouaga.bf',
      ),
      password: 'password123',
    );

    // 4. Student - En attente de validation
    _users['PEND01'] = (
      user: const AppUser(
        id: 'usr_pend_1',
        firstName: 'Fatou',
        lastName: 'Diallo',
        matricule: 'PEND01',
        role: UserRole.student,
        status: AccountStatus.pending,
        eligibility: EligibilityType.none,
        className: 'Licence 2 Économie',
        email: 'fatou.diallo@univ-ouaga.bf',
      ),
      password: 'password123',
    );

    // 5. Staff cantine
    _users['STAFF01'] = (
      user: const AppUser(
        id: 'usr_staff_1',
        firstName: 'Salif',
        lastName: 'Traore',
        matricule: 'STAFF01',
        role: UserRole.staff,
        status: AccountStatus.active,
        email: 'salif.traore@cantine.bf',
      ),
      password: 'password123',
    );

    // 6. Admin cantine
    _users['ADMIN01'] = (
      user: const AppUser(
        id: 'usr_admin_1',
        firstName: 'Zalissa',
        lastName: 'Kindo',
        matricule: 'ADMIN01',
        role: UserRole.admin,
        status: AccountStatus.active,
        email: 'zalissa.kindo@cantine.bf',
      ),
      password: 'password123',
    );
  }

  AppUser? _currentUser;

  @override
  Future<({AppUser user, String accessToken, String refreshToken})> login({
    required String matricule,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final entry = _users[matricule.toUpperCase().trim()];
    if (entry == null || entry.password != password) {
      throw const UnauthorizedFailure('Matricule ou mot de passe incorrect.');
    }
    _currentUser = entry.user;
    return (
      user: entry.user,
      accessToken: 'fake_access_token_${entry.user.id}',
      refreshToken: 'fake_refresh_token_${entry.user.id}',
    );
  }

  @override
  Future<bool> checkScholarship({
    required String matricule,
    required String lastName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _scholarshipMatricules.contains(matricule.toUpperCase().trim());
  }

  @override
  Future<({AppUser user, String? accessToken, String? refreshToken})> register({
    required String matricule,
    required String firstName,
    required String lastName,
    required String password,
    String? className,
    required bool isScholarship,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final upperMat = matricule.toUpperCase().trim();
    if (_users.containsKey(upperMat)) {
      throw const ConflictFailure('Ce matricule possède déjà un compte.');
    }

    final isActuallyScholar = isScholarship && _scholarshipMatricules.contains(upperMat);
    final status = (isScholarship && !isActuallyScholar) ? AccountStatus.pending : AccountStatus.active;
    final eligibility = isActuallyScholar ? EligibilityType.scholarship : EligibilityType.none;

    final newUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      matricule: upperMat,
      role: UserRole.student,
      status: status,
      eligibility: eligibility,
      className: className,
    );

    _users[upperMat] = (user: newUser, password: password);
    _currentUser = newUser;

    return (
      user: newUser,
      accessToken: status == AccountStatus.active ? 'fake_access_${newUser.id}' : null,
      refreshToken: status == AccountStatus.active ? 'fake_refresh_${newUser.id}' : null,
    );
  }

  @override
  Future<AppUser> currentUser() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_currentUser == null) {
      throw const UnauthorizedFailure('Non authentifié');
    }
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
  }
}
