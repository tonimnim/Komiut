/// Stop selector widget for choosing pickup and dropoff stops.
///
/// Displays route stops in order with selection controls and
/// fare preview between selected stops.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../shared/routes/domain/entities/route_entity.dart';
import '../providers/booking_flow_provider.dart';

/// Widget for selecting pickup and dropoff stops on a route.
class StopSelector extends ConsumerWidget {
  /// Creates a StopSelector.
  const StopSelector({
    super.key,
    required this.route,
    this.onStopsSelected,
    this.showFarePreview = true,
    this.compact = false,
  });

  /// The route to select stops from.
  final RouteEntity route;

  /// Callback when stops are selected.
  final void Function(int pickupIndex, int dropoffIndex)? onStopsSelected;

  /// Whether to show the fare preview.
  final bool showFarePreview;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingFlowProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selection indicators
        _StopSelectionIndicators(
          route: route,
          pickupStopIndex: bookingState.pickupStopIndex,
          dropoffStopIndex: bookingState.dropoffStopIndex,
        ),
        const SizedBox(height: 16),

        // Fare preview
        if (showFarePreview && bookingState.hasValidStops) ...[
          _FarePreviewCard(
            route: route,
            pickupIndex: bookingState.pickupStopIndex!,
            dropoffIndex: bookingState.dropoffStopIndex!,
            passengerCount: bookingState.passengerCount,
          ),
          const SizedBox(height: 16),
        ],

        // Stops list header
        Text(
          'Select Stops',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Stops list
        Expanded(
          child: _StopsList(
            route: route,
            pickupStopIndex: bookingState.pickupStopIndex,
            dropoffStopIndex: bookingState.dropoffStopIndex,
            compact: compact,
            onPickupSelected: (index) {
              ref.read(bookingFlowProvider.notifier).selectPickupStop(index);
              _checkAndNotify(ref, index, bookingState.dropoffStopIndex);
            },
            onDropoffSelected: (index) {
              ref.read(bookingFlowProvider.notifier).selectDropoffStop(index);
              _checkAndNotify(ref, bookingState.pickupStopIndex, index);
            },
          ),
        ),
      ],
    );
  }

  void _checkAndNotify(WidgetRef ref, int? pickupIndex, int? dropoffIndex) {
    if (pickupIndex != null &&
        dropoffIndex != null &&
        dropoffIndex > pickupIndex) {
      onStopsSelected?.call(pickupIndex, dropoffIndex);
    }
  }
}

/// Compact stop selector for dropdown/sheet usage.
class CompactStopSelector extends ConsumerWidget {
  /// Creates a CompactStopSelector.
  const CompactStopSelector({
    super.key,
    required this.route,
    required this.isPickup,
    required this.onStopSelected,
    this.disabledIndices = const [],
  });

  /// The route to select stops from.
  final RouteEntity route;

  /// Whether selecting pickup (true) or dropoff (false).
  final bool isPickup;

  /// Callback when a stop is selected.
  final void Function(int index) onStopSelected;

  /// Indices that should be disabled.
  final List<int> disabledIndices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: route.stops.length,
      itemBuilder: (context, index) {
        final stop = route.stops[index];
        final isDisabled = disabledIndices.contains(index);
        final isFirst = index == 0;
        final isLast = index == route.stops.length - 1;

        return ListTile(
          onTap: isDisabled ? null : () => onStopSelected(index),
          leading: _StopIndicator(
            isFirst: isFirst,
            isLast: isLast,
            isDisabled: isDisabled,
            color: isPickup ? AppColors.primaryGreen : AppColors.error,
          ),
          title: Text(
            stop,
            style: TextStyle(
              color: isDisabled
                  ? (isDark ? Colors.grey[600] : Colors.grey[400])
                  : theme.colorScheme.onSurface,
              fontWeight: isDisabled ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          trailing: isDisabled
              ? Icon(
                  Icons.block,
                  size: 16,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                )
              : Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
        );
      },
    );
  }
}

/// Stop selection indicators showing current selection state.
class _StopSelectionIndicators extends StatelessWidget {
  const _StopSelectionIndicators({
    required this.route,
    this.pickupStopIndex,
    this.dropoffStopIndex,
  });

  final RouteEntity route;
  final int? pickupStopIndex;
  final int? dropoffStopIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _SelectionCard(
            label: 'From',
            value: pickupStopIndex != null
                ? route.stops[pickupStopIndex!]
                : 'Select pickup',
            isSelected: pickupStopIndex != null,
            color: AppColors.primaryGreen,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.arrow_forward,
            size: 20,
            color: isDark ? Colors.grey[500] : AppColors.textHint,
          ),
        ),
        Expanded(
          child: _SelectionCard(
            label: 'To',
            value: dropoffStopIndex != null
                ? route.stops[dropoffStopIndex!]
                : 'Select dropoff',
            isSelected: dropoffStopIndex != null,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

/// Selection card for displaying pickup/dropoff stop.
class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.color,
  });

  final String label;
  final String value;
  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? color
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : (isDark ? Colors.grey[500] : AppColors.textHint),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Fare preview card showing estimated fare.
class _FarePreviewCard extends StatelessWidget {
  const _FarePreviewCard({
    required this.route,
    required this.pickupIndex,
    required this.dropoffIndex,
    required this.passengerCount,
  });

  final RouteEntity route;
  final int pickupIndex;
  final int dropoffIndex;
  final int passengerCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fare = route.calculateFare(pickupIndex, dropoffIndex);
    final totalFare = fare * passengerCount;
    final stopsCount = dropoffIndex - pickupIndex;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$stopsCount ${stopsCount == 1 ? 'stop' : 'stops'} '
                  '${passengerCount > 1 ? '($passengerCount passengers)' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Estimated fare: ${route.formatFare(totalFare)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of stops with selection controls.
class _StopsList extends StatelessWidget {
  const _StopsList({
    required this.route,
    this.pickupStopIndex,
    this.dropoffStopIndex,
    required this.onPickupSelected,
    required this.onDropoffSelected,
    this.compact = false,
  });

  final RouteEntity route;
  final int? pickupStopIndex;
  final int? dropoffStopIndex;
  final void Function(int index) onPickupSelected;
  final void Function(int index) onDropoffSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: route.stops.length,
      itemBuilder: (context, index) {
        final stop = route.stops[index];
        final isPickup = pickupStopIndex == index;
        final isDropoff = dropoffStopIndex == index;
        final isFirst = index == 0;
        final isLast = index == route.stops.length - 1;

        // Determine if stop can be selected for dropoff
        // (must be after pickup)
        final canSelectAsDropoff =
            pickupStopIndex != null && index > pickupStopIndex!;

        return _StopTile(
          name: stop,
          index: index,
          isFirst: isFirst,
          isLast: isLast,
          isPickupSelected: isPickup,
          isDropoffSelected: isDropoff,
          canSelectAsDropoff: canSelectAsDropoff,
          compact: compact,
          onPickupTap: () => onPickupSelected(index),
          onDropoffTap: canSelectAsDropoff || pickupStopIndex == null
              ? () => onDropoffSelected(index)
              : null,
        );
      },
    );
  }
}

/// Single stop tile with timeline and selection buttons.
class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.name,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.isPickupSelected,
    required this.isDropoffSelected,
    required this.canSelectAsDropoff,
    required this.onPickupTap,
    this.onDropoffTap,
    this.compact = false,
  });

  final String name;
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isPickupSelected;
  final bool isDropoffSelected;
  final bool canSelectAsDropoff;
  final VoidCallback onPickupTap;
  final VoidCallback? onDropoffTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: compact ? 4 : 8,
                  color: isFirst
                      ? Colors.transparent
                      : (isDark ? Colors.grey[700] : Colors.grey[300]),
                ),
                Container(
                  width: isFirst || isLast ? 10 : 6,
                  height: isFirst || isLast ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPickupSelected
                        ? AppColors.primaryGreen
                        : isDropoffSelected
                            ? AppColors.error
                            : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
                Container(
                  width: 2,
                  height: compact ? 20 : 32,
                  color: isLast
                      ? Colors.transparent
                      : (isDark ? Colors.grey[700] : Colors.grey[300]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Stop name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: compact ? 13 : 14,
                  fontWeight: isPickupSelected || isDropoffSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isPickupSelected || isDropoffSelected
                      ? theme.colorScheme.onSurface
                      : (isDark ? Colors.grey[400] : AppColors.textSecondary),
                ),
              ),
            ),
          ),

          // Selection buttons
          Row(
            children: [
              _SelectButton(
                label: 'From',
                isSelected: isPickupSelected,
                color: AppColors.primaryGreen,
                onTap: onPickupTap,
                compact: compact,
              ),
              SizedBox(width: compact ? 4 : 8),
              _SelectButton(
                label: 'To',
                isSelected: isDropoffSelected,
                color: AppColors.error,
                onTap: onDropoffTap,
                isDisabled: onDropoffTap == null,
                compact: compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Selection button for From/To.
class _SelectButton extends StatelessWidget {
  const _SelectButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.isDisabled = false,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled ? Colors.grey : color;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? effectiveColor
                : effectiveColor.withValues(alpha: isDisabled ? 0.3 : 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDisabled
                    ? effectiveColor.withValues(alpha: 0.5)
                    : effectiveColor),
          ),
        ),
      ),
    );
  }
}

/// Stop indicator icon.
class _StopIndicator extends StatelessWidget {
  const _StopIndicator({
    required this.isFirst,
    required this.isLast,
    required this.isDisabled,
    required this.color,
  });

  final bool isFirst;
  final bool isLast;
  final bool isDisabled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDisabled ? Colors.grey[400] : color,
        border: isFirst || isLast
            ? Border.all(
                color: isDisabled ? Colors.grey[400]! : color,
                width: 2,
              )
            : null,
      ),
    );
  }
}
