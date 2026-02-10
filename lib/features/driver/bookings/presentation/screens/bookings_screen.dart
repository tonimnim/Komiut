import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking.dart';
import '../../../trips/domain/entities/driver_trip.dart';
import '../../../trips/presentation/providers/trips_providers.dart';
import '../providers/bookings_providers.dart';
import '../widgets/passenger_booking_card.dart';
import '../../../../../shared/widgets/komiut_map.dart';
import '../../../../../core/widgets/error_widget.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;

  static const LatLng _defaultLocation = LatLng(-1.2921, 36.8219);
  static const int _defaultCapacity = 14;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setDefaultLocation();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _currentLocation = _defaultLocation;
        _isLoadingLocation = false;
      });
    }
  }

  void _recenterMap() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(activeTripProvider);
    ref.invalidate(activeTripBookingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeTripAsync = ref.watch(activeTripProvider);
    final bookingsAsync = ref.watch(activeTripBookingsProvider);

    return Stack(
      children: [
        // Map
        KomiutMap(
          // mapController: _mapController, // KomiutMap doesn't expose controller yet but handles it internally or we need to update it
          initialPosition: _currentLocation ?? _defaultLocation,
          zoom: 15.0,
          markers: _currentLocation != null
              ? [
                  Marker(
                    point: _currentLocation!,
                    width: 60,
                    height: 60,
                    child: const _DriverLocationMarker(),
                  ),
                ]
              : [],
        ),

        if (_isLoadingLocation)
          Container(
            color: AppColors.shadow54,
            child: const Center(child: CircularProgressIndicator()),
          ),

        // Recenter
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).size.height * 0.42,
          child: FloatingActionButton(
            onPressed: _recenterMap,
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).primaryColor,
            mini: true,
            child: const Icon(Icons.my_location),
          ),
        ),

        // Sheet
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.15,
          maxChildSize: 0.92,
          snap: true,
          snapSizes: const [0.15, 0.38, 0.65, 0.92],
          builder: (context, scrollController) {
            final theme = Theme.of(context);
            // No isDark check needed

            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: _buildSheetContent(
                scrollController,
                activeTripAsync,
                bookingsAsync,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSheetContent(
    ScrollController scrollController,
    AsyncValue<DriverTrip?> activeTripAsync,
    AsyncValue<List<Booking>> bookingsAsync,
  ) {
    // Error from active trip
    if (activeTripAsync.hasError) {
      return _buildScrollableError(
        scrollController,
        activeTripAsync.error.toString().replaceAll('Exception: ', ''),
      );
    }

    // Loading
    if (activeTripAsync.isLoading) {
      return _buildScrollableLoading(scrollController);
    }

    final trip = activeTripAsync.valueOrNull;

    // No active trip
    if (trip == null) {
      return _buildScrollableNoTrip(scrollController);
    }

    // Has trip - show content
    return _buildTripWithBookings(scrollController, trip, bookingsAsync);
  }

  Widget _buildScrollableError(ScrollController controller, String message) {
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHandleBar(),
            const SizedBox(height: 40),
            CustomErrorWidget(message: message, onRetry: _onRefresh),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableLoading(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          _buildHandleBar(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerList(
              itemCount: 6,
              itemBuilder: (context, index) => const ShimmerListTile(
                hasLeading: true,
                hasSubtitle: true,
                hasTrailing: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScrollableNoTrip(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          _buildHandleBar(),
          const SizedBox(height: 40),
          const EmptyStateWidget(
            icon: Icons.directions_bus_outlined,
            title: 'No active trip',
            message: 'Join a queue to start a trip',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTripWithBookings(
    ScrollController controller,
    DriverTrip trip,
    AsyncValue<List<Booking>> bookingsAsync,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandleBar(),
          _buildTripHeader(trip),
          Divider(
            height: 1,
            color: isDark ? theme.dividerTheme.color : Colors.grey[200],
          ),
          _buildBookingsContent(bookingsAsync),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.dividerTheme.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildTripHeader(DriverTrip trip) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.routeName,
                  style: theme.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pillGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip.statusName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${trip.passengerCount}/${trip.maxCapacity ?? _defaultCapacity} passengers',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(trip.startTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsContent(AsyncValue<List<Booking>> bookingsAsync) {
    final theme = Theme.of(context);

    if (bookingsAsync.hasError) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: CustomErrorWidget(
          message: bookingsAsync.error.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.refresh(activeTripBookingsProvider),
        ),
      );
    }

    if (bookingsAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final bookings = bookingsAsync.valueOrNull ?? [];

    if (bookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: EmptyStateWidget(
          icon: Icons.people_outline,
          title: 'Waiting for passengers',
          message: 'Bookings will appear here',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passengers',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${bookings.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...bookings.map(
          (booking) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PassengerBookingCard(booking: booking),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

class _DriverLocationMarker extends StatelessWidget {
  const _DriverLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white, // Always white as requested
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
