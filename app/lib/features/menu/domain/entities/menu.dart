import 'package:equatable/equatable.dart';

class Dish extends Equatable {
  const Dish({
    required this.id,
    required this.name,
    required this.description,
    this.photoUrl,
    this.portions = 0,
    this.availablePortions = 0,
  });

  final String id;
  final String name;
  final String description;
  final String? photoUrl;
  final int portions;
  final int availablePortions;

  bool get isAvailable => availablePortions > 0;

  @override
  List<Object?> get props => [id, name, description, photoUrl, portions, availablePortions];
}

class DailyMenu extends Equatable {
  const DailyMenu({
    required this.id,
    required this.date,
    required this.dishes,
    this.published = true,
  });

  final String id;
  final DateTime date;
  final List<Dish> dishes;
  final bool published;

  @override
  List<Object?> get props => [id, date, dishes, published];
}

class DishInput extends Equatable {
  const DishInput({
    required this.name,
    required this.description,
    this.photoPath,
  });

  final String name;
  final String description;
  final String? photoPath;

  @override
  List<Object?> get props => [name, description, photoPath];
}
