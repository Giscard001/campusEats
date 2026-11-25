import 'package:equatable/equatable.dart';

class SlotConfig extends Equatable {
  const SlotConfig({
    required this.id,
    required this.label,
    required this.capacity,
    this.active = true,
  });

  final String id;
  final String label;
  final int capacity;
  final bool active;

  SlotConfig copyWith({String? id, String? label, int? capacity, bool? active}) => SlotConfig(
        id: id ?? this.id,
        label: label ?? this.label,
        capacity: capacity ?? this.capacity,
        active: active ?? this.active,
      );

  @override
  List<Object?> get props => [id, label, capacity, active];
}

class SlotsConfig extends Equatable {
  const SlotsConfig({
    required this.cutoffTime,
    required this.slots,
  });

  final String cutoffTime;
  final List<SlotConfig> slots;

  SlotsConfig copyWith({String? cutoffTime, List<SlotConfig>? slots}) => SlotsConfig(
        cutoffTime: cutoffTime ?? this.cutoffTime,
        slots: slots ?? this.slots,
      );

  @override
  List<Object?> get props => [cutoffTime, slots];
}
