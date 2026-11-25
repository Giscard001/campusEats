import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/features/auth/domain/entities/app_user.dart';

abstract final class UserModel {
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: jsonString(json, 'id'),
      firstName: jsonString(json, 'firstName'),
      lastName: jsonString(json, 'lastName'),
      matricule: jsonString(json, 'matricule'),
      role: UserRole.fromString(jsonStringOrNull(json, 'role')),
      status: AccountStatus.fromString(jsonStringOrNull(json, 'status')),
      eligibility: EligibilityType.fromString(jsonStringOrNull(json, 'eligibility')),
      className: jsonStringOrNull(json, 'className'),
      subscriptionEnd: jsonDateOrNull(json, 'subscriptionEnd'),
      photoUrl: jsonStringOrNull(json, 'photoUrl'),
      email: jsonStringOrNull(json, 'email'),
      phone: jsonStringOrNull(json, 'phone'),
    );
  }

  static Map<String, dynamic> toJson(AppUser user) => {
        'id': user.id,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'matricule': user.matricule,
        'role': user.role.name,
        'status': user.status.name,
        'eligibility': user.eligibility.name,
        if (user.className != null) 'className': user.className,
        if (user.subscriptionEnd != null) 'subscriptionEnd': user.subscriptionEnd!.toIso8601String(),
        if (user.photoUrl != null) 'photoUrl': user.photoUrl,
        if (user.email != null) 'email': user.email,
        if (user.phone != null) 'phone': user.phone,
      };
}
