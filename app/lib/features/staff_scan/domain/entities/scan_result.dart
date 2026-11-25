import 'package:equatable/equatable.dart';
import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';

enum ScanStatusType {
  valid,
  alreadyUsed,
  expired,
  noOrder,
  subscriptionExpired,
  error;

  String get label => switch (this) {
        ScanStatusType.valid => 'Commande valide',
        ScanStatusType.alreadyUsed => 'Déjà servi',
        ScanStatusType.expired => 'Commande expirée',
        ScanStatusType.noOrder => 'Commande introuvable',
        ScanStatusType.subscriptionExpired => 'Abonnement expiré',
        ScanStatusType.error => 'Erreur de scan',
      };
}

class ScanResult extends Equatable {
  const ScanResult({
    required this.statusType,
    this.order,
    this.studentName,
    this.studentMatricule,
    this.servedAt,
    this.message,
  });

  final ScanStatusType statusType;
  final Order? order;
  final String? studentName;
  final String? studentMatricule;
  final DateTime? servedAt;
  final String? message;

  bool get isValid => statusType == ScanStatusType.valid;
  bool get isAlreadyUsed => statusType == ScanStatusType.alreadyUsed;

  @override
  List<Object?> get props => [
        statusType,
        order,
        studentName,
        studentMatricule,
        servedAt,
        message,
      ];
}
