/// Route Filter Bar - Filter controls for the routes list.
///
/// Provides a search field, sacco filter dropdown, and clear filters button.
/// Updates the [routeFilterStateProvider] to trigger filtering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/debounce.dart';
import '../providers/route_providers.dart';

/// A filter bar widget for filtering routes.
///
/// Contains a search field and optional sacco filter chip.
/// Also syncs with the legacy [routeSearchQueryProvider] for backward compatibility.
class RouteFilterBar extends ConsumerStatefulWidget {
  /// Creates a RouteFilterBar.
  const RouteFilterBar({
    super.key,
    this.showSaccoFilter = true,
    this.saccoOptions,
    this.placeholder = 'Search routes...',
  });

  /// Whether to show the sacco filter dropdown.
  final bool showSaccoFilter;

  /// List of sacco options for the filter dropdown.
  /// Each entry should be a map with 'id' and 'name' keys.
  final List<Map<String, String>>? saccoOptions;

  /// Placeholder text for the search field.
  final String placeholder;

  @override
  ConsumerState<RouteFilterBar> createState() => _RouteFilterBarState();
}

class _RouteFilterBarState extends ConsumerState<RouteFilterBar> {
  late TextEditingController _searchController;

  /// Debouncer for search input to reduce unnecessary API calls.
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filterState = ref.watch(routeFilterStateProvider);

    // Sync controller with filter state
    if (_searchController.text != (filterState.searchQuery ?? '')) {
      _searchController.text = filterState.searchQuery ?? '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : AppColors.textHint,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
                size: 22,
              ),
              suffixIcon: filterState.hasActiveFilters
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.grey[500] : AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: _clearFilters,
                    )
                  : null,
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Filter chips row
          if (widget.showSaccoFilter && widget.saccoOptions != null) ...[
            const SizedBox(height: 12),
            _buildFilterChips(isDark, filterState),
          ],

          // Active filters indicator
          if (filterState.hasActiveFilters) ...[
            const SizedBox(height: 8),
            _buildActiveFiltersIndicator(isDark, filterState),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, RouteFilterState filterState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // "All" chip
          _FilterChip(
            label: 'All',
            isSelected: filterState.saccoId == null,
            onTap: () => _onSaccoChanged(null),
          ),
          const SizedBox(width: 8),

          // Sacco filter chips
          ...widget.saccoOptions!.map((sacco) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: sacco['name'] ?? '',
                isSelected: filterState.saccoId == sacco['id'],
                onTap: () => _onSaccoChanged(sacco['id']),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersIndicator(
    bool isDark,
    RouteFilterState filterState,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.filter_list,
          size: 16,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 4),
        const Text(
          'Filters active',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _clearFilters,
          child: Text(
            'Clear all',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    // Debounce search to reduce unnecessary rebuilds and filtering
    _searchDebouncer.run(() {
      if (!mounted) return;

      // Update the advanced filter state
      ref.read(routeFilterStateProvider.notifier).state =
          ref.read(routeFilterStateProvider).copyWith(searchQuery: value);

      // Also update the legacy provider for backward compatibility
      ref.read(routeSearchQueryProvider.notifier).state = value;
    });
  }

  void _onSaccoChanged(String? saccoId) {
    ref.read(routeFilterStateProvider.notifier).state = ref
        .read(routeFilterStateProvider)
        .copyWith(saccoId: saccoId, clearSaccoId: saccoId == null);
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(routeFilterStateProvider.notifier).state =
        ref.read(routeFilterStateProvider).clear();

    // Also clear the legacy provider
    ref.read(routeSearchQueryProvider.notifier).state = '';
  }
}

/// Individual filter chip widget.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[300] : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
