import 'package:flutter_test/flutter_test.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/orders/data/models/order_model.dart';
import 'package:campuseats/features/staff_scan/data/repositories/scanner_repository_impl.dart';
import 'package:campuseats/features/staff_scan/domain/entities/scan_result.dart';
import 'package:campuseats/features/staff_scan/presentation/bloc/scanner_bloc.dart';

class MockScannerRepository implements ScannerRepository {
  int verifyCallCount = 0;

  @override
  Future<Result<ScanResult>> verifyQrCode(String qrData) async {
    verifyCallCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    return Success(ScanResult(
      statusType: ScanStatusType.valid,
      studentName: 'Ousmane Sawadogo',
      studentMatricule: 'STU001',
      order: OrderModel.fromJson({
        'id': 'ord_1',
        'userId': 'usr_1',
        'studentMatricule': 'STU001',
        'studentName': 'Ousmane Sawadogo',
        'dishId': 'dish_1',
        'dishName': 'Riz gras',
        'slotId': 'slot_1',
        'slotLabel': '11h30 - 12h00',
        'date': DateTime.now().toIso8601String(),
        'status': 'ready',
        'qrCode': qrData,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    ));
  }

  @override
  Future<Result<void>> markServed(String orderId) async => const Success(null);
}

void main() {
  group('ScannerBloc', () {
    late MockScannerRepository mockRepo;
    late ScannerBloc bloc;

    setUp(() {
      mockRepo = MockScannerRepository();
      bloc = ScannerBloc(mockRepo);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is idle', () {
      expect(bloc.state.status, ScannerStateStatus.idle);
    });

    test('droppable event handler ignores rapid successive camera detections of identical code', () async {
      // Rapid camera bursts
      bloc.add(const QrDetected('QR_TEST_CODE'));
      bloc.add(const QrDetected('QR_TEST_CODE'));
      bloc.add(const QrDetected('QR_TEST_CODE'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ScannerState>((state) => state.status == ScannerStateStatus.resultReady),
        ),
      );

      // Cooldown & droppable guarantee verify was only called once
      expect(mockRepo.verifyCallCount, 1);
    });
  });
}
