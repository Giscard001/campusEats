import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/core/storage/cache_store.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:campuseats/features/orders/data/models/order_model.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrdersRemoteDataSource remoteDataSource,
    required CacheStore cacheStore,
  })  : _remoteDataSource = remoteDataSource,
        _cacheStore = cacheStore;

  final OrdersRemoteDataSource _remoteDataSource;
  final CacheStore _cacheStore;

  static const String _todayOrderCacheKey = 'cached_today_order';

  @override
  Future<Result<List<Slot>>> getSlots(DateTime date) {
    return guardRequest(() => _remoteDataSource.getSlots(date));
  }

  @override
  Future<Result<Order>> placeOrder({
    required String dishId,
    required String slotId,
    required DateTime date,
  }) async {
    final result = await guardRequest(() => _remoteDataSource.placeOrder(
          dishId: dishId,
          slotId: slotId,
          date: date,
        ));

    return result.when(
      success: (order) async {
        await _cacheStore.putMap(_todayOrderCacheKey, OrderModel.toJson(order));
        return Success(order);
      },
      failure: (failure) => Err(failure),
    );
  }

  @override
  Future<Result<Order?>> getTodayOrder() async {
    final result = await guardRequest(_remoteDataSource.getTodayOrder);
    return result.when(
      success: (order) async {
        if (order != null) {
          await _cacheStore.putMap(_todayOrderCacheKey, OrderModel.toJson(order));
        } else {
          await _cacheStore.delete(_todayOrderCacheKey);
        }
        return Success(order);
      },
      failure: (failure) async {
        // Offline cache fallback for today's QR code
        final cached = await _cacheStore.getMap(_todayOrderCacheKey);
        if (cached != null) {
          return Success(OrderModel.fromJson(cached));
        }
        return Err(failure);
      },
    );
  }

  @override
  Future<Result<void>> cancelOrder(String orderId) {
    return guardRequest(() => _remoteDataSource.cancelOrder(orderId));
  }

  @override
  Future<Result<PagedResult<Order>>> getMyOrders({int page = 1}) {
    return guardRequest(() => _remoteDataSource.getMyOrders(page: page));
  }
}
