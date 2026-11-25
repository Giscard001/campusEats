import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/staff_orders/domain/entities/orders_summary.dart';
import 'package:campuseats/features/staff_orders/domain/repositories/staff_orders_repository.dart';

// Events
sealed class StaffOrdersEvent extends Equatable {
  const StaffOrdersEvent();
  @override
  List<Object?> get props => [];
}

final class LoadStaffOrders extends StaffOrdersEvent {
  const LoadStaffOrders();
}

final class SlotFilterChanged extends StaffOrdersEvent {
  const SlotFilterChanged(this.slotId);
  final String? slotId;
  @override
  List<Object?> get props => [slotId];
}

final class SearchQueryChanged extends StaffOrdersEvent {
  const SearchQueryChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class UpdateOrderStatusRequested extends StaffOrdersEvent {
  const UpdateOrderStatusRequested({required this.orderId, required this.newStatus});
  final String orderId;
  final OrderStatus newStatus;
  @override
  List<Object?> get props => [orderId, newStatus];
}

final class BulkMarkReadyRequested extends StaffOrdersEvent {
  const BulkMarkReadyRequested({required this.slotId});
  final String slotId;
  @override
  List<Object?> get props => [slotId];
}

final class AutoRefreshTriggered extends StaffOrdersEvent {
  const AutoRefreshTriggered();
}

// State
enum StaffOrdersStatus { initial, loading, success, error }

class StaffOrdersState extends Equatable {
  const StaffOrdersState({
    this.status = StaffOrdersStatus.initial,
    this.summary,
    this.orders = const [],
    this.selectedSlotId,
    this.searchQuery = '',
    this.failure,
    this.snackBarMessage,
  });

  final StaffOrdersStatus status;
  final OrdersSummary? summary;
  final List<Order> orders;
  final String? selectedSlotId;
  final String searchQuery;
  final Failure? failure;
  final String? snackBarMessage;

  StaffOrdersState copyWith({
    StaffOrdersStatus? status,
    OrdersSummary? summary,
    List<Order>? orders,
    String? selectedSlotId,
    String? searchQuery,
    Failure? failure,
    String? snackBarMessage,
  }) {
    return StaffOrdersState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      orders: orders ?? this.orders,
      selectedSlotId: selectedSlotId ?? this.selectedSlotId,
      searchQuery: searchQuery ?? this.searchQuery,
      failure: failure,
      snackBarMessage: snackBarMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, orders, selectedSlotId, searchQuery, failure, snackBarMessage];
}

class StaffOrdersBloc extends Bloc<StaffOrdersEvent, StaffOrdersState> {
  StaffOrdersBloc(this._repository) : super(const StaffOrdersState()) {
    on<LoadStaffOrders>(_onLoad);
    on<SlotFilterChanged>(_onSlotChanged);
    on<SearchQueryChanged>(_onSearchChanged);
    on<UpdateOrderStatusRequested>(_onUpdateStatus);
    on<BulkMarkReadyRequested>(_onBulkReady);
    on<AutoRefreshTriggered>(_onAutoRefresh);

    add(const LoadStaffOrders());
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => add(const AutoRefreshTriggered()));
  }

  final StaffOrdersRepository _repository;
  Timer? _refreshTimer;

  Future<void> _onLoad(LoadStaffOrders event, Emitter<StaffOrdersState> emit) async {
    emit(state.copyWith(status: StaffOrdersStatus.loading, failure: null));
    await _fetchData(emit);
  }

  Future<void> _onSlotChanged(SlotFilterChanged event, Emitter<StaffOrdersState> emit) async {
    emit(state.copyWith(selectedSlotId: event.slotId, status: StaffOrdersStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _onSearchChanged(SearchQueryChanged event, Emitter<StaffOrdersState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    await _fetchData(emit);
  }

  Future<void> _onAutoRefresh(AutoRefreshTriggered event, Emitter<StaffOrdersState> emit) async {
    await _fetchData(emit, silent: true);
  }

  Future<void> _fetchData(Emitter<StaffOrdersState> emit, {bool silent = false}) async {
    final now = DateTime.now();
    final summaryRes = await _repository.getSummary(now);
    final ordersRes = await _repository.getOrders(
      date: now,
      slotId: state.selectedSlotId,
      query: state.searchQuery,
    );

    OrdersSummary? summary;
    List<Order> orders = state.orders;
    Failure? failure;

    summaryRes.when(success: (s) => summary = s, failure: (f) => failure = f);
    ordersRes.when(success: (p) => orders = p.items, failure: (f) => failure ??= f);

    emit(state.copyWith(
      status: failure != null && !silent ? StaffOrdersStatus.error : StaffOrdersStatus.success,
      summary: summary ?? state.summary,
      orders: orders,
      failure: failure,
    ));
  }

  Future<void> _onUpdateStatus(UpdateOrderStatusRequested event, Emitter<StaffOrdersState> emit) async {
    final previousOrders = List<Order>.from(state.orders);

    // Optimistic update
    final updated = [
      for (final o in state.orders)
        if (o.id == event.orderId) o.copyWith(status: event.newStatus) else o,
    ];
    emit(state.copyWith(orders: updated));

    final result = await _repository.updateStatus(event.orderId, event.newStatus);
    result.when(
      success: (_) {
        // Refresh summary
        add(const AutoRefreshTriggered());
      },
      failure: (failure) {
        // Rollback on failure!
        emit(state.copyWith(
          orders: previousOrders,
          snackBarMessage: 'Échec de mise à jour: ${failure.message}',
        ));
      },
    );
  }

  Future<void> _onBulkReady(BulkMarkReadyRequested event, Emitter<StaffOrdersState> emit) async {
    emit(state.copyWith(snackBarMessage: 'Passage en "Prêt" pour le créneau...'));
    final result = await _repository.bulkMarkReady(slotId: event.slotId, date: DateTime.now());
    result.when(
      success: (_) {
        emit(state.copyWith(snackBarMessage: 'Toutes les commandes du créneau sont prêtes !'));
        add(const LoadStaffOrders());
      },
      failure: (failure) => emit(state.copyWith(snackBarMessage: failure.message)),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
