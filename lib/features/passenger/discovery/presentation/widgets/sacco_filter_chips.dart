/// SaccoFilterChips - Filter chips for sacco list filtering.
///
/// Provides filter options for the sacco discovery screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../providers/sacco_providers.dart';

/// Available filter options for saccos.
enum SaccoFilter {
  /// Show all saccos.
  all,

  /// Show only active saccos.
  active,

  /// Show popular saccos.
  popular,
}

/// Extension methods for SaccoFilter.
extension SaccoFilterX on SaccoFilter {
  /// Display label for the filter.
  String get label {
    switch (this) {
      case SaccoFilter.all:
        return 'All Saccos';
      case SaccoFilter.active:
        return 'Active';
      case SaccoFilter.popular:
        return 'Popular';
    }
  }

  /// Icon for the filter.
  IconData get icon {
    switch (this) {
      case SaccoFilter.all:
        return Icons.list_alt;
      case SaccoFilter.active:
        return Icons.check_circle_outline;
      case SaccoFilter.popular:
        return Icons.trending_up;
    }
  }
}

/// Provider for the selected sacco filter.
final saccoFilterProvider = StateProvider<SaccoFilter>((ref) => SaccoFilter.all);

/// A horizontally scrollable row of filter chips for saccos.
class SaccoFilterChips extends ConsumerWidget {
  /// Creates SaccoFilterChips.
  const SaccoFilterChips({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedFilter = ref.watch(saccoFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: SaccoFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = SaccoFilter.values[index];
          final isSelected = filter == selectedFilter;

          return _FilterChip(
            label: filter.label,
            icon: filter.icon,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () {
              ref.read(saccoFilterProvider.notifier).state = filter;
              // Update the showActiveSaccosOnly provider based on filter
              if (filter == SaccoFilter.active) {
                ref.read(showActiveSaccosOnlyProvider.notifier).state = true;
              } else if (filter == SaccoFilter.all) {
                ref.read(showActiveSaccosOnlyProvider.notifier).state = false;
              }
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isSelected
        ? AppColors.primaryBlue
        : (isDark ? Colors.grey[800] : Colors.grey[100]);

    final foregroundColor = isSelected
        ? Colors.white
        : (isDark ? Colors.grey[300] : AppColors.textSecondary);

    final borderColor = isSelected
        ? AppColors.primaryBlue
        : (isDark ? Colors.grey[700] : Colors.grey[300]);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: foregroundColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
