import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/core/time/server_clock.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';
import 'package:campuseats/features/menu/domain/repositories/menu_repository.dart';

// Events
sealed class MenuEvent extends Equatable {
  const MenuEvent();
  @override
  List<Object?> get props => [];
}

final class MenuDateChanged extends MenuEvent {
  const MenuDateChanged(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

final class RefreshMenu extends MenuEvent {
  const RefreshMenu();
}

final class _TickTimer extends MenuEvent {
  const _TickTimer();
}

// State
class MenuState extends Equatable {
  const MenuState({
    required this.selectedDate,
    this.isLoading = false,
    this.menu,
    this.failure,
    this.cutoffTime = '10:00',
    this.isPastCutoff = false,
    this.cutoffCountdown = '',
  });

  final DateTime selectedDate;
  final bool isLoading;
  final DailyMenu? menu;
  final Failure? failure;
  final String cutoffTime;
  final bool isPastCutoff;
  final String cutoffCountdown;

  MenuState copyWith({
    DateTime? selectedDate,
    bool? isLoading,
    DailyMenu? menu,
    Failure? failure,
    String? cutoffTime,
    bool? isPastCutoff,
    String? cutoffCountdown,
  }) {
    return MenuState(
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      menu: menu ?? this.menu,
      failure: failure,
      cutoffTime: cutoffTime ?? this.cutoffTime,
      isPastCutoff: isPastCutoff ?? this.isPastCutoff,
      cutoffCountdown: cutoffCountdown ?? this.cutoffCountdown,
    );
  }

  @override
  List<Object?> get props => [
        selectedDate,
        isLoading,
        menu,
        failure,
        cutoffTime,
        isPastCutoff,
        cutoffCountdown,
      ];
}

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc({
    required MenuRepository menuRepository,
    required ServerClock serverClock,
  })  : _menuRepository = menuRepository,
        _serverClock = serverClock,
        super(MenuState(selectedDate: DateTime.now())) {
    on<MenuDateChanged>(_onDateChanged);
    on<RefreshMenu>(_onRefreshMenu);
    on<_TickTimer>(_onTickTimer);

    // Initial load
    add(MenuDateChanged(DateTime.now()));

    // Periodic cutoff countdown ticker
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => add(const _TickTimer()));
  }

  final MenuRepository _menuRepository;
  final ServerClock _serverClock;
  Timer? _ticker;

  Future<void> _onDateChanged(MenuDateChanged event, Emitter<MenuState> emit) async {
    emit(state.copyWith(selectedDate: event.date, isLoading: true, failure: null));
    await _loadMenuForDate(event.date, emit);
  }

  Future<void> _onRefreshMenu(RefreshMenu event, Emitter<MenuState> emit) async {
    emit(state.copyWith(isLoading: true, failure: null));
    await _loadMenuForDate(state.selectedDate, emit);
  }

  Future<void> _loadMenuForDate(DateTime date, Emitter<MenuState> emit) async {
    final result = await _menuRepository.getMenu(date);
    _computeCutoff(emit);

    result.when(
      success: (menu) => emit(state.copyWith(isLoading: false, menu: menu)),
      failure: (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
    );
  }

  void _onTickTimer(_TickTimer event, Emitter<MenuState> emit) {
    _computeCutoff(emit);
  }

  void _computeCutoff(Emitter<MenuState> emit) {
    final now = _serverClock.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final selectedDay = DateTime.utc(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day);

    if (selectedDay.isBefore(today)) {
      emit(state.copyWith(isPastCutoff: true, cutoffCountdown: 'Service passé'));
      return;
    }

    if (selectedDay.isAfter(today)) {
      emit(state.copyWith(isPastCutoff: false, cutoffCountdown: 'Réservations ouvertes'));
      return;
    }

    // Selected is today: Cutoff is 10:00 UTC
    final parts = state.cutoffTime.split(':');
    final cutoffHour = int.tryParse(parts.first) ?? 10;
    final cutoffMin = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final cutoffDateTime = DateTime.utc(now.year, now.month, now.day, cutoffHour, cutoffMin);

    final diff = cutoffDateTime.difference(now);
    if (diff.isNegative) {
      emit(state.copyWith(isPastCutoff: true, cutoffCountdown: 'Commandes closes pour aujourd\'hui'));
    } else {
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      emit(state.copyWith(
        isPastCutoff: false,
        cutoffCountdown: '$hours:$minutes:$seconds avant clôture',
      ));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
