import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/admin_scholarships/domain/entities/scholarship.dart';

abstract interface class ScholarshipsRepository {
  Future<Result<PagedResult<Scholar>>> list({String? query, int page = 1});
  Future<Result<Scholar>> add({required String lastName, required String firstName, required String matricule});
  Future<Result<void>> delete(String id);
  Future<Result<ImportResult>> importCsv({required String fileName, required List<int> bytes});
}

abstract interface class PendingAccountsRepository {
  Future<Result<List<PendingAccount>>> pending();
  Future<Result<void>> approve(String id, {required bool asScholarship});
}
