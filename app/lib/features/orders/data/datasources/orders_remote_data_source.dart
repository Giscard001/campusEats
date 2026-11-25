import 'package:dio/dio.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/orders/data/models/order_model.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';

abstract interface class OrdersRemoteDataSource {
  Future<List<Slot>> getSlots(DateTime date);
  Future<Order> placeOrder({required String dishId, required String slotId, required DateTime date});
  Future<Order?> getTodayOrder();
  Future<void> cancelOrder(String orderId);
  Future<PagedResult<Order>> getMyOrders({int page = 1});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Slot>> getSlots(DateTime date) async {
    final list = await _dio.requestList('GET', '/slots', query: {'date': Fmt.apiDate(date)});
    return [for (final j in list) OrderModel.slotFromJson(j)];
  }

  @override
  Future<Order> placeOrder({required String dishId, required String slotId, required DateTime date}) async {
    final res = await _dio.requestMap(
      'POST',
      '/orders',
      data: {'dishId': dishId, 'slotId': slotId, 'date': Fmt.apiDate(date)},
    );
    return OrderModel.fromJson(res);
  }

  @override
  Future<Order?> getTodayOrder() async {
    try {
      final res = await _dio.requestMap('GET', '/orders/today');
      return OrderModel.fromJson(res);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _dio.requestMap('DELETE', '/orders/$orderId');
  }

  @override
  Future<PagedResult<Order>> getMyOrders({int page = 1}) async {
    final res = await _dio.requestMap('GET', '/orders/my', query: {'page': page, 'limit': 20});
    return OrderModel.pageFromJson(res);
  }
}
