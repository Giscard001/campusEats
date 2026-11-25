import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/features/admin_scholarships/domain/entities/scholarship.dart';

abstract final class ScholarshipModel {
  static Scholar scholarFromJson(Map<String, dynamic> j) => Scholar(
        id: jsonString(j, 'id'),
        lastName: jsonString(j, 'lastName'),
        firstName: jsonString(j, 'firstName'),
        matricule: jsonString(j, 'matricule'),
      );

  static PendingAccount pendingFromJson(Map<String, dynamic> j) {
    final candidate = j['candidate'];
    return PendingAccount(
      id: jsonString(j, 'id'),
      lastName: jsonString(j, 'lastName'),
      firstName: jsonString(j, 'firstName'),
      matricule: jsonString(j, 'matricule'),
      className: jsonStringOrNull(j, 'className'),
      candidate: candidate is Map ? scholarFromJson(asJsonMap(candidate)) : null,
    );
  }

  static ImportResult importResultFromJson(Map<String, dynamic> j) => ImportResult(
        added: jsonInt(j, 'added'),
        duplicates: jsonInt(j, 'duplicates'),
        errors: [
          for (final e in (j['errors'] as List? ?? const []))
            ImportLineError(line: jsonInt(asJsonMap(e), 'line'), message: jsonStringOrNull(asJsonMap(e), 'message') ?? ''),
        ],
      );
}
