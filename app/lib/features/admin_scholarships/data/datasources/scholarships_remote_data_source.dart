import 'package:dio/dio.dart';

import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/features/admin_scholarships/data/models/scholarship_model.dart';
import 'package:campuseats/features/admin_scholarships/domain/entities/scholarship.dart';

abstract interface class ScholarshipsRemoteDataSource {
  Future<PagedResult<Scholar>> list({String? query, int page = 1});
  Future<Scholar> add({required String lastName, required String firstName, required String matricule});
  Future<void> delete(String id);
  Future<ImportResult> importCsv({required String fileName, required List<int> bytes});
  Future<List<PendingAccount>> pending();
  Future<void> approve(String id, {required bool asScholarship});
}

class ScholarshipsRemoteDataSourceImpl implements ScholarshipsRemoteDataSource {
  ScholarshipsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedResult<Scholar>> list({String? query, int page = 1}) async => pagedFromJson(
        await _dio.requestMap(
          'GET',
          '/scholarships',
          query: {if (query != null && query.isNotEmpty) 'q': query, 'page': page, 'limit': 20},
        ),
        ScholarshipModel.scholarFromJson,
      );

  @override
  Future<Scholar> add({required String lastName, required String firstName, required String matricule}) async =>
      ScholarshipModel.scholarFromJson(
        await _dio.requestMap(
          'POST',
          '/scholarships',
          data: {'lastName': lastName, 'firstName': firstName, 'matricule': matricule},
        ),
      );

  @override
  Future<void> delete(String id) async {
    await _dio.requestMap('DELETE', '/scholarships/$id');
  }

  @override
  Future<ImportResult> importCsv({required String fileName, required List<int> bytes}) async {
    final form = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: fileName)});
    return ScholarshipModel.importResultFromJson(await _dio.requestMap('POST', '/scholarships/import', data: form));
  }

  @override
  Future<List<PendingAccount>> pending() async => [
        for (final j in await _dio.requestList('GET', '/accounts/pending')) ScholarshipModel.pendingFromJson(j),
      ];

  @override
  Future<void> approve(String id, {required bool asScholarship}) async {
    await _dio.requestMap('POST', '/accounts/$id/approve', data: {'asScholarship': asScholarship});
  }
}
