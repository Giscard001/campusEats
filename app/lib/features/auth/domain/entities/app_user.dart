import 'package:equatable/equatable.dart';

enum UserRole {
  student,
  staff,
  admin;

  static UserRole fromString(String? role) => switch (role?.toLowerCase()) {
        'admin' => UserRole.admin,
        'staff' => UserRole.staff,
        _ => UserRole.student,
      };

  String get label => switch (this) {
        UserRole.student => 'Étudiant',
        UserRole.staff => 'Personnel cantine',
        UserRole.admin => 'Administrateur',
      };
}

enum AccountStatus {
  active,
  pending,
  suspended;

  static AccountStatus fromString(String? status) => switch (status?.toLowerCase()) {
        'pending' => AccountStatus.pending,
        'suspended' => AccountStatus.suspended,
        _ => AccountStatus.active,
      };

  String get label => switch (this) {
        AccountStatus.active => 'Actif',
        AccountStatus.pending => 'En attente',
        AccountStatus.suspended => 'Suspendu',
      };
}

enum EligibilityType {
  scholarship,
  subscribed,
  none;

  static EligibilityType fromString(String? type) => switch (type?.toLowerCase()) {
        'scholarship' || 'boursier' => EligibilityType.scholarship,
        'subscribed' || 'abonne' => EligibilityType.subscribed,
        _ => EligibilityType.none,
      };

  String get label => switch (this) {
        EligibilityType.scholarship => 'Boursier',
        EligibilityType.subscribed => 'Abonné',
        EligibilityType.none => 'Non éligible',
      };
}

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.matricule,
    required this.role,
    this.status = AccountStatus.active,
    this.eligibility = EligibilityType.none,
    this.className,
    this.subscriptionEnd,
    this.photoUrl,
    this.email,
    this.phone,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String matricule;
  final UserRole role;
  final AccountStatus status;
  final EligibilityType eligibility;
  final String? className;
  final DateTime? subscriptionEnd;
  final String? photoUrl;
  final String? email;
  final String? phone;

  String get fullName => '$firstName $lastName';

  bool get isStudent => role == UserRole.student;
  bool get isStaff => role == UserRole.staff;
  bool get isAdmin => role == UserRole.admin;
  bool get isPending => status == AccountStatus.pending;
  bool get isActive => status == AccountStatus.active;
  bool get isScholarship => eligibility == EligibilityType.scholarship;
  bool get isSubscribed => eligibility == EligibilityType.subscribed;

  bool get canOrder {
    if (!isStudent || !isActive) return false;
    if (isScholarship) return true;
    if (isSubscribed && subscriptionEnd != null) {
      return subscriptionEnd!.isAfter(DateTime.now());
    }
    return false;
  }

  AppUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? matricule,
    UserRole? role,
    AccountStatus? status,
    EligibilityType? eligibility,
    String? className,
    DateTime? subscriptionEnd,
    String? photoUrl,
    String? email,
    String? phone,
  }) {
    return AppUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      matricule: matricule ?? this.matricule,
      role: role ?? this.role,
      status: status ?? this.status,
      eligibility: eligibility ?? this.eligibility,
      className: className ?? this.className,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        matricule,
        role,
        status,
        eligibility,
        className,
        subscriptionEnd,
        photoUrl,
        email,
        phone,
      ];
}
