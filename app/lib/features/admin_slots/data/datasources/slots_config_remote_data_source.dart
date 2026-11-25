import 'package:dio/dio.dart';

import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/features/admin_slots/domain/entities/slots_config.dart';

abstract interface class SlotsConfigRemoteDataSource {
  Future<SlotsConfig> load();
  Future<void> save(SlotsConfig config);
}

class SlotsConfigRemoteDataSourceImpl implements SlotsConfigRemoteDataSource {
  SlotsConfigRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<SlotsConfig> load() async {
    final j = await _dio.requestMap('GET', '/slots/config');
    return SlotsConfig(
      cutoffTime: jsonStringOrNull(j, 'cutoffTime') ?? '10:00',
      slots: [
        for (final s in (j['slots'] as List? ?? const []))
          SlotConfig(
            id: jsonString(asJsonMap(s), 'id'),
            label: jsonString(asJsonMap(s), 'label'),
            capacity: jsonInt(asJsonMap(s), 'capacity'),
            active: asJsonMap(s)['active'] != false,
          ),
      ],
    );
  }

  @override
  Future<void> save(SlotsConfig config) async {
    await _dio.requestMap(
      'PUT',
      '/slots/config',
      data: {
        'cutoffTime': config.cutoffTime,
        'slots': [
          for (final s in config.slots) {'id': s.id, 'capacity': s.capacity, 'active': s.active},
        ],
      },
    );
  }
}
