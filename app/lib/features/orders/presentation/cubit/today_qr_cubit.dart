import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';

enum TodayQrStatus { initial, loading, loaded, empty, error }

class TodayQrState extends Equatable {
  const TodayQrState({
    this.status = TodayQrStatus.initial,
    this.order,
    this.failure,
  });

  final TodayQrStatus status;
  final Order? order;
  final Failure? failure;

  TodayQrState copyWith({
    TodayQrStatus? status,
    Order? order,
    Failure? failure,
  }) {
    return TodayQrState(
      status: status ?? this.status,
      order: order ?? this.order,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, order, failure];
}

class TodayQrCubit extends Cubit<TodayQrState> {
  TodayQrCubit(this._orderRepository) : super(const TodayQrState()) {
    loadTodayQr();
  }

  final OrderRepository _orderRepository;

  Future<void> loadTodayQr() async {
    emit(state.copyWith(status: TodayQrStatus.loading, failure: null));
    final result = await _orderRepository.getTodayOrder();
    result.when(
      success: (order) {
        if (order != null) {
          emit(state.copyWith(status: TodayQrStatus.loaded, order: order));
        } else {
          emit(state.copyWith(status: TodayQrStatus.empty, order: null));
        }
      },
      failure: (failure) => emit(state.copyWith(status: TodayQrStatus.error, failure: failure)),
    );
  }
}
