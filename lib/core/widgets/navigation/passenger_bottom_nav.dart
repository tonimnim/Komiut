import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/route_constants.dart';

/// Bottom navigation bar for passenger screens.
///
/// Provides navigation between the four main passenger sections:
/// - Home
/// - Saccos (Discovery)
/// - Tickets
/// - Profile
class PassengerBottomNav extends StatelessWidget {
  const PassengerBottomNav({
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
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route_outlined),
          activeIcon: Icon(Icons.route),
          label: 'Routes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined),
          activeIcon: Icon(Icons.confirmation_number),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go(RouteConstants.passengerHome);
        break;
      case 1:
        context.go(RouteConstants.passengerSaccos);
        break;
      case 2:
        context.go(RouteConstants.passengerTickets);
        break;
      case 3:
        context.go(RouteConstants.sharedProfile);
        break;
    }
  }
}
