/// Driver Stats Row - Shows today's trip and passenger statistics.
///
/// A horizontal row of stat cards displaying trips and passengers,
/// without earnings information.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/cards/app_card.dart';

/// A widget that displays driver statistics in a horizontal row.
///
/// Shows:
/// - Trips today count
/// - Passengers today count
class DriverStatsRow extends StatelessWidget {
  /// Creates a DriverStatsRow.
  const DriverStatsRow({
    super.key,
    required this.tripsToday,
    required this.passengersToday,
    this.onTripsTap,
    this.onPassengersTap,
  });

  /// Number of trips completed today.
  final int tripsToday;

  /// Number of passengers transported today.
  final int passengersToday;

  /// Callback when the trips card is tapped.
  final VoidCallback? onTripsTap;

  /// Callback when the passengers card is tapped.
  final VoidCallback? onPassengersTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.directions_bus_rounded,
            value: tripsToday,
            label: 'trips today',
            iconColor: AppColors.primaryBlue,
            backgroundColor: AppColors.pillBlueBg,
            onTap: onTripsTap,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatTile(
            icon: Icons.people_outline,
            value: passengersToday,
            label: 'passengers',
            iconColor: AppColors.primaryGreen,
            backgroundColor: AppColors.pillGreenBg,
            onTap: onPassengersTap,
          ),
        ),
      ],
    );
  }
}

/// Individual stat tile showing an icon, value, and label.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extended stats row with additional metrics.
///
/// Use this variant when more statistics need to be displayed.
class DriverStatsRowExtended extends StatelessWidget {
  /// Creates a DriverStatsRowExtended.
  const DriverStatsRowExtended({
    super.key,
    required this.stats,
    this.onStatTap,
  });

  /// List of stat items to display.
  final List<DriverStatItem> stats;

  /// Callback when a stat is tapped, receives the stat index.
  final void Function(int index)? onStatTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine how many items per row based on width
        final itemsPerRow = constraints.maxWidth > 400 ? 4 : 2;
        final itemWidth = (constraints.maxWidth - (itemsPerRow - 1) * AppSpacing.md) / itemsPerRow;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: List.generate(stats.length, (index) {
            final stat = stats[index];
            return SizedBox(
              width: itemWidth,
              child: _StatTile(
                icon: stat.icon,
                value: stat.value,
                label: stat.label,
                iconColor: stat.iconColor,
                backgroundColor: stat.backgroundColor,
                onTap: onStatTap != null ? () => onStatTap!(index) : null,
              ),
            );
          }),
        );
      },
    );
  }
}

/// Data class for a single stat item.
class DriverStatItem {
  /// Creates a DriverStatItem.
  const DriverStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
  });

  /// Icon to display.
  final IconData icon;

  /// Numeric value.
  final int value;

  /// Label text.
  final String label;

  /// Color of the icon.
  final Color iconColor;

  /// Background color of the icon container.
  final Color backgroundColor;
}
