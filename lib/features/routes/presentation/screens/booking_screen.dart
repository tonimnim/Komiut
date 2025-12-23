import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../providers/route_providers.dart';
import 'ticket_screen.dart';
import '../services/booking_service.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final bookingState = ref.watch(bookingStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (route == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: Text('Route not found')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Trip',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              route.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: route.isFavorite ? AppColors.error : theme.colorScheme.onSurface,
            ),
            onPressed: () {
              ref.read(toggleFavoriteProvider)(route);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Route info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_bus,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route.routeSummary,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selection instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _SelectionIndicator(
                  label: 'From',
                  stopName: bookingState.fromStopIndex != null
                      ? route.stops[bookingState.fromStopIndex!]
                      : 'Select origin',
                  isSelected: bookingState.fromStopIndex != null,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                ),
                const SizedBox(width: 12),
                _SelectionIndicator(
                  label: 'To',
                  stopName: bookingState.toStopIndex != null
                      ? route.stops[bookingState.toStopIndex!]
                      : 'Select destination',
                  isSelected: bookingState.toStopIndex != null,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stops list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Stops',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stops list
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: route.stops.length,
              itemBuilder: (context, index) {
                final stop = route.stops[index];
                final isFrom = bookingState.fromStopIndex == index;
                final isTo = bookingState.toStopIndex == index;
                final isFirst = index == 0;
                final isLast = index == route.stops.length - 1;

                return _StopSelectionTile(
                  name: stop,
                  index: index,
                  isFirst: isFirst,
                  isLast: isLast,
                  isFromSelected: isFrom,
                  isToSelected: isTo,
                  onFromTap: () {
                    ref.read(bookingStateProvider.notifier).selectFromStop(index);
                  },
                  onToTap: () {
                    ref.read(bookingStateProvider.notifier).selectToStop(index);
                  },
                );
              },
            ),
          ),

          // Bottom bar with fare and book button
          _BookingBottomBar(
            route: route,
            bookingState: bookingState,
            onBook: () => _processBooking(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking(BuildContext context, WidgetRef ref) async {
    final route = ref.read(selectedRouteProvider);
    final bookingState = ref.read(bookingStateProvider);
    final walletAsync = ref.read(walletProvider);

    if (route == null || !bookingState.isValid) return;

    final wallet = walletAsync.valueOrNull;
    if (wallet == null) {
      _showError(context, 'Wallet not available');
      return;
    }

    if (wallet.balance < bookingState.fare) {
      _showError(context, 'Insufficient balance. Please top up your wallet.');
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final ticketData = await bookingService.bookTrip(
        route: route,
        fromStopIndex: bookingState.fromStopIndex!,
        toStopIndex: bookingState.toStopIndex!,
        fare: bookingState.fare,
      );

      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Refresh wallet and trips
      ref.invalidate(walletProvider);
      ref.invalidate(recentTripsProvider);

      // Navigate to ticket screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketScreen(ticketData: ticketData),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context, 'Booking failed. Please try again.');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final String label;
  final String stopName;
  final bool isSelected;
  final Color color;

  const _SelectionIndicator({
    required this.label,
    required this.stopName,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
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
              stopName,
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
      ),
    );
  }
}

class _StopSelectionTile extends StatelessWidget {
  final String name;
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isFromSelected;
  final bool isToSelected;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const _StopSelectionTile({
    required this.name,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.isFromSelected,
    required this.isToSelected,
    required this.onFromTap,
    required this.onToTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 2,
                height: 8,
                color: isFirst
                    ? Colors.transparent
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
              Container(
                width: isFirst || isLast ? 10 : 6,
                height: isFirst || isLast ? 10 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFromSelected
                      ? AppColors.primaryGreen
                      : isToSelected
                          ? AppColors.error
                          : (isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
              Container(
                width: 2,
                height: 32,
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
                fontSize: 14,
                fontWeight: isFromSelected || isToSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isFromSelected || isToSelected
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
              isSelected: isFromSelected,
              color: AppColors.primaryGreen,
              onTap: onFromTap,
            ),
            const SizedBox(width: 8),
            _SelectButton(
              label: 'To',
              isSelected: isToSelected,
              color: AppColors.error,
              onTap: onToTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SelectButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _BookingBottomBar extends StatelessWidget {
  final dynamic route;
  final BookingState bookingState;
  final VoidCallback onBook;

  const _BookingBottomBar({
    required this.route,
    required this.bookingState,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isValid = bookingState.isValid;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Fare display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Fare',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isValid ? route.formatFare(bookingState.fare) : '---',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Book button
            Expanded(
              child: ElevatedButton(
                onPressed: isValid ? onBook : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Book Trip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isValid ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[500]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
