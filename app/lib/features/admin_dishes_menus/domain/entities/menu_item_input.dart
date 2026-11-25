import 'package:equatable/equatable.dart';

class MenuItemInput extends Equatable {
  const MenuItemInput({
    required this.dishId,
    required this.portions,
  });

  final String dishId;
  final int portions;

  @override
  List<Object?> get props => [dishId, portions];
}
