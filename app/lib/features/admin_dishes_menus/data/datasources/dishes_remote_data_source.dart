import 'package:dio/dio.dart';

import 'package:campuseats/core/network/json_helpers.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/entities/menu_item_input.dart';
import 'package:campuseats/features/menu/data/models/menu_model.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

abstract interface class DishesRemoteDataSource {
  Future<List<Dish>> list();
  Future<Dish> save({String? id, required DishInput input});
  Future<void> delete(String id);
  Future<void> saveMenu({required DateTime date, required List<MenuItemInput> items, required bool published});
}

class DishesRemoteDataSourceImpl implements DishesRemoteDataSource {
  DishesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Dish>> list() async => [
        for (final j in await _dio.requestList('GET', '/dishes', query: {'limit': 50})) MenuModel.dishFromJson(j),
      ];

  @override
  Future<Dish> save({String? id, required DishInput input}) async {
    final body = {'name': input.name, 'description': input.description};
    var json = id == null
        ? await _dio.requestMap('POST', '/dishes', data: body)
        : await _dio.requestMap('PUT', '/dishes/$id', data: body);
    final photoPath = input.photoPath;
    if (photoPath != null) {
      final form = FormData.fromMap({'photo': await MultipartFile.fromFile(photoPath)});
      json = await _dio.requestMap('POST', '/dishes/${jsonString(json, 'id')}/photo', data: form);
    }
    return MenuModel.dishFromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.requestMap('DELETE', '/dishes/$id');
  }

  @override
  Future<void> saveMenu({required DateTime date, required List<MenuItemInput> items, required bool published}) async {
    await _dio.requestMap(
      'PUT',
      '/menus/${Fmt.apiDate(date)}',
      data: {
        'dishes': [
          for (final i in items) {'dishId': i.dishId, 'portions': i.portions},
        ],
        'published': published,
      },
    );
  }
}
