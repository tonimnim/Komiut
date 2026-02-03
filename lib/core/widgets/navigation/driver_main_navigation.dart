/// Driver main navigation with IndexedStack.
///
/// Uses IndexedStack to keep all screens in memory and avoid rebuilds
/// when switching tabs. Matches the passenger MainNavigation pattern.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/driver/dashboard/presentation/screens/driver_home_screen.dart';
import '../../../features/driver/earnings/presentation/screens/earnings_screen.dart';
import '../../../features/driver/queue/presentation/screens/queue_screen.dart';
import '../../../features/driver/trips/presentation/screens/driver_trips_screen.dart';
import '../../theme/app_colors.dart';

/// Provider for driver navigation tab index.
final driverNavigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation wrapper for driver screens.
///
/// Uses IndexedStack to preserve state across tab switches.
/// This prevents unnecessary rebuilds and data refetching.
class DriverMainNavigation extends ConsumerWidget {
  const DriverMainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(driverNavigationIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          DriverHomeContent(),
          QueueContent(),
          DriverTripsContent(),
          EarningsContent(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DriverNavItem(
                      index: 0,
                      currentIndex: currentIndex,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      onTap: () =>
                          ref.read(driverNavigationIndexProvider.notifier).state = 0,
                    ),
                    _DriverNavItem(
                      index: 1,
                      currentIndex: currentIndex,
                      icon: Icons.format_list_numbered_outlined,
                      activeIcon: Icons.format_list_numbered,
                      label: 'Queue',
                      onTap: () =>
                          ref.read(driverNavigationIndexProvider.notifier).state = 1,
                    ),
                    _DriverNavItem(
                      index: 2,
                      currentIndex: currentIndex,
                      icon: Icons.directions_bus_outlined,
                      activeIcon: Icons.directions_bus,
                      label: 'Trips',
                      onTap: () =>
                          ref.read(driverNavigationIndexProvider.notifier).state = 2,
                    ),
                    _DriverNavItem(
                      index: 3,
                      currentIndex: currentIndex,
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet,
                      label: 'Earnings',
                      onTap: () =>
                          ref.read(driverNavigationIndexProvider.notifier).state = 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _DriverNavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.grey[400] : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryBlue : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
