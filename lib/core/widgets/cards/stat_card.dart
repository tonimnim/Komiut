/// StatCard - Statistics display card.
///
/// A card for displaying a statistic with optional trend indicator.
library;

import 'package:flutter/material.dart';

import 'app_card.dart';

/// Trend direction for stats.
enum StatTrend {
  /// Value is increasing.
  up,

  /// Value is decreasing.
  down,

  /// Value is unchanged.
  neutral,
}

/// A card for displaying statistics with trend.
class StatCard extends StatelessWidget {
  /// Creates a StatCard.
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendValue,
    this.backgroundColor,
    this.valueColor,
    this.onTap,
    this.compact = false,
  });

  /// Label describing the stat.
  final String label;

  /// The stat value.
  final String value;

  /// Optional icon.
  final IconData? icon;

  /// Trend direction.
  final StatTrend? trend;

  /// Trend value (e.g., "+12%").
  final String? trendValue;

  /// Background color.
  final Color? backgroundColor;

  /// Value text color.
  final Color? valueColor;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      padding: compact
          ? const EdgeInsets.all(12)
          : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: compact ? 16 : 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: (compact
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            value,
            style: (compact
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall)
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          if (trend != null && trendValue != null) ...[
            const SizedBox(height: 4),
            _TrendIndicator(
              trend: trend!,
              value: trendValue!,
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({
    required this.trend,
    required this.value,
  });

  final StatTrend trend;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = switch (trend) {
      StatTrend.up => Colors.green,
      StatTrend.down => Colors.red,
      StatTrend.neutral => Colors.grey,
    };

    final icon = switch (trend) {
      StatTrend.up => Icons.trending_up,
      StatTrend.down => Icons.trending_down,
      StatTrend.neutral => Icons.trending_flat,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
