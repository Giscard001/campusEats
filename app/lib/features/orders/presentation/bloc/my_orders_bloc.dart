import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';

// Events
sealed class MyOrdersEvent extends Equatable {
  const MyOrdersEvent();
  @override
  List<Object?> get props => [];
}

final class LoadMyOrders extends MyOrdersEvent {
  const LoadMyOrders();
}

final class RefreshMyOrders extends MyOrdersEvent {
  const RefreshMyOrders();
}

final class CancelOrderRequested extends MyOrdersEvent {
  const CancelOrderRequested(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

// State
enum MyOrdersStatus { initial, loading, success, error }

class MyOrdersState extends Equatable {
  const MyOrdersState({
    this.status = MyOrdersStatus.initial,
    this.orders = const [],
    this.failure,
    this.snackBarMessage,
  });

  final MyOrdersStatus status;
  final List<Order> orders;
  final Failure? failure;
  final String? snackBarMessage;

  MyOrdersState copyWith({
    MyOrdersStatus? status,
    List<Order>? orders,
    Failure? failure,
    String? snackBarMessage,
  }) {
    return MyOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      failure: failure,
      snackBarMessage: snackBarMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, failure, snackBarMessage];
}

class MyOrdersBloc extends Bloc<MyOrdersEvent, MyOrdersState> {
  MyOrdersBloc(this._orderRepository) : super(const MyOrdersState()) {
    on<LoadMyOrders>(_onLoadMyOrders);
    on<RefreshMyOrders>(_onRefreshMyOrders);
    on<CancelOrderRequested>(_onCancelOrderRequested);

    add(const LoadMyOrders());
  }

  final OrderRepository _orderRepository;

  Future<void> _onLoadMyOrders(LoadMyOrders event, Emitter<MyOrdersState> emit) async {
    emit(state.copyWith(status: MyOrdersStatus.loading, failure: null));
    final result = await _orderRepository.getMyOrders();
    result.when(
      success: (paged) => emit(state.copyWith(
        status: MyOrdersStatus.success,
        orders: paged.items,
      )),
      failure: (failure) => emit(state.copyWith(
        status: MyOrdersStatus.error,
        failure: failure,
      )),
    );
  }

  Future<void> _onRefreshMyOrders(RefreshMyOrders event, Emitter<MyOrdersState> emit) async {
    final result = await _orderRepository.getMyOrders();
    result.when(
      success: (paged) => emit(state.copyWith(
        status: MyOrdersStatus.success,
        orders: paged.items,
      )),
      failure: (failure) => emit(state.copyWith(
        failure: failure,
        snackBarMessage: 'Erreur lors de l\'actualisation',
      )),
    );
  }

  Future<void> _onCancelOrderRequested(CancelOrderRequested event, Emitter<MyOrdersState> emit) async {
    final previousOrders = List<Order>.from(state.orders);

    // Optimistic cancellation: update status in UI immediately
    final updated = [
      for (final o in state.orders)
        if (o.id == event.orderId) o.copyWith(status: OrderStatus.cancelled) else o,
    ];
    emit(state.copyWith(orders: updated, snackBarMessage: 'Annulation en cours...'));

    final result = await _orderRepository.cancelOrder(event.orderId);
    result.when(
      success: (_) {
        emit(state.copyWith(snackBarMessage: 'Commande annulée avec succès.'));
      },
      failure: (failure) {
        // Rollback on failure!
        emit(state.copyWith(
          orders: previousOrders,
          snackBarMessage: 'Échec de l\'annulation : ${failure.message}',
        ));
      },
    );
  }
}
