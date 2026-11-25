import 'package:equatable/equatable.dart';

class DayCount extends Equatable {
  const DayCount({required this.date, required this.count});
  final DateTime date;
  final int count;

  @override
  List<Object?> get props => [date, count];
}

class NamedCount extends Equatable {
  const NamedCount({required this.name, required this.count});
  final String name;
  final int count;

  @override
  List<Object?> get props => [name, count];
}

class SlotFill extends Equatable {
  const SlotFill({required this.label, required this.rate});
  final String label;
  final double rate;

  @override
  List<Object?> get props => [label, rate];
}

class ExpiringSubscription extends Equatable {
  const ExpiringSubscription({required this.name, required this.endsAt});
  final String name;
  final DateTime endsAt;

  @override
  List<Object?> get props => [name, endsAt];
}

class StatsReport extends Equatable {
  const StatsReport({
    required this.mealsPerDay,
    required this.popularDishes,
    required this.scholarshipCount,
    required this.subscribedCount,
    required this.slotFill,
    required this.expiring,
  });

  final List<DayCount> mealsPerDay;
  final List<NamedCount> popularDishes;
  final int scholarshipCount;
  final int subscribedCount;
  final List<SlotFill> slotFill;
  final List<ExpiringSubscription> expiring;

  @override
  List<Object?> get props => [
        mealsPerDay,
        popularDishes,
        scholarshipCount,
        subscribedCount,
        slotFill,
        expiring,
      ];
}
