import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/staff_orders/data/datasources/staff_orders_remote_data_source.dart';
import 'package:campuseats/features/staff_orders/domain/entities/orders_summary.dart';

class FakeStaffOrdersDataSource implements StaffOrdersRemoteDataSource {
  final List<Order> _orders = [
    Order(
      id: 'ord_staff_1',
      userId: 'usr_stu_1',
      studentMatricule: 'STU001',
      studentName: 'Ousmane Sawadogo',
      dishId: 'dish_1',
      dishName: 'Riz gras au bœuf',
      slotId: 'slot_1',
      slotLabel: '11h30 - 12h00',
      date: DateTime.now(),
      status: OrderStatus.ready,
      qrCode: 'ORD-2026-STU001-TODAY-SECURE',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Order(
      id: 'ord_staff_2',
      userId: 'usr_stu_2',
      studentMatricule: 'STU002',
      studentName: 'Aminata Ouedraogo',
      dishId: 'dish_2',
      dishName: 'Tô de maïs & gombo',
      slotId: 'slot_1',
      slotLabel: '11h30 - 12h00',
      date: DateTime.now(),
      status: OrderStatus.pending,
      qrCode: 'ORD-2026-STU002-PENDING',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    Order(
      id: 'ord_staff_3',
      userId: 'usr_stu_4',
      studentMatricule: 'STU004',
      studentName: 'Issa Compaore',
      dishId: 'dish_1',
      dishName: 'Riz gras au bœuf',
      slotId: 'slot_2',
      slotLabel: '12h00 - 12h30',
      date: DateTime.now(),
      status: OrderStatus.served,
      qrCode: 'ORD-2026-STU004-SERVED',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Order(
      id: 'ord_staff_4',
      userId: 'usr_stu_5',
      studentMatricule: 'STU005',
      studentName: 'Mariam Zerbo',
      dishId: 'dish_4',
      dishName: 'Alloco & capitaine',
      slotId: 'slot_2',
      slotLabel: '12h00 - 12h30',
      date: DateTime.now(),
      status: OrderStatus.pending,
      qrCode: 'ORD-2026-STU005-PENDING',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  @override
  Future<OrdersSummary> summary(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final served = _orders.where((o) => o.status == OrderStatus.served).length;
    return OrdersSummary(
      portions: const [
        DishPortion(dishName: 'Riz gras au bœuf', count: 48),
        DishPortion(dishName: 'Tô de maïs & gombo', count: 15),
        DishPortion(dishName: 'Alloco & capitaine', count: 65),
      ],
      served: served,
      total: _orders.length,
    );
  }

  @override
  Future<PagedResult<Order>> orders({required DateTime date, String? slotId, String? query, int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var filtered = _orders;
    if (slotId != null && slotId.isNotEmpty && slotId != 'all') {
      filtered = filtered.where((o) => o.slotId == slotId).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((o) => o.studentName.toLowerCase().contains(q) || o.studentMatricule.toLowerCase().contains(q)).toList();
    }

    return PagedResult(
      items: filtered,
      total: filtered.length,
      page: 1,
      limit: 50,
      totalPages: 1,
    );
  }

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> bulkMarkReady({required String slotId, required DateTime date}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var i = 0; i < _orders.length; i++) {
      if (_orders[i].slotId == slotId && _orders[i].status == OrderStatus.pending) {
        _orders[i] = _orders[i].copyWith(status: OrderStatus.ready);
      }
    }
  }
}
