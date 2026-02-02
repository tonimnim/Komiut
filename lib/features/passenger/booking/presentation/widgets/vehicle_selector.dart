/// Vehicle selector widget for choosing from queue vehicles.
///
/// Displays available vehicles with seat availability, ETA,
/// and position in queue. Highlights recommended vehicle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../shared/queue/domain/entities/queue_vehicle.dart';
import '../../../../shared/queue/presentation/providers/queue_providers.dart';
import '../providers/booking_flow_provider.dart';

/// Widget for selecting a vehicle from the queue.
class VehicleSelector extends ConsumerWidget {
  /// Creates a VehicleSelector.
  const VehicleSelector({
    super.key,
    required this.routeId,
    this.onVehicleSelected,
    this.showHeader = true,
  });

  /// ID of the route to show queue for.
  final String routeId;

  /// Callback when a vehicle is selected.
  final void Function(QueueVehicle vehicle)? onVehicleSelected;

  /// Whether to show the header section.
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueForRouteProvider(routeId));
    final bookingState = ref.watch(bookingFlowProvider);
    final selectedVehicle = bookingState.selectedVehicle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          _VehicleSelectorHeader(
            selectedVehicle: selectedVehicle,
            passengerCount: bookingState.passengerCount,
          ),
          const SizedBox(height: 16),
        ],

        // Vehicles list
        Expanded(
          child: queueAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => _ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(queueForRouteProvider(routeId)),
            ),
            data: (queue) {
              if (queue.isEmpty) {
                return const _EmptyQueueState();
              }

              // Convert QueuedVehicle to QueueVehicle for compatibility
              final vehicles = queue.vehicles
                  .map((v) => v.toQueueVehicle(routeId: routeId))
                  .where((v) => v.hasSeats)
                  .toList();

              if (vehicles.isEmpty) {
                return const _NoAvailableSeatsState();
              }

              return _VehiclesList(
                vehicles: vehicles,
                selectedVehicleId: selectedVehicle?.id,
                passengerCount: bookingState.passengerCount,
                onVehicleSelected: (vehicle) {
                  ref.read(bookingFlowProvider.notifier).selectVehicle(vehicle);
                  onVehicleSelected?.call(vehicle);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Header showing selection summary.
class _VehicleSelectorHeader extends StatelessWidget {
  const _VehicleSelectorHeader({
    this.selectedVehicle,
    required this.passengerCount,
  });

  final QueueVehicle? selectedVehicle;
  final int passengerCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_bus,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedVehicle != null
                      ? 'Selected: ${selectedVehicle!.registrationNumber}'
                      : 'Select a vehicle',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedVehicle != null
                      ? '${selectedVehicle!.availableSeats} seats available'
                      : 'Choose from available vehicles',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (selectedVehicle != null)
            Icon(
              Icons.check_circle,
              color: AppColors.primaryGreen,
              size: 24,
            ),
        ],
      ),
    );
  }
}

/// List of available vehicles.
class _VehiclesList extends StatelessWidget {
  const _VehiclesList({
    required this.vehicles,
    this.selectedVehicleId,
    required this.passengerCount,
    required this.onVehicleSelected,
  });

  final List<QueueVehicle> vehicles;
  final String? selectedVehicleId;
  final int passengerCount;
  final void Function(QueueVehicle vehicle) onVehicleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sort vehicles by position
    final sortedVehicles = List<QueueVehicle>.from(vehicles)
      ..sort((a, b) => a.position.compareTo(b.position));

    // Find recommended vehicle (first with enough seats)
    final recommendedVehicle = sortedVehicles.firstWhere(
      (v) => v.availableSeats >= passengerCount,
      orElse: () => sortedVehicles.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Vehicles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: sortedVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = sortedVehicles[index];
              final isSelected = vehicle.id == selectedVehicleId;
              final isRecommended = vehicle.id == recommendedVehicle.id;
              final hasEnoughSeats = vehicle.availableSeats >= passengerCount;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VehicleCard(
                  vehicle: vehicle,
                  isSelected: isSelected,
                  isRecommended: isRecommended,
                  isDisabled: !hasEnoughSeats,
                  onTap:
                      hasEnoughSeats ? () => onVehicleSelected(vehicle) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Card displaying vehicle information.
class VehicleCard extends StatelessWidget {
  /// Creates a VehicleCard.
  const VehicleCard({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.isRecommended = false,
    this.isDisabled = false,
    this.onTap,
    this.showDetails = true,
  });

  /// The vehicle to display.
  final QueueVehicle vehicle;

  /// Whether this vehicle is selected.
  final bool isSelected;

  /// Whether this is the recommended vehicle.
  final bool isRecommended;

  /// Whether the card is disabled.
  final bool isDisabled;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Whether to show detailed information.
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color borderColor;
    if (isSelected) {
      borderColor = AppColors.primaryBlue;
    } else if (isRecommended) {
      borderColor = AppColors.primaryGreen;
    } else {
      borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDisabled
              ? (isDark ? Colors.grey[900] : Colors.grey[100])
              : (isSelected
                  ? AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1)
                  : theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Position badge
                _PositionBadge(
                  position: vehicle.position,
                  isBoarding: vehicle.status == QueueVehicleStatus.boarding,
                ),
                const SizedBox(width: 12),

                // Vehicle info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            vehicle.registrationNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDisabled
                                  ? (isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400])
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            _RecommendedBadge(),
                          ],
                        ],
                      ),
                      if (vehicle.make != null && vehicle.model != null)
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey[500]
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryBlue,
                    size: 24,
                  )
                else if (!isDisabled)
                  Icon(
                    Icons.radio_button_unchecked,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                    size: 24,
                  ),
              ],
            ),

            if (showDetails) ...[
              const SizedBox(height: 12),
              // Details row
              Row(
                children: [
                  // Seats
                  _DetailChip(
                    icon: Icons.event_seat,
                    label: vehicle.seatDisplay,
                    color: vehicle.hasSeats
                        ? AppColors.primaryGreen
                        : AppColors.error,
                    isDisabled: isDisabled,
                  ),
                  const SizedBox(width: 12),

                  // Status
                  _DetailChip(
                    icon: _getStatusIcon(vehicle.status),
                    label: vehicle.status.label,
                    color: _getStatusColor(vehicle.status),
                    isDisabled: isDisabled,
                  ),

                  // ETA
                  if (vehicle.formattedDepartureTime != null) ...[
                    const SizedBox(width: 12),
                    _DetailChip(
                      icon: Icons.schedule,
                      label: vehicle.formattedDepartureTime!,
                      color: AppColors.info,
                      isDisabled: isDisabled,
                    ),
                  ],
                ],
              ),

              // Driver info
              if (vehicle.driverName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color:
                          isDark ? Colors.grey[500] : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Driver: ${vehicle.driverName}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.grey[500] : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Disabled message
            if (isDisabled) ...[
              const SizedBox(height: 8),
              Text(
                'Not enough seats available',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(QueueVehicleStatus status) {
    switch (status) {
      case QueueVehicleStatus.waiting:
        return Icons.hourglass_empty;
      case QueueVehicleStatus.boarding:
        return Icons.login;
      case QueueVehicleStatus.departing:
        return Icons.directions_bus;
      case QueueVehicleStatus.departed:
        return Icons.check;
    }
  }

  Color _getStatusColor(QueueVehicleStatus status) {
    switch (status) {
      case QueueVehicleStatus.waiting:
        return AppColors.warning;
      case QueueVehicleStatus.boarding:
        return AppColors.primaryGreen;
      case QueueVehicleStatus.departing:
        return AppColors.info;
      case QueueVehicleStatus.departed:
        return AppColors.textSecondary;
    }
  }
}

/// Badge showing queue position.
class _PositionBadge extends StatelessWidget {
  const _PositionBadge({
    required this.position,
    this.isBoarding = false,
  });

  final int position;
  final bool isBoarding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isBoarding ? AppColors.primaryGreen : AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: isBoarding
            ? const Icon(
                Icons.login,
                color: Colors.white,
                size: 20,
              )
            : Text(
                '#$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

/// Recommended badge.
class _RecommendedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Recommended',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

/// Detail chip for showing vehicle info.
class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
    this.isDisabled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled ? Colors.grey : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: effectiveColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty queue state widget.
class _EmptyQueueState extends StatelessWidget {
  const _EmptyQueueState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicles in queue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// No available seats state widget.
class _NoAvailableSeatsState extends StatelessWidget {
  const _NoAvailableSeatsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_seat,
            size: 64,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            'All vehicles are full',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait for the next available vehicle',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load vehicles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
