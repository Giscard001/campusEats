import 'package:flutter_test/flutter_test.dart';
import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';
import 'package:campuseats/features/orders/presentation/bloc/my_orders_bloc.dart';

class MockOrderRepository implements OrderRepository {
  List<Order> orders = [];
  bool failNextCancel = false;

  @override
  Future<Result<PagedResult<Order>>> getMyOrders({int page = 1}) async {
    return Success(PagedResult(
      items: orders,
      total: orders.length,
      page: 1,
      limit: 20,
      totalPages: 1,
    ));
  }

  @override
  Future<Result<void>> cancelOrder(String orderId) async {
    if (failNextCancel) {
      return const Err(ServerFailure('Erreur serveur lors de l\'annulation'));
    }
    return const Success(null);
  }

  @override
  Future<Result<Order?>> getTodayOrder() async => const Success(null);

  @override
  Future<Result<List<Slot>>> getSlots(DateTime date) async => const Success([]);

  @override
  Future<Result<Order>> placeOrder({required String dishId, required String slotId, required DateTime date}) async {
    throw UnimplementedError();
  }
}

void main() {
  group('MyOrdersBloc', () {
    late MockOrderRepository mockRepo;
    late MyOrdersBloc bloc;

    final initialOrder = Order(
      id: 'ord_1',
      userId: 'usr_1',
      studentMatricule: 'STU001',
      studentName: 'Ousmane',
      dishId: 'dish_1',
      dishName: 'Riz gras',
      slotId: 'slot_1',
      slotLabel: '11h30 - 12h00',
      date: DateTime.now(),
      status: OrderStatus.pending,
      qrCode: 'QR1',
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockRepo = MockOrderRepository()..orders = [initialOrder];
      bloc = MyOrdersBloc(mockRepo);
    });

    tearDown(() {
      bloc.close();
    });

    test('optimistic cancel immediately sets status to cancelled and succeeds', () async {
      await Future.delayed(const Duration(milliseconds: 50)); // let initial load complete

      bloc.add(const CancelOrderRequested('ord_1'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<MyOrdersState>((state) {
            final o = state.orders.firstWhere((e) => e.id == 'ord_1');
            return o.status == OrderStatus.cancelled && state.snackBarMessage == 'Commande annulée avec succès.';
          }),
        ),
      );
    });

    test('optimistic cancel rolls back status if cancel fails', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      mockRepo.failNextCancel = true;

      bloc.add(const CancelOrderRequested('ord_1'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<MyOrdersState>((state) {
            final o = state.orders.firstWhere((e) => e.id == 'ord_1');
            // Rolled back to pending!
            return o.status == OrderStatus.pending && (state.snackBarMessage?.contains('Échec') ?? false);
          }),
        ),
      );
    });
  });
}
