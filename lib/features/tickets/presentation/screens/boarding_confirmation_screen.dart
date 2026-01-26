/// Boarding confirmation screen.
///
/// Handles the boarding confirmation flow when passenger boards the vehicle.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_providers.dart';
import '../widgets/boarding_success_animation.dart';
import '../widgets/ticket_qr_code.dart';

/// Screen for confirming boarding.
class BoardingConfirmationScreen extends ConsumerStatefulWidget {
  const BoardingConfirmationScreen({
    super.key,
    required this.ticketId,
  });

  /// The ticket ID to confirm boarding for.
  final String ticketId;

  @override
  ConsumerState<BoardingConfirmationScreen> createState() =>
      _BoardingConfirmationScreenState();
}

class _BoardingConfirmationScreenState
    extends ConsumerState<BoardingConfirmationScreen> {
  bool _isConfirming = false;
  bool _isConfirmed = false;
  String? _tripId;

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketByIdProvider(widget.ticketId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _isConfirmed
          ? null
          : AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Confirm Boarding',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: ticketAsync.when(
        loading: () => _buildLoading(context),
        error: (error, _) => _buildError(context, error),
        data: (ticket) {
          if (ticket == null) {
            return _buildNotFound(context);
          }

          // Check if already boarded
          if (_isConfirmed) {
            return _buildSuccessState(ticket);
          }

          // Check ticket validity
          if (ticket.status != TicketStatus.valid) {
            return _buildInvalidTicket(context, ticket, isDark);
          }

          return _buildConfirmationContent(context, ticket, isDark);
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryBlue),
          SizedBox(height: 16),
          Text(
            'Loading ticket...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load ticket',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(ticketByIdProvider(widget.ticketId));
              },
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

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ticket Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This ticket may have been cancelled or doesn\'t exist.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvalidTicket(BuildContext context, Ticket ticket, bool isDark) {
    String message;
    IconData icon;
    Color color;

    switch (ticket.status) {
      case TicketStatus.used:
        message = 'This ticket has already been used for boarding.';
        icon = Icons.check_circle_outline;
        color = AppColors.info;
        break;
      case TicketStatus.expired:
        message = 'This ticket has expired and can no longer be used.';
        icon = Icons.schedule;
        color = AppColors.warning;
        break;
      case TicketStatus.cancelled:
        message = 'This ticket was cancelled.';
        icon = Icons.cancel_outlined;
        color = AppColors.error;
        break;
      default:
        message = 'This ticket cannot be used for boarding.';
        icon = Icons.error_outline;
        color = AppColors.error;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              ticket.status.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationContent(
    BuildContext context,
    Ticket ticket,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Show this QR code to the conductor to board, or tap "Confirm Boarding" when you\'re on the vehicle.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QR Code
              CompactTicketQRCode(
                ticket: ticket,
                size: 180,
              ),

              const SizedBox(height: 16),

              // Ticket number
              Text(
                ticket.ticketNumber,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 24),

              // Trip info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.directions_bus_outlined,
                      label: 'Route',
                      value: ticket.routeInfo.name,
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.my_location,
                      label: 'Pickup',
                      value: ticket.pickupStop,
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Dropoff',
                      value: ticket.dropoffStop,
                    ),
                    if (ticket.seatNumber != null) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.event_seat_outlined,
                        label: 'Seat',
                        value: '${ticket.seatNumber}',
                      ),
                    ],
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.directions_car_outlined,
                      label: 'Vehicle',
                      value: ticket.tripInfo.vehicleRegistration,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isConfirming ? null : () => _confirmBoarding(ticket),
                  icon: _isConfirming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _isConfirming ? 'Confirming...' : 'Confirm Boarding',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.6),
                    disabledForegroundColor: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: _isConfirming ? null : () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(Ticket ticket) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: BoardingSuccessAnimation(
              ticket: ticket,
              autoHide: false,
              onComplete: () => _navigateToActiveTrip(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToActiveTrip,
                icon: const Icon(Icons.navigation),
                label: const Text('Track Your Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBoarding(Ticket ticket) async {
    setState(() => _isConfirming = true);

    HapticFeedback.mediumImpact();

    final notifier = ref.read(boardingNotifierProvider.notifier);
    final result = await notifier.confirmBoarding(ticket.id);

    if (!mounted) return;

    if (result != null && result.success) {
      _tripId = result.tripId ?? ticket.tripInfo.id;
      setState(() {
        _isConfirming = false;
        _isConfirmed = true;
      });

      // Invalidate ticket data to refresh status
      ref.invalidate(ticketByIdProvider(widget.ticketId));
      ref.invalidate(activeTicketsProvider);
      ref.invalidate(allTicketsProvider);
    } else {
      setState(() => _isConfirming = false);

      // Show error
      final boardingState = ref.read(boardingNotifierProvider);
      final errorMessage = boardingState.error?.toString() ?? 'Boarding failed';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _confirmBoarding(ticket),
          ),
        ),
      );
    }
  }

  void _navigateToActiveTrip() {
    if (_tripId != null) {
      context.go(RouteConstants.passengerActiveTripPath(_tripId!));
    } else {
      context.go(RouteConstants.passengerHome);
    }
  }
}

/// Info row for boarding confirmation.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
