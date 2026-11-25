import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/staff_orders/data/datasources/staff_orders_remote_data_source.dart';
import 'package:campuseats/features/staff_orders/domain/entities/orders_summary.dart';
import 'package:campuseats/features/staff_orders/domain/repositories/staff_orders_repository.dart';

class StaffOrdersRepositoryImpl implements StaffOrdersRepository {
  StaffOrdersRepositoryImpl(this._remote);

  final StaffOrdersRemoteDataSource _remote;

  @override
  Future<Result<OrdersSummary>> getSummary(DateTime date) =>
      guardRequest(() => _remote.summary(date));

  @override
  Future<Result<PagedResult<Order>>> getOrders({
    required DateTime date,
    String? slotId,
    String? query,
    int page = 1,
  }) =>
      guardRequest(() => _remote.orders(date: date, slotId: slotId, query: query, page: page));

  @override
  Future<Result<void>> updateStatus(String orderId, OrderStatus status) =>
      guardRequest(() => _remote.updateStatus(orderId, status));

  @override
  Future<Result<void>> bulkMarkReady({required String slotId, required DateTime date}) =>
      guardRequest(() => _remote.bulkMarkReady(slotId: slotId, date: date));
}
