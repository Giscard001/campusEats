import 'package:dio/dio.dart';
import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/orders/data/models/order_model.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/staff_orders/domain/entities/orders_summary.dart';

abstract interface class StaffOrdersRemoteDataSource {
  Future<OrdersSummary> summary(DateTime date);
  Future<PagedResult<Order>> orders({required DateTime date, String? slotId, String? query, int page = 1});
  Future<void> updateStatus(String orderId, OrderStatus status);
  Future<void> bulkMarkReady({required String slotId, required DateTime date});
}

class StaffOrdersRemoteDataSourceImpl implements StaffOrdersRemoteDataSource {
  StaffOrdersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<OrdersSummary> summary(DateTime date) async {
    final j = await _dio.requestMap('GET', '/orders/summary', query: {'date': Fmt.apiDate(date)});
    final portions = j['portions'];
    return OrdersSummary(
      portions: portions is List
          ? [
              for (final e in portions)
                DishPortion(
                  dishName: jsonString(asJsonMap(e), 'dishName'),
                  count: jsonInt(asJsonMap(e), 'count'),
                ),
            ]
          : const [],
      served: jsonInt(j, 'served'),
      total: jsonInt(j, 'total'),
    );
  }

  @override
  Future<PagedResult<Order>> orders({required DateTime date, String? slotId, String? query, int page = 1}) async =>
      OrderModel.pageFromJson(
        await _dio.requestMap(
          'GET',
          '/orders',
          query: {
            'date': Fmt.apiDate(date),
            if (slotId != null) 'slotId': slotId,
            if (query != null && query.isNotEmpty) 'q': query,
            'page': page,
            'limit': 50,
          },
        ),
      );

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _dio.requestMap('PATCH', '/orders/$orderId/status', data: {'status': status.apiValue});
  }

  @override
  Future<void> bulkMarkReady({required String slotId, required DateTime date}) async {
    await _dio.requestMap(
      'POST',
      '/orders/status-bulk',
      data: {'slotId': slotId, 'date': Fmt.apiDate(date), 'status': 'ready'},
    );
  }
}
