import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:campuseats/core/error/failure.dart';
import 'package:campuseats/features/staff_scan/data/repositories/scanner_repository_impl.dart';
import 'package:campuseats/features/staff_scan/domain/entities/scan_result.dart';

// Events
sealed class ScannerEvent extends Equatable {
  const ScannerEvent();
  @override
  List<Object?> get props => [];
}

final class QrDetected extends ScannerEvent {
  const QrDetected(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

final class MarkServedRequested extends ScannerEvent {
  const MarkServedRequested(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

final class ResetScanner extends ScannerEvent {
  const ResetScanner();
}

// State
enum ScannerStateStatus { idle, verifying, resultReady, serving, servedSuccess, error }

class ScannerState extends Equatable {
  const ScannerState({
    this.status = ScannerStateStatus.idle,
    this.lastScannedCode,
    this.result,
    this.failure,
  });

  final ScannerStateStatus status;
  final String? lastScannedCode;
  final ScanResult? result;
  final Failure? failure;

  ScannerState copyWith({
    ScannerStateStatus? status,
    String? lastScannedCode,
    ScanResult? result,
    Failure? failure,
  }) {
    return ScannerState(
      status: status ?? this.status,
      lastScannedCode: lastScannedCode ?? this.lastScannedCode,
      result: result ?? this.result,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, lastScannedCode, result, failure];
}

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc(this._scannerRepository) : super(const ScannerState()) {
    // droppable() ensures rapid QR detections from camera don't trigger simultaneous API requests
    on<QrDetected>(_onQrDetected, transformer: droppable());
    on<MarkServedRequested>(_onMarkServedRequested);
    on<ResetScanner>(_onResetScanner);
  }

  final ScannerRepository _scannerRepository;
  DateTime? _lastScanTime;
  String? _lastScanned;

  Future<void> _onQrDetected(QrDetected event, Emitter<ScannerState> emit) async {
    final now = DateTime.now();
    // 2-second cooldown on identical code
    if (_lastScanned == event.code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inSeconds < 2) {
      return;
    }

    _lastScanned = event.code;
    _lastScanTime = now;

    emit(state.copyWith(
      status: ScannerStateStatus.verifying,
      lastScannedCode: event.code,
      failure: null,
    ));

    final result = await _scannerRepository.verifyQrCode(event.code);
    result.when(
      success: (scanRes) => emit(state.copyWith(
        status: ScannerStateStatus.resultReady,
        result: scanRes,
      )),
      failure: (f) => emit(state.copyWith(
        status: ScannerStateStatus.error,
        failure: f,
      )),
    );
  }

  Future<void> _onMarkServedRequested(MarkServedRequested event, Emitter<ScannerState> emit) async {
    emit(state.copyWith(status: ScannerStateStatus.serving));
    final result = await _scannerRepository.markServed(event.orderId);
    result.when(
      success: (_) => emit(state.copyWith(status: ScannerStateStatus.servedSuccess)),
      failure: (f) => emit(state.copyWith(status: ScannerStateStatus.error, failure: f)),
    );
  }

  void _onResetScanner(ResetScanner event, Emitter<ScannerState> emit) {
    emit(const ScannerState(status: ScannerStateStatus.idle));
  }
}
