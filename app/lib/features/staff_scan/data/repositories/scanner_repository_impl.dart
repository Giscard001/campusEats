import 'package:dio/dio.dart';
import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/features/orders/data/models/order_model.dart';
import 'package:campuseats/features/staff_scan/domain/entities/scan_result.dart';

abstract interface class ScannerRepository {
  Future<Result<ScanResult>> verifyQrCode(String qrData);
  Future<Result<void>> markServed(String orderId);
}

class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<Result<ScanResult>> verifyQrCode(String qrData) => guardRequest(() async {
        final j = await _dio.requestMap('POST', '/orders/scan', data: {'code': qrData});
        final statusStr = jsonString(j, 'status').toLowerCase();

        final statusType = switch (statusStr) {
          'valid' => ScanStatusType.valid,
          'already_served' || 'already_used' => ScanStatusType.alreadyUsed,
          'expired' => ScanStatusType.expired,
          'subscription_expired' => ScanStatusType.subscriptionExpired,
          _ => ScanStatusType.noOrder,
        };

        final orderData = j['order'];
        final order = orderData is Map ? OrderModel.fromJson(asJsonMap(orderData)) : null;

        return ScanResult(
          statusType: statusType,
          order: order,
          studentName: jsonStringOrNull(j, 'studentName') ?? order?.studentName,
          studentMatricule: jsonStringOrNull(j, 'matricule') ?? order?.studentMatricule,
          servedAt: jsonDateOrNull(j, 'servedAt'),
          message: jsonStringOrNull(j, 'message'),
        );
      });

  @override
  Future<Result<void>> markServed(String orderId) => guardRequest(() async {
        await _dio.requestMap('POST', '/orders/$orderId/serve');
      });
}

class FakeScannerRepository implements ScannerRepository {
  @override
  Future<Result<ScanResult>> verifyQrCode(String qrData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final upper = qrData.toUpperCase();

    if (upper.contains('STU001') || upper.contains('ORD-2026-STU001')) {
      return Success(ScanResult(
        statusType: ScanStatusType.valid,
        studentName: 'Ousmane Sawadogo',
        studentMatricule: 'STU001',
        order: OrderModel.fromJson({
          'id': 'ord_today_101',
          'userId': 'usr_stu_1',
          'studentMatricule': 'STU001',
          'studentName': 'Ousmane Sawadogo',
          'dishId': 'dish_1',
          'dishName': 'Riz gras au bœuf & légumes locaux',
          'slotId': 'slot_1',
          'slotLabel': '11h30 - 12h00',
          'date': DateTime.now().toIso8601String(),
          'status': 'ready',
          'qrCode': qrData,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      ));
    } else if (upper.contains('SERVED')) {
      return Success(ScanResult(
        statusType: ScanStatusType.alreadyUsed,
        studentName: 'Issa Compaore',
        studentMatricule: 'STU004',
        servedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        message: 'Ce QR Code a déjà été validé à 11h42 au guichet 2.',
      ));
    } else if (upper.contains('EXPIRED')) {
      return const Success(ScanResult(
        statusType: ScanStatusType.expired,
        message: 'Ce repas correspond à une commande de la veille.',
      ));
    }

    return Success(ScanResult(
      statusType: ScanStatusType.valid,
      studentName: 'Aminata Ouedraogo',
      studentMatricule: 'STU002',
      order: OrderModel.fromJson({
        'id': 'ord_mock_${DateTime.now().millisecondsSinceEpoch}',
        'userId': 'usr_stu_2',
        'studentMatricule': 'STU002',
        'studentName': 'Aminata Ouedraogo',
        'dishId': 'dish_2',
        'dishName': 'Tô de maïs & sauce gombo frais',
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
  Future<Result<void>> markServed(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const Success(null);
  }
}
