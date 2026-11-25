import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/features/admin_stats/data/datasources/stats_remote_data_source.dart';
import 'package:campuseats/features/admin_stats/domain/entities/stats_report.dart';
import 'package:campuseats/features/admin_stats/domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl(this._remote);

  final StatsRemoteDataSource _remote;

  @override
  Future<Result<StatsReport>> stats({required DateTime from, required DateTime to}) =>
      guardRequest(() => _remote.stats(from: from, to: to));
}
