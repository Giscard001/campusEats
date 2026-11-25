import 'package:equatable/equatable.dart';
import 'package:campuseats/core/domain/order_status.dart';

class Slot extends Equatable {
  const Slot({
    required this.id,
    required this.label,
    this.startTime = '11:30',
    this.endTime = '12:15',
    this.capacity = 50,
    this.reservedCount = 0,
    this.active = true,
  });

  final String id;
  final String label;
  final String startTime;
  final String endTime;
  final int capacity;
  final int reservedCount;
  final bool active;

  int get remaining => (capacity - reservedCount).clamp(0, capacity);
  bool get isFull => remaining <= 0;

  @override
  List<Object?> get props => [id, label, startTime, endTime, capacity, reservedCount, active];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.userId,
    required this.studentMatricule,
    required this.studentName,
    required this.dishId,
    required this.dishName,
    required this.slotId,
    required this.slotLabel,
    required this.date,
    required this.status,
    required this.qrCode,
    required this.createdAt,
    this.portionNotes,
  });

  final String id;
  final String userId;
  final String studentMatricule;
  final String studentName;
  final String dishId;
  final String dishName;
  final String slotId;
  final String slotLabel;
  final DateTime date;
  final OrderStatus status;
  final String qrCode;
  final DateTime createdAt;
  final String? portionNotes;

  bool get canBeCancelled => status == OrderStatus.pending;
  bool get isReady => status == OrderStatus.ready;
  bool get isServed => status == OrderStatus.served;

  Order copyWith({
    String? id,
    String? userId,
    String? studentMatricule,
    String? studentName,
    String? dishId,
    String? dishName,
    String? slotId,
    String? slotLabel,
    DateTime? date,
    OrderStatus? status,
    String? qrCode,
    DateTime? createdAt,
    String? portionNotes,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentMatricule: studentMatricule ?? this.studentMatricule,
      studentName: studentName ?? this.studentName,
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      slotId: slotId ?? this.slotId,
      slotLabel: slotLabel ?? this.slotLabel,
      date: date ?? this.date,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      portionNotes: portionNotes ?? this.portionNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        studentMatricule,
        studentName,
        dishId,
        dishName,
        slotId,
        slotLabel,
        date,
        status,
        qrCode,
        createdAt,
        portionNotes,
      ];
}
