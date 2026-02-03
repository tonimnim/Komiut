/// Driver quick action buttons.
///
/// Matches passenger's QuickActions circular button design for consistency.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/navigation/driver_main_navigation.dart';

/// Circular quick action buttons for common driver tasks.
class DriverQuickActions extends ConsumerWidget {
  const DriverQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.format_list_numbered_rounded,
          label: 'Queue',
          color: AppColors.primaryBlue,
          onTap: () {
            ref.read(driverNavigationIndexProvider.notifier).state = 1;
          },
        ),
        _ActionButton(
          icon: Icons.play_circle_filled_rounded,
          label: 'Start Trip',
          color: AppColors.primaryGreen,
          onTap: () {
            ref.read(driverNavigationIndexProvider.notifier).state = 2;
          },
        ),
        _ActionButton(
          icon: Icons.history_rounded,
          label: 'History',
          color: AppColors.secondaryPurple,
          onTap: () {
            ref.read(driverNavigationIndexProvider.notifier).state = 2;
          },
        ),
        _ActionButton(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Earnings',
          color: Colors.orange,
          onTap: () {
            ref.read(driverNavigationIndexProvider.notifier).state = 3;
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
