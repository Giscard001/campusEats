import 'package:dio/dio.dart';

import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/admin_stats/domain/entities/stats_report.dart';

abstract interface class StatsRemoteDataSource {
  Future<StatsReport> stats({required DateTime from, required DateTime to});
}

/// Forme supposée de GET /stats (à confirmer) :
/// `{mealsPerDay:[{date,count}], popularDishes:[{name,count}], scholarshipCount, subscribedCount,
///   slotFill:[{label,rate}], expiring:[{name,endsAt}]}`
class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  StatsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<StatsReport> stats({required DateTime from, required DateTime to}) async {
    final j = await _dio.requestMap('GET', '/stats', query: {'from': Fmt.apiDate(from), 'to': Fmt.apiDate(to)});
    List<Map<String, dynamic>> list(String key) => [for (final e in (j[key] as List? ?? const [])) asJsonMap(e)];
    return StatsReport(
      mealsPerDay: [
        for (final e in list('mealsPerDay')) DayCount(date: Fmt.parseApiDate(jsonString(e, 'date')), count: jsonInt(e, 'count')),
      ],
      popularDishes: [for (final e in list('popularDishes')) NamedCount(name: jsonString(e, 'name'), count: jsonInt(e, 'count'))],
      scholarshipCount: jsonInt(j, 'scholarshipCount'),
      subscribedCount: jsonInt(j, 'subscribedCount'),
      slotFill: [for (final e in list('slotFill')) SlotFill(label: jsonString(e, 'label'), rate: (e['rate'] as num?)?.toDouble() ?? 0)],
      expiring: [
        for (final e in list('expiring'))
          ExpiringSubscription(name: jsonString(e, 'name'), endsAt: jsonDateOrNull(e, 'endsAt') ?? DateTime.now().toUtc()),
      ],
    );
  }
}
