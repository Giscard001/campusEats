import 'package:dio/dio.dart';
import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/menu/data/models/menu_model.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

abstract interface class MenuRemoteDataSource {
  Future<DailyMenu> getMenu(DateTime date);
  Future<List<Dish>> getAllDishes();
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  MenuRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DailyMenu> getMenu(DateTime date) async {
    final response = await _dio.requestMap(
      'GET',
      '/menus/${Fmt.apiDate(date)}',
    );
    return MenuModel.menuFromJson(response);
  }

  @override
  Future<List<Dish>> getAllDishes() async {
    final list = await _dio.requestList('GET', '/dishes');
    return [for (final j in list) MenuModel.dishFromJson(j)];
  }
}
