import 'package:campuseats/core/error/result.dart';
import 'package:campuseats/core/network/error_mapper.dart';
import 'package:campuseats/features/admin_dishes_menus/data/datasources/dishes_remote_data_source.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/entities/menu_item_input.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/repositories/dishes_repository.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

class DishesRepositoryImpl implements DishesRepository, MenuPlannerRepository {
  DishesRepositoryImpl(this._remote);

  final DishesRemoteDataSource _remote;

  @override
  Future<Result<List<Dish>>> list() => guardRequest(_remote.list);

  @override
  Future<Result<Dish>> save({String? id, required DishInput input}) => guardRequest(() => _remote.save(id: id, input: input));

  @override
  Future<Result<void>> delete(String id) => guardRequest(() => _remote.delete(id));

  @override
  Future<Result<void>> saveMenu({required DateTime date, required List<MenuItemInput> items, required bool published}) =>
      guardRequest(() => _remote.saveMenu(date: date, items: items, published: published));
}
