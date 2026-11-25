import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/admin_stats/domain/entities/stats_report.dart';

abstract interface class StatsRepository {
  Future<Result<StatsReport>> stats({required DateTime from, required DateTime to});
}
