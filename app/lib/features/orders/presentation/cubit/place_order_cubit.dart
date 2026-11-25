import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';

enum PlaceOrderStatus { initial, loadingSlots, slotsLoaded, submitting, success, error }

class PlaceOrderState extends Equatable {
  const PlaceOrderState({
    required this.dish,
    required this.date,
    this.status = PlaceOrderStatus.initial,
    this.slots = const [],
    this.selectedSlot,
    this.failure,
    this.createdOrder,
  });

  final Dish dish;
  final DateTime date;
  final PlaceOrderStatus status;
  final List<Slot> slots;
  final Slot? selectedSlot;
  final Failure? failure;
  final Order? createdOrder;

  PlaceOrderState copyWith({
    Dish? dish,
    DateTime? date,
    PlaceOrderStatus? status,
    List<Slot>? slots,
    Slot? selectedSlot,
    Failure? failure,
    Order? createdOrder,
  }) {
    return PlaceOrderState(
      dish: dish ?? this.dish,
      date: date ?? this.date,
      status: status ?? this.status,
      slots: slots ?? this.slots,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      failure: failure,
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }

  @override
  List<Object?> get props => [dish, date, status, slots, selectedSlot, failure, createdOrder];
}

class PlaceOrderCubit extends Cubit<PlaceOrderState> {
  PlaceOrderCubit({
    required Dish dish,
    required DateTime date,
    required OrderRepository orderRepository,
  })  : _orderRepository = orderRepository,
        super(PlaceOrderState(dish: dish, date: date)) {
    loadSlots();
  }

  final OrderRepository _orderRepository;

  Future<void> loadSlots() async {
    emit(state.copyWith(status: PlaceOrderStatus.loadingSlots, failure: null));
    final result = await _orderRepository.getSlots(state.date);
    result.when(
      success: (slots) {
        final firstAvailable = slots.where((s) => !s.isFull).firstOrNull;
        emit(state.copyWith(
          status: PlaceOrderStatus.slotsLoaded,
          slots: slots,
          selectedSlot: firstAvailable,
        ));
      },
      failure: (failure) => emit(state.copyWith(status: PlaceOrderStatus.error, failure: failure)),
    );
  }

  void selectSlot(Slot slot) {
    if (!slot.isFull) {
      emit(state.copyWith(selectedSlot: slot));
    }
  }

  Future<void> submitOrder() async {
    final slot = state.selectedSlot;
    if (slot == null || slot.isFull) {
      emit(state.copyWith(
        failure: const ValidationFailure('Veuillez sélectionner un créneau disponible.'),
      ));
      return;
    }

    emit(state.copyWith(status: PlaceOrderStatus.submitting, failure: null));

    final result = await _orderRepository.placeOrder(
      dishId: state.dish.id,
      slotId: slot.id,
      date: state.date,
    );

    result.when(
      success: (order) => emit(state.copyWith(status: PlaceOrderStatus.success, createdOrder: order)),
      failure: (failure) => emit(state.copyWith(status: PlaceOrderStatus.error, failure: failure)),
    );
  }
}
