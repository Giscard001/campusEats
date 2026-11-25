import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/staff_orders/domain/entities/orders_summary.dart';

abstract interface class StaffOrdersRepository {
  Future<Result<OrdersSummary>> getSummary(DateTime date);
  Future<Result<PagedResult<Order>>> getOrders({
    required DateTime date,
    String? slotId,
    String? query,
    int page = 1,
  });
  Future<Result<void>> updateStatus(String orderId, OrderStatus status);
  Future<Result<void>> bulkMarkReady({required String slotId, required DateTime date});
}
