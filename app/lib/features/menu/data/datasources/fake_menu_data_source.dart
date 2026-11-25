import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';

class FakeMenuDataSource implements MenuRemoteDataSource {
  final List<Dish> _allDishes = [
    const Dish(
      id: 'dish_1',
      name: 'Riz gras au bœuf & légumes locaux',
      description: 'Riz braisé dans un bouillon de bœuf parfumé, carottes du pays, choux et piment doux.',
      portions: 120,
      availablePortions: 48,
    ),
    const Dish(
      id: 'dish_2',
      name: 'Tô de maïs & sauce gombo frais',
      description: 'Pâte de maïs blanc traditionnel accompagnée d\'une sauce gombo onctueuse et poisson fumé.',
      portions: 80,
      availablePortions: 15,
    ),
    const Dish(
      id: 'dish_3',
      name: 'Haricots verts sautés & poulet bicyclette',
      description: 'Haricots verts sautés à l\'ail, sauce tomate fraîche et morceau de poulet local grillé.',
      portions: 90,
      availablePortions: 0, // épuisé
    ),
    const Dish(
      id: 'dish_4',
      name: 'Alloco & poisson capitaine braisé',
      description: 'Bananes plantains frites dorées accompagnées de filets de capitaine et sauce pimentée.',
      portions: 100,
      availablePortions: 65,
    ),
  ];

  @override
  Future<DailyMenu> getMenu(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DailyMenu(
      id: 'menu_${Fmt.apiDate(date)}',
      date: date,
      published: true,
      dishes: _allDishes,
    );
  }

  @override
  Future<List<Dish>> getAllDishes() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _allDishes;
  }
}
