import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/admin_slots/domain/entities/slots_config.dart';

abstract interface class SlotsConfigRepository {
  Future<Result<SlotsConfig>> load();
  Future<Result<void>> save(SlotsConfig config);
}
