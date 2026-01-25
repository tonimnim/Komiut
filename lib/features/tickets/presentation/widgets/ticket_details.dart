/// Ticket details widget.
///
/// Displays full ticket information including route, trip, and fare details.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';
import 'ticket_status_badge.dart';

/// Full ticket details display.
class TicketDetails extends StatelessWidget {
  const TicketDetails({
    super.key,
    required this.ticket,
    this.showStatus = true,
  });

  /// The ticket to display.
  final Ticket ticket;

  /// Whether to show the status badge.
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEE, MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with route info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket.routeInfo.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (showStatus)
                      TicketStatusBadge(
                        status: ticket.status,
                        size: TicketStatusBadgeSize.small,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _RouteStopsDisplay(
                  pickup: ticket.pickupStop,
                  dropoff: ticket.dropoffStop,
                ),
              ],
            ),
          ),

          // Details sections
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Trip info
                _DetailSection(
                  title: 'Trip Details',
                  children: [
                    _DetailRow(
                      icon: Icons.directions_bus_outlined,
                      label: 'Vehicle',
                      value: ticket.tripInfo.vehicleRegistration,
                    ),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: dateFormat.format(ticket.tripInfo.departureTime),
                    ),
                    _DetailRow(
                      icon: Icons.schedule_outlined,
                      label: 'Departure',
                      value: timeFormat.format(ticket.tripInfo.departureTime),
                    ),
                    if (ticket.tripInfo.estimatedArrival != null)
                      _DetailRow(
                        icon: Icons.flag_outlined,
                        label: 'Est. Arrival',
                        value: timeFormat.format(ticket.tripInfo.estimatedArrival!),
                      ),
                    if (ticket.tripInfo.driverName != null)
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Driver',
                        value: ticket.tripInfo.driverName!,
                      ),
                  ],
                ),

                const Divider(height: 32),

                // Ticket info
                _DetailSection(
                  title: 'Ticket Information',
                  children: [
                    _DetailRow(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Ticket #',
                      value: ticket.ticketNumber,
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    _DetailRow(
                      icon: Icons.event_seat_outlined,
                      label: 'Seat',
                      value: ticket.formattedSeat,
                    ),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      label: 'Fare',
                      value: ticket.formattedFare,
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Validity info
                _DetailSection(
                  title: 'Validity',
                  children: [
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Valid From',
                      value: '${dateFormat.format(ticket.validFrom)} ${timeFormat.format(ticket.validFrom)}',
                    ),
                    _DetailRow(
                      icon: Icons.timer_off_outlined,
                      label: 'Valid Until',
                      value: '${dateFormat.format(ticket.validUntil)} ${timeFormat.format(ticket.validUntil)}',
                    ),
                    if (ticket.usedAt != null)
                      _DetailRow(
                        icon: Icons.check_circle_outline,
                        label: 'Boarded At',
                        value: '${dateFormat.format(ticket.usedAt!)} ${timeFormat.format(ticket.usedAt!)}',
                        valueStyle: const TextStyle(
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Route stops display with arrow.
class _RouteStopsDisplay extends StatelessWidget {
  const _RouteStopsDisplay({
    required this.pickup,
    required this.dropoff,
  });

  final String pickup;
  final String dropoff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Pickup
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PICKUP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickup,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Arrow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.arrow_forward,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: 20,
          ),
        ),

        // Dropoff
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DROPOFF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      dropoff,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Section header for details.
class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

/// Row for displaying a detail item.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

/// Compact ticket details for summary display.
class CompactTicketDetails extends StatelessWidget {
  const CompactTicketDetails({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeFormat = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route
        Text(
          ticket.routeInfo.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),

        // Stops
        Text(
          '${ticket.pickupStop} → ${ticket.dropoffStop}',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Time and fare
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              timeFormat.format(ticket.tripInfo.departureTime),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              ticket.formattedFare,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
