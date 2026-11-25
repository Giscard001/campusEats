import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

abstract final class MenuModel {
  static Dish dishFromJson(Map<String, dynamic> j) {
    return Dish(
      id: jsonString(j, 'id'),
      name: jsonString(j, 'name'),
      description: jsonStringOrNull(j, 'description') ?? '',
      photoUrl: jsonStringOrNull(j, 'photoUrl') ?? jsonStringOrNull(j, 'photo'),
      portions: jsonInt(j, 'portions'),
      availablePortions: j.containsKey('availablePortions')
          ? jsonInt(j, 'availablePortions')
          : jsonInt(j, 'portions'),
    );
  }

  static Map<String, dynamic> dishToJson(Dish dish) => {
        'id': dish.id,
        'name': dish.name,
        'description': dish.description,
        if (dish.photoUrl != null) 'photoUrl': dish.photoUrl,
        'portions': dish.portions,
        'availablePortions': dish.availablePortions,
      };

  static DailyMenu menuFromJson(Map<String, dynamic> j) {
    final rawDate = j['date'];
    final parsedDate = rawDate is String ? Fmt.parseApiDate(rawDate) : DateTime.now();
    final rawDishes = j['dishes'] as List? ?? const [];

    return DailyMenu(
      id: jsonString(j, 'id'),
      date: parsedDate,
      published: j['published'] != false,
      dishes: [for (final d in rawDishes) dishFromJson(asJsonMap(d))],
    );
  }

  static Map<String, dynamic> menuToJson(DailyMenu menu) => {
        'id': menu.id,
        'date': Fmt.apiDate(menu.date),
        'published': menu.published,
        'dishes': [for (final d in menu.dishes) dishToJson(d)],
      };
}
