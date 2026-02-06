/// Next Stop Widget - Shows upcoming stop information during a trip.
///
/// Displays the next stop name and expected passenger activity
/// (pickups/dropoffs) at that location.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/cards/app_card.dart';

/// A widget that displays information about the next stop.
///
/// Shows:
/// - "NEXT STOP" label
/// - Stop name with location icon
/// - Expected pickups/dropoffs
class NextStopWidget extends StatelessWidget {
  /// Creates a NextStopWidget.
  const NextStopWidget({
    super.key,
    required this.stopName,
    this.pickupsExpected = 0,
    this.dropoffsExpected = 0,
    this.onTap,
  });

  /// The name of the next stop.
  final String stopName;

  /// Number of passengers expected to board at this stop.
  final int pickupsExpected;

  /// Number of passengers expected to alight at this stop.
  final int dropoffsExpected;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            'NEXT STOP',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ),
        // Stop card
        AppCard(
          onTap: onTap,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stop name row
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      stopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              // Activity indicators
              if (pickupsExpected > 0 || dropoffsExpected > 0) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    if (pickupsExpected > 0) ...[
                      _ActivityIndicator(
                        icon: Icons.person_add_alt_1_outlined,
                        count: pickupsExpected,
                        label: pickupsExpected == 1
                            ? 'pickup expected'
                            : 'pickups expected',
                        color: AppColors.primaryGreen,
                      ),
                      if (dropoffsExpected > 0)
                        const SizedBox(width: AppSpacing.md),
                    ],
                    if (dropoffsExpected > 0)
                      _ActivityIndicator(
                        icon: Icons.person_remove_alt_1_outlined,
                        count: dropoffsExpected,
                        label: dropoffsExpected == 1
                            ? 'dropoff expected'
                            : 'dropoffs expected',
                        color: AppColors.primaryOrange,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Activity indicator showing expected pickups or dropoffs.
class _ActivityIndicator extends StatelessWidget {
  const _ActivityIndicator({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
