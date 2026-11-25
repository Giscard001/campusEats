import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:campuseats/features/admin_dishes_menus/presentation/pages/add_dish_page.dart';
import 'package:campuseats/features/admin_dishes_menus/presentation/pages/dishes_catalogue_page.dart';
import 'package:campuseats/features/admin_dishes_menus/presentation/pages/menu_planner_page.dart';
import 'package:campuseats/features/admin_scholarships/presentation/pages/pending_accounts_page.dart';
import 'package:campuseats/features/admin_scholarships/presentation/pages/scholarships_list_page.dart';
import 'package:campuseats/features/admin_shell.dart';
import 'package:campuseats/features/admin_slots/presentation/pages/slots_config_page.dart';
import 'package:campuseats/features/admin_stats/presentation/pages/admin_stats_page.dart';
import 'package:campuseats/features/admin_users/presentation/pages/create_staff_account_page.dart';
import 'package:campuseats/features/admin_users/presentation/pages/users_list_page.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:campuseats/features/auth/presentation/pages/login_page.dart';
import 'package:campuseats/features/auth/presentation/pages/pending_account_page.dart';
import 'package:campuseats/features/auth/presentation/pages/register_page.dart';
import 'package:campuseats/features/auth/presentation/pages/splash_page.dart';
import 'package:campuseats/features/menu/domain/entities/menu.dart';
import 'package:campuseats/features/menu/presentation/pages/daily_menu_page.dart';
import 'package:campuseats/features/notifications/presentation/pages/notifications_page.dart';
import 'package:campuseats/features/orders/domain/entities/order.dart';
import 'package:campuseats/features/orders/presentation/pages/choose_slot_page.dart';
import 'package:campuseats/features/orders/presentation/pages/my_orders_page.dart';
import 'package:campuseats/features/orders/presentation/pages/order_confirmed_page.dart';
import 'package:campuseats/features/orders/presentation/pages/today_qr_page.dart';
import 'package:campuseats/features/profile/presentation/pages/identity_qr_page.dart';
import 'package:campuseats/features/profile/presentation/pages/profile_page.dart';
import 'package:campuseats/features/staff_orders/presentation/pages/staff_orders_page.dart';
import 'package:campuseats/features/staff_scan/presentation/pages/staff_scanner_page.dart';
import 'package:campuseats/features/staff_shell.dart';
import 'package:campuseats/features/student_shell.dart';
import 'package:campuseats/features/subscriptions/presentation/pages/register_subscription_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // 1. Splash & Auth
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/pending',
        builder: (context, state) => const PendingAccountPage(),
      ),

      // 2. Student Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => StudentShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/home',
                builder: (context, state) => const DailyMenuPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/today-qr',
                builder: (context, state) => const TodayQrPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/orders',
                builder: (context, state) => const MyOrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Student sub-routes outside bottom bar
      GoRoute(
        path: '/student/choose-slot',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final dish = state.extra as Dish;
          return ChooseSlotPage(dish: dish);
        },
      ),
      GoRoute(
        path: '/student/order-confirmed',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderConfirmedPage(order: order);
        },
      ),
      GoRoute(
        path: '/student/identity-qr',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IdentityQrPage(),
      ),
      GoRoute(
        path: '/student/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),

      // 3. Staff Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => StaffShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/scanner',
                builder: (context, state) => const StaffScannerPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/orders',
                builder: (context, state) => const StaffOrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/subscriptions',
                builder: (context, state) => const RegisterSubscriptionPage(),
              ),
            ],
          ),
        ],
      ),

      // 4. Admin Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const AdminDashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dishes',
                builder: (context, state) => const DishesCataloguePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/scholarships',
                builder: (context, state) => const ScholarshipsListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                builder: (context, state) => const UsersListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/stats',
                builder: (context, state) => const AdminStatsPage(),
              ),
            ],
          ),
        ],
      ),

      // Admin sub-routes
      GoRoute(
        path: '/admin/dishes/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddDishPage(),
      ),
      GoRoute(
        path: '/admin/menu-planner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MenuPlannerPage(),
      ),
      GoRoute(
        path: '/admin/slots-config',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SlotsConfigPage(),
      ),
      GoRoute(
        path: '/admin/pending-accounts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PendingAccountsPage(),
      ),
      GoRoute(
        path: '/admin/users/create-staff',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateStaffAccountPage(),
      ),
    ],
  );
}
