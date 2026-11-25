import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuseats/core/theme/app_colors.dart';

class StaffShell extends StatelessWidget {
  const StaffShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_list_outlined),
            selectedIcon: Icon(Icons.view_list_rounded, color: AppColors.primary),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_membership_outlined),
            selectedIcon: Icon(Icons.card_membership_rounded, color: AppColors.primary),
            label: 'Abonnements',
          ),
        ],
      ),
    );
  }
}
