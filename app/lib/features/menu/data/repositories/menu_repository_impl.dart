import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/core/storage/cache_store.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:campuseats/features/menu/data/models/menu_model.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';
import 'package:campuseats/features/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl({
    required MenuRemoteDataSource remoteDataSource,
    required CacheStore cacheStore,
  })  : _remoteDataSource = remoteDataSource,
        _cacheStore = cacheStore;

  final MenuRemoteDataSource _remoteDataSource;
  final CacheStore _cacheStore;

  @override
  Future<Result<DailyMenu>> getMenu(DateTime date) async {
    final cacheKey = 'daily_menu_${Fmt.apiDate(date)}';

    final remoteResult = await guardRequest(() => _remoteDataSource.getMenu(date));
    return remoteResult.when(
      success: (menu) async {
        await _cacheStore.putMap(cacheKey, MenuModel.menuToJson(menu));
        return Success(menu);
      },
      failure: (failure) async {
        // Fallback to offline cache
        final cached = await _cacheStore.getMap(cacheKey);
        if (cached != null) {
          return Success(MenuModel.menuFromJson(cached));
        }
        return Err(failure);
      },
    );
  }

  @override
  Future<Result<List<Dish>>> getAllDishes() => guardRequest(_remoteDataSource.getAllDishes);
}
