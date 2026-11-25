import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';

abstract interface class OrderRepository {
  Future<Result<List<Slot>>> getSlots(DateTime date);

  Future<Result<Order>> placeOrder({
    required String dishId,
    required String slotId,
    required DateTime date,
  });

  Future<Result<Order?>> getTodayOrder();

  Future<Result<void>> cancelOrder(String orderId);

  Future<Result<PagedResult<Order>>> getMyOrders({int page = 1});
}
