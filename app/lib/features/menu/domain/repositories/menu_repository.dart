import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

abstract interface class MenuRepository {
  Future<Result<DailyMenu>> getMenu(DateTime date);
  Future<Result<List<Dish>>> getAllDishes();
}
