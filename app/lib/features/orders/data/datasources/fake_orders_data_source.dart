import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';

class FakeOrdersDataSource implements OrdersRemoteDataSource {
  final List<Slot> _mockSlots = [
    const Slot(id: 'slot_1', label: '11h30 - 12h00', startTime: '11:30', endTime: '12:00', capacity: 60, reservedCount: 24),
    const Slot(id: 'slot_2', label: '12h00 - 12h30', startTime: '12:00', endTime: '12:30', capacity: 70, reservedCount: 70), // plein
    const Slot(id: 'slot_3', label: '12h30 - 13h00', startTime: '12:30', endTime: '13:00', capacity: 60, reservedCount: 45),
    const Slot(id: 'slot_4', label: '13h00 - 13h30', startTime: '13:00', endTime: '13:30', capacity: 50, reservedCount: 12),
  ];

  final List<Order> _myOrders = [];
  Order? _todayOrder;

  FakeOrdersDataSource() {
    final now = DateTime.now();
    // Default today active order for student demo
    _todayOrder = Order(
      id: 'ord_today_101',
      userId: 'usr_stu_1',
      studentMatricule: 'STU001',
      studentName: 'Ousmane Sawadogo',
      dishId: 'dish_1',
      dishName: 'Riz gras au bœuf & légumes locaux',
      slotId: 'slot_1',
      slotLabel: '11h30 - 12h00',
      date: now,
      status: OrderStatus.ready,
      qrCode: 'ORD-2026-STU001-TODAY-SECURE',
      createdAt: now.subtract(const Duration(hours: 2)),
    );
    _myOrders.add(_todayOrder!);

    // Past order yesterday
    _myOrders.add(Order(
      id: 'ord_yesterday_099',
      userId: 'usr_stu_1',
      studentMatricule: 'STU001',
      studentName: 'Ousmane Sawadogo',
      dishId: 'dish_2',
      dishName: 'Tô de maïs & sauce gombo frais',
      slotId: 'slot_2',
      slotLabel: '12h00 - 12h30',
      date: now.subtract(const Duration(days: 1)),
      status: OrderStatus.served,
      qrCode: 'ORD-YEST-SERVED-1',
      createdAt: now.subtract(const Duration(days: 1, hours: 3)),
    ));
  }

  @override
  Future<List<Slot>> getSlots(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockSlots;
  }

  @override
  Future<Order> placeOrder({required String dishId, required String slotId, required DateTime date}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final slot = _mockSlots.firstWhere((s) => s.id == slotId, orElse: () => _mockSlots.first);
    if (slot.isFull) {
      throw const ConflictFailure('Ce créneau est complet. Veuillez en choisir un autre.');
    }

    final newOrder = Order(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_stu_1',
      studentMatricule: 'STU001',
      studentName: 'Ousmane Sawadogo',
      dishId: dishId,
      dishName: dishId == 'dish_1' ? 'Riz gras au bœuf' : 'Plat sélectionné',
      slotId: slotId,
      slotLabel: slot.label,
      date: date,
      status: OrderStatus.pending,
      qrCode: 'ORD-${DateTime.now().millisecondsSinceEpoch}-QR',
      createdAt: DateTime.now(),
    );

    _todayOrder = newOrder;
    _myOrders.insert(0, newOrder);
    return newOrder;
  }

  @override
  Future<Order?> getTodayOrder() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _todayOrder;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _myOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final existing = _myOrders[idx];
      if (existing.status != OrderStatus.pending) {
        throw const ConflictFailure('Seules les commandes en attente peuvent être annulées.');
      }
      _myOrders[idx] = existing.copyWith(status: OrderStatus.cancelled);
      if (_todayOrder?.id == orderId) {
        _todayOrder = _myOrders[idx];
      }
    }
  }

  @override
  Future<PagedResult<Order>> getMyOrders({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return PagedResult(
      items: _myOrders,
      total: _myOrders.length,
      page: 1,
      limit: 20,
      totalPages: 1,
    );
  }
}
