import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/features/admin_scholarships/data/datasources/scholarships_remote_data_source.dart';
import 'package:campuseats/features/admin_scholarships/domain/entities/scholarship.dart';
import 'package:campuseats/features/admin_scholarships/domain/repositories/scholarships_repository.dart';

class ScholarshipsRepositoryImpl implements ScholarshipsRepository, PendingAccountsRepository {
  ScholarshipsRepositoryImpl(this._remote);

  final ScholarshipsRemoteDataSource _remote;

  @override
  Future<Result<PagedResult<Scholar>>> list({String? query, int page = 1}) =>
      guardRequest(() => _remote.list(query: query, page: page));

  @override
  Future<Result<Scholar>> add({required String lastName, required String firstName, required String matricule}) =>
      guardRequest(() => _remote.add(lastName: lastName, firstName: firstName, matricule: matricule));

  @override
  Future<Result<void>> delete(String id) => guardRequest(() => _remote.delete(id));

  @override
  Future<Result<ImportResult>> importCsv({required String fileName, required List<int> bytes}) =>
      guardRequest(() => _remote.importCsv(fileName: fileName, bytes: bytes));

  @override
  Future<Result<List<PendingAccount>>> pending() => guardRequest(_remote.pending);

  @override
  Future<Result<void>> approve(String id, {required bool asScholarship}) =>
      guardRequest(() => _remote.approve(id, asScholarship: asScholarship));
}
