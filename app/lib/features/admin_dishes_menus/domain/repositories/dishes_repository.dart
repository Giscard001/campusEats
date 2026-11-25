import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/entities/menu_item_input.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

abstract interface class DishesRepository {
  Future<Result<List<Dish>>> list();
  Future<Result<Dish>> save({String? id, required DishInput input});
  Future<Result<void>> delete(String id);
}

abstract interface class MenuPlannerRepository {
  Future<Result<void>> saveMenu({
    required DateTime date,
    required List<MenuItemInput> items,
    required bool published,
  });
}
