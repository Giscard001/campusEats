import 'package:campuseats/core/domain/order_status.dart';
import 'package:campuseats/core/domain/paged.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';

abstract final class OrderModel {
  static Slot slotFromJson(Map<String, dynamic> j) {
    return Slot(
      id: jsonString(j, 'id'),
      label: jsonString(j, 'label'),
      startTime: jsonStringOrNull(j, 'startTime') ?? '11:30',
      endTime: jsonStringOrNull(j, 'endTime') ?? '12:15',
      capacity: jsonInt(j, 'capacity'),
      reservedCount: j.containsKey('reservedCount') ? jsonInt(j, 'reservedCount') : 0,
      active: j['active'] != false,
    );
  }

  static Map<String, dynamic> slotToJson(Slot slot) => {
        'id': slot.id,
        'label': slot.label,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
        'capacity': slot.capacity,
        'reservedCount': slot.reservedCount,
        'active': slot.active,
      };

  static Order fromJson(Map<String, dynamic> j) {
    final rawDate = j['date'];
    final parsedDate = rawDate is String ? Fmt.parseApiDate(rawDate) : DateTime.now();

    return Order(
      id: jsonString(j, 'id'),
      userId: jsonStringOrNull(j, 'userId') ?? '',
      studentMatricule: jsonStringOrNull(j, 'studentMatricule') ?? jsonStringOrNull(j, 'matricule') ?? '',
      studentName: jsonStringOrNull(j, 'studentName') ?? '',
      dishId: jsonString(j, 'dishId'),
      dishName: jsonStringOrNull(j, 'dishName') ?? 'Repas du jour',
      slotId: jsonString(j, 'slotId'),
      slotLabel: jsonStringOrNull(j, 'slotLabel') ?? 'Créneau déjeuner',
      date: parsedDate,
      status: OrderStatus.fromApi(jsonString(j, 'status')),
      qrCode: jsonStringOrNull(j, 'qrCode') ?? jsonString(j, 'id'),
      createdAt: jsonDateOrNull(j, 'createdAt') ?? DateTime.now(),
      portionNotes: jsonStringOrNull(j, 'portionNotes'),
    );
  }

  static Map<String, dynamic> toJson(Order order) => {
        'id': order.id,
        'userId': order.userId,
        'studentMatricule': order.studentMatricule,
        'studentName': order.studentName,
        'dishId': order.dishId,
        'dishName': order.dishName,
        'slotId': order.slotId,
        'slotLabel': order.slotLabel,
        'date': Fmt.apiDate(order.date),
        'status': order.status.apiValue,
        'qrCode': order.qrCode,
        'createdAt': order.createdAt.toIso8601String(),
        if (order.portionNotes != null) 'portionNotes': order.portionNotes,
      };

  static PagedResult<Order> pageFromJson(Map<String, dynamic> j) =>
      pagedFromJson(j, fromJson);
}
