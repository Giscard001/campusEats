import 'package:equatable/equatable.dart';

class DishPortion extends Equatable {
  const DishPortion({required this.dishName, required this.count});
  final String dishName;
  final int count;

  @override
  List<Object?> get props => [dishName, count];
}

class OrdersSummary extends Equatable {
  const OrdersSummary({
    required this.portions,
    required this.served,
    required this.total,
  });

  final List<DishPortion> portions;
  final int served;
  final int total;

  int get remaining => total - served;
  double get progressRate => total > 0 ? (served / total).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [portions, served, total];
}
