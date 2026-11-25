import 'package:get_it/get_it.dart';
import 'package:campuseats/core/config/app_config.dart';
import 'package:campuseats/core/network/auth_interceptor.dart';
import 'package:campuseats/core/network/dio_client.dart';
import 'package:campuseats/core/services/connectivity_service.dart';
import 'package:campuseats/core/services/push_service.dart';
import 'package:campuseats/core/storage/cache_store.dart';
import 'package:campuseats/core/storage/secure_token_storage.dart';
import 'package:campuseats/core/time/server_clock.dart';
import 'package:campuseats/features/admin_dishes_menus/data/datasources/dishes_remote_data_source.dart';
import 'package:campuseats/features/admin_dishes_menus/data/repositories/dishes_repository_impl.dart';
import 'package:campuseats/features/admin_dishes_menus/domain/repositories/dishes_repository.dart';
import 'package:campuseats/features/admin_scholarships/data/datasources/scholarships_remote_data_source.dart';
import 'package:campuseats/features/admin_scholarships/data/repositories/scholarships_repository_impl.dart';
import 'package:campuseats/features/admin_scholarships/domain/repositories/scholarships_repository.dart';
import 'package:campuseats/features/admin_slots/data/datasources/slots_config_remote_data_source.dart';
import 'package:campuseats/features/admin_slots/data/repositories/slots_config_repository_impl.dart';
import 'package:campuseats/features/admin_slots/domain/repositories/slots_config_repository.dart';
import 'package:campuseats/features/admin_stats/data/datasources/stats_remote_data_source.dart';
import 'package:campuseats/features/admin_stats/data/repositories/stats_repository_impl.dart';
import 'package:campuseats/features/admin_stats/domain/repositories/stats_repository.dart';
import 'package:campuseats/features/admin_users/data/datasources/users_remote_data_source.dart';
import 'package:campuseats/features/admin_users/data/repositories/users_repository_impl.dart';
import 'package:campuseats/features/admin_users/domain/repositories/users_repository.dart';
import 'package:campuseats/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:campuseats/features/auth/data/datasources/fake_auth_data_source.dart';
import 'package:campuseats/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:campuseats/features/auth/domain/repositories/auth_repository.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:campuseats/features/menu/data/datasources/fake_menu_data_source.dart';
import 'package:campuseats/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:campuseats/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:campuseats/features/menu/domain/repositories/menu_repository.dart';
import 'package:campuseats/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:campuseats/features/orders/data/datasources/fake_orders_data_source.dart';
import 'package:campuseats/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:campuseats/features/orders/data/repositories/order_repository_impl.dart';
import 'package:campuseats/features/orders/domain/repositories/order_repository.dart';
import 'package:campuseats/features/staff_orders/data/datasources/fake_staff_orders_data_source.dart';
import 'package:campuseats/features/staff_orders/data/datasources/staff_orders_remote_data_source.dart';
import 'package:campuseats/features/staff_orders/data/repositories/staff_orders_repository_impl.dart';
import 'package:campuseats/features/staff_orders/domain/repositories/staff_orders_repository.dart';
import 'package:campuseats/features/staff_scan/data/repositories/scanner_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initDependencies({required AppConfig config}) async {
  sl.registerSingleton<AppConfig>(config);

  // 1. Core Services & Storage
  final tokenStorage = SecureTokenStorage();
  sl.registerSingleton<TokenStorage>(tokenStorage);

  final cacheStore = MemoryCacheStore();
  sl.registerSingleton<CacheStore>(cacheStore);

  final serverClock = ServerClock();
  sl.registerSingleton<ServerClock>(serverClock);

  final connectivityService = ConnectivityService();
  sl.registerSingleton<ConnectivityService>(connectivityService);

  final pushService = PushService();
  sl.registerSingleton<PushService>(pushService);

  // 2. Network Client
  final dioClient = DioClient(
    config: config,
    tokenStorage: tokenStorage,
    serverClock: serverClock,
  );
  sl.registerSingleton<DioClient>(dioClient);

  // 3. Data Sources & Repositories
  if (config.useMocks) {
    // Auth
    final fakeAuth = FakeAuthDataSource();
    sl.registerSingleton<AuthRemoteDataSource>(fakeAuth);
    sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(
      remoteDataSource: fakeAuth,
      tokenStorage: tokenStorage,
      cacheStore: cacheStore,
    ));

    // Menu
    final fakeMenu = FakeMenuDataSource();
    sl.registerSingleton<MenuRemoteDataSource>(fakeMenu);
    sl.registerSingleton<MenuRepository>(MenuRepositoryImpl(
      remoteDataSource: fakeMenu,
      cacheStore: cacheStore,
    ));

    // Orders
    final fakeOrders = FakeOrdersDataSource();
    sl.registerSingleton<OrdersRemoteDataSource>(fakeOrders);
    sl.registerSingleton<OrderRepository>(OrderRepositoryImpl(
      remoteDataSource: fakeOrders,
      cacheStore: cacheStore,
    ));

    // Staff Scan
    sl.registerSingleton<ScannerRepository>(FakeScannerRepository());

    // Staff Orders
    final fakeStaffOrders = FakeStaffOrdersDataSource();
    sl.registerSingleton<StaffOrdersRemoteDataSource>(fakeStaffOrders);
    sl.registerSingleton<StaffOrdersRepository>(StaffOrdersRepositoryImpl(fakeStaffOrders));

    // Admin Dishes
    final dishesDs = DishesRemoteDataSourceImpl(dioClient.base);
    final dishesRepo = DishesRepositoryImpl(dishesDs);
    sl.registerSingleton<DishesRepository>(dishesRepo);
    sl.registerSingleton<MenuPlannerRepository>(dishesRepo);

    // Admin Slots
    final slotsDs = SlotsConfigRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<SlotsConfigRepository>(SlotsConfigRepositoryImpl(slotsDs));

    // Admin Scholarships
    final scholarDs = ScholarshipsRemoteDataSourceImpl(dioClient.base);
    final scholarRepo = ScholarshipsRepositoryImpl(scholarDs);
    sl.registerSingleton<ScholarshipsRepository>(scholarRepo);
    sl.registerSingleton<PendingAccountsRepository>(scholarRepo);

    // Admin Users
    final usersDs = UsersRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<UsersRepository>(UsersRepositoryImpl(usersDs));

    // Admin Stats
    final statsDs = StatsRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<StatsRepository>(StatsRepositoryImpl(statsDs));
  } else {
    // Real Remote Implementations
    final authDs = AuthRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<AuthRemoteDataSource>(authDs);
    sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(
      remoteDataSource: authDs,
      tokenStorage: tokenStorage,
      cacheStore: cacheStore,
    ));

    final menuDs = MenuRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<MenuRemoteDataSource>(menuDs);
    sl.registerSingleton<MenuRepository>(MenuRepositoryImpl(
      remoteDataSource: menuDs,
      cacheStore: cacheStore,
    ));

    final ordersDs = OrdersRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<OrdersRemoteDataSource>(ordersDs);
    sl.registerSingleton<OrderRepository>(OrderRepositoryImpl(
      remoteDataSource: ordersDs,
      cacheStore: cacheStore,
    ));

    sl.registerSingleton<ScannerRepository>(ScannerRepositoryImpl(dioClient.base));

    final staffOrdersDs = StaffOrdersRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<StaffOrdersRemoteDataSource>(staffOrdersDs);
    sl.registerSingleton<StaffOrdersRepository>(StaffOrdersRepositoryImpl(staffOrdersDs));

    final dishesDs = DishesRemoteDataSourceImpl(dioClient.base);
    final dishesRepo = DishesRepositoryImpl(dishesDs);
    sl.registerSingleton<DishesRepository>(dishesRepo);
    sl.registerSingleton<MenuPlannerRepository>(dishesRepo);

    final slotsDs = SlotsConfigRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<SlotsConfigRepository>(SlotsConfigRepositoryImpl(slotsDs));

    final scholarDs = ScholarshipsRemoteDataSourceImpl(dioClient.base);
    final scholarRepo = ScholarshipsRepositoryImpl(scholarDs);
    sl.registerSingleton<ScholarshipsRepository>(scholarRepo);
    sl.registerSingleton<PendingAccountsRepository>(scholarRepo);

    final usersDs = UsersRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<UsersRepository>(UsersRepositoryImpl(usersDs));

    final statsDs = StatsRemoteDataSourceImpl(dioClient.base);
    sl.registerSingleton<StatsRepository>(StatsRepositoryImpl(statsDs));
  }

  // 4. Blocs
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(
        authRepository: sl<AuthRepository>(),
        tokenStorage: sl<TokenStorage>(),
      ));

  sl.registerFactory<MenuBloc>(() => MenuBloc(
        menuRepository: sl<MenuRepository>(),
        serverClock: sl<ServerClock>(),
      ));
}
