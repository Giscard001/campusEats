import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/features/admin_slots/data/datasources/slots_config_remote_data_source.dart';
import 'package:campuseats/features/admin_slots/domain/entities/slots_config.dart';
import 'package:campuseats/features/admin_slots/domain/repositories/slots_config_repository.dart';

class SlotsConfigRepositoryImpl implements SlotsConfigRepository {
  SlotsConfigRepositoryImpl(this._remote);

  final SlotsConfigRemoteDataSource _remote;

  @override
  Future<Result<SlotsConfig>> load() => guardRequest(_remote.load);

  @override
  Future<Result<void>> save(SlotsConfig config) => guardRequest(() => _remote.save(config));
}
