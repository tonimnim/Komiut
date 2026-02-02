import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/route_constants.dart';

/// Bottom navigation bar for driver screens.
///
/// Provides navigation between the four main driver sections:
/// - Home (Dashboard)
/// - Queue
/// - Trips
/// - Earnings
class DriverBottomNav extends StatelessWidget {
  const DriverBottomNav({
    super.key,
    required this.currentIndex,
  });

  /// The index of the currently selected tab (0-3).
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.format_list_numbered_outlined),
          activeIcon: Icon(Icons.format_list_numbered),
          label: 'Queue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_bus_outlined),
          activeIcon: Icon(Icons.directions_bus),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Earnings',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go(RouteConstants.driverHome);
        break;
      case 1:
        context.go(RouteConstants.driverQueue);
        break;
      case 2:
        context.go(RouteConstants.driverTrips);
        break;
      case 3:
        context.go(RouteConstants.driverEarnings);
        break;
    }
  }
}
