/// Queue Screen - Vehicle queue display for passengers.
///
/// Shows all vehicles queued on a specific route with real-time updates,
/// allowing passengers to view availability and select a vehicle for booking.
///
/// Features:
/// - Real-time queue updates via WebSocket
/// - Connection status indicator
/// - Optimistic UI for vehicle selection
/// - Pull-to-refresh support
/// - Auto-refresh on reconnect
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/entities.dart';
import '../providers/realtime_queue_providers.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/queue_empty_state.dart';
import '../widgets/queue_header.dart';
import '../widgets/queue_loading.dart';
import '../widgets/queue_vehicle_card.dart';
import '../widgets/queued_vehicle_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Temporary Model Classes (for mock data in PassengerQueueScreen)
// ─────────────────────────────────────────────────────────────────────────────

/// Temporary route info model for mock data.
class QueueRouteInfo {
  const QueueRouteInfo({
    required this.id,
    required this.name,
    this.origin,
    this.destination,
  });

  final String id;
  final String name;
  final String? origin;
  final String? destination;
}

/// Temporary vehicle model for mock data in PassengerQueueScreen.
class _MockQueuedVehicle {
  const _MockQueuedVehicle({
    required this.id,
    required this.position,
    required this.registrationNumber,
    required this.availableSeats,
    required this.totalSeats,
    required this.status,
    this.eta,
    this.vehicleType,
  });

  final String id;
  final int position;
  final String registrationNumber;
  final int availableSeats;
  final int totalSeats;
  final VehicleQueueStatus status;
  final String? eta;
  final String? vehicleType;
}

// ─────────────────────────────────────────────────────────────────────────────
// PassengerQueueScreen (Legacy Mock Implementation)
// ─────────────────────────────────────────────────────────────────────────────

/// Queue screen widget for passengers.
///
/// Displays a list of vehicles queued on a specific route.
/// Takes a routeId parameter to fetch the relevant queue data.
class PassengerQueueScreen extends ConsumerStatefulWidget {
  /// Creates a PassengerQueueScreen widget.
  const PassengerQueueScreen({
    super.key,
    required this.routeId,
  });

  /// ID of the route to display queue for.
  final String routeId;

  @override
  ConsumerState<PassengerQueueScreen> createState() => _PassengerQueueScreenState();
}

class _PassengerQueueScreenState extends ConsumerState<PassengerQueueScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  QueueRouteInfo? _routeInfo;
  List<_MockQueuedVehicle> _vehicles = [];
  String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    _loadQueueData();
  }

  Future<void> _loadQueueData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call via provider
      // For now, simulate loading with mock data
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data - replace with actual provider data
      _routeInfo = QueueRouteInfo(
        id: widget.routeId,
        name: 'Route ${widget.routeId}',
        origin: 'CBD',
        destination: 'Westlands',
      );

      _vehicles = _getMockVehicles();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refreshQueueData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // TODO: Replace with actual API refresh
      await Future.delayed(const Duration(milliseconds: 600));

      // Refresh mock data
      _vehicles = _getMockVehicles();

      setState(() {
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to refresh queue'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _refreshQueueData,
            ),
          ),
        );
      }
    }
  }

  List<_MockQueuedVehicle> _getMockVehicles() {
    // Mock data for demonstration
    return [
      const _MockQueuedVehicle(
        id: '1',
        position: 1,
        registrationNumber: 'KDA 123A',
        availableSeats: 3,
        totalSeats: 14,
        status: VehicleQueueStatus.boarding,
        eta: 'Departing in 5 min',
        vehicleType: 'Matatu',
      ),
      const _MockQueuedVehicle(
        id: '2',
        position: 2,
        registrationNumber: 'KCB 456B',
        availableSeats: 8,
        totalSeats: 14,
        status: VehicleQueueStatus.waiting,
        eta: 'Est. 15 min',
        vehicleType: 'Matatu',
      ),
      const _MockQueuedVehicle(
        id: '3',
        position: 3,
        registrationNumber: 'KDD 789C',
        availableSeats: 12,
        totalSeats: 14,
        status: VehicleQueueStatus.waiting,
        eta: 'Est. 25 min',
        vehicleType: 'Matatu',
      ),
      const _MockQueuedVehicle(
        id: '4',
        position: 4,
        registrationNumber: 'KBZ 012D',
        availableSeats: 0,
        totalSeats: 14,
        status: VehicleQueueStatus.full,
        vehicleType: 'Matatu',
      ),
      const _MockQueuedVehicle(
        id: '5',
        position: 5,
        registrationNumber: 'KCA 345E',
        availableSeats: 14,
        totalSeats: 14,
        status: VehicleQueueStatus.waiting,
        eta: 'Est. 35 min',
        vehicleType: 'Matatu',
      ),
    ];
  }

  void _onVehicleSelected(_MockQueuedVehicle vehicle) {
    setState(() {
      _selectedVehicleId = vehicle.id;
    });

    // TODO: Navigate to booking or show booking bottom sheet
    _showBookingBottomSheet(vehicle);
  }

  void _showBookingBottomSheet(_MockQueuedVehicle vehicle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Book a Seat',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Vehicle info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.registrationNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${vehicle.availableSeats} seats available',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: vehicle.status.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vehicle.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: vehicle.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Book button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigate to seat selection or payment
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking ${vehicle.registrationNumber}...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue to Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Vehicle Queue'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    // Loading state
    if (_isLoading) {
      return const QueueLoading();
    }

    // Error state
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load queue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQueueData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_vehicles.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 16),
          if (_routeInfo != null)
            QueueHeader(
              routeName: _routeInfo!.name,
              totalVehicles: 0,
              origin: _routeInfo!.origin,
              destination: _routeInfo!.destination,
              onRefresh: _refreshQueueData,
              isRefreshing: _isRefreshing,
            ),
          const Expanded(
            child: QueueEmptyState(),
          ),
        ],
      );
    }

    // Data loaded - show queue
    return RefreshIndicator(
      onRefresh: _refreshQueueData,
      color: AppColors.primaryBlue,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (_routeInfo != null)
                  QueueHeader(
                    routeName: _routeInfo!.name,
                    totalVehicles: _vehicles.length,
                    origin: _routeInfo!.origin,
                    destination: _routeInfo!.destination,
                    onRefresh: _refreshQueueData,
                    isRefreshing: _isRefreshing,
                  ),
                const SizedBox(height: 20),

                // Section title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Vehicles in Queue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap to book',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Vehicle list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final vehicle = _vehicles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QueuedVehicleCard(
                      position: vehicle.position,
                      registrationNumber: vehicle.registrationNumber,
                      availableSeats: vehicle.availableSeats,
                      totalSeats: vehicle.totalSeats,
                      status: vehicle.status,
                      eta: vehicle.eta,
                      vehicleType: vehicle.vehicleType,
                      isSelected: _selectedVehicleId == vehicle.id,
                      onTap: () => _onVehicleSelected(vehicle),
                    ),
                  );
                },
                childCount: _vehicles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Real-time Queue Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Queue screen with real-time updates.
///
/// Uses WebSocket connection for live queue updates including:
/// - Vehicle joining/leaving queue
/// - Position changes
/// - Seat availability updates
/// - Status changes (waiting/boarding/departing)
///
/// Supports optimistic UI for vehicle selection with conflict handling.
class RealtimeQueueScreen extends ConsumerStatefulWidget {
  /// Creates a RealtimeQueueScreen.
  const RealtimeQueueScreen({
    required this.routeId,
    this.routeName,
    this.origin,
    this.destination,
    super.key,
  });

  /// The route ID to display queue for.
  final String routeId;

  /// Optional route name for display.
  final String? routeName;

  /// Origin point of the route.
  final String? origin;

  /// Destination point of the route.
  final String? destination;

  @override
  ConsumerState<RealtimeQueueScreen> createState() => _RealtimeQueueScreenState();
}

class _RealtimeQueueScreenState extends ConsumerState<RealtimeQueueScreen> {
  @override
  void initState() {
    super.initState();
    // Subscribe to queue updates when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscribeToQueueProvider(widget.routeId))();
    });
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(queueStreamProvider(widget.routeId));
    final connectionState =
        ref.watch(queueConnectionStateProvider(widget.routeId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.routeName ?? 'Vehicle Queue',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            ConnectionStatusIndicator(
              connectionState: connectionState,
              compact: true,
            ),
          ],
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(realtimeRefreshQueueProvider(widget.routeId))();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: queueAsync.when(
          loading: () => const QueueLoading(),
          error: (error, stack) => _buildErrorState(context, error),
          data: (queueState) => _buildContent(context, queueState, isDark),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    QueueState queueState,
    bool isDark,
  ) {
    if (queueState.isEmpty && !queueState.isLoading) {
      return Column(
        children: [
          const SizedBox(height: 16),
          QueueHeader(
            routeName: widget.routeName ?? 'Route ${widget.routeId}',
            totalVehicles: 0,
            origin: widget.origin,
            destination: widget.destination,
            onRefresh: () => ref.read(realtimeRefreshQueueProvider(widget.routeId))(),
            isRefreshing: queueState.isSyncing,
          ),
          const Expanded(child: QueueEmptyState()),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(realtimeRefreshQueueProvider(widget.routeId))(),
      color: AppColors.primaryBlue,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Syncing indicator
          if (queueState.isSyncing)
            SliverToBoxAdapter(
              child: _SyncingBanner(isDark: isDark),
            ),

          // Pending selection feedback
          if (queueState.hasPendingUpdate)
            SliverToBoxAdapter(
              child: _PendingSelectionBanner(
                pendingSelection: queueState.pendingSelection!,
                isDark: isDark,
              ),
            ),

          // Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                QueueHeader(
                  routeName: widget.routeName ?? 'Route ${widget.routeId}',
                  totalVehicles: queueState.vehicleCount,
                  origin: widget.origin,
                  destination: widget.destination,
                  onRefresh: () => ref.read(realtimeRefreshQueueProvider(widget.routeId))(),
                  isRefreshing: queueState.isSyncing,
                ),
                const SizedBox(height: 12),

                // Queue summary
                _QueueSummary(
                  vehicleCount: queueState.vehicleCount,
                  totalSeats: queueState.totalAvailableSeats,
                  lastUpdated: queueState.lastUpdated,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Section title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Vehicles in Queue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (queueState.isLive)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Live',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Tap to book',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Vehicle list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final vehicle = queueState.vehicles[index];
                  final isSelected =
                      queueState.selectedVehicleId == vehicle.vehicleId;
                  final isPending = queueState.pendingSelection?.vehicleId ==
                      vehicle.vehicleId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QueueVehicleCard(
                      vehicle: vehicle,
                      isSelected: isSelected,
                      isPending: isPending && queueState.pendingSelection!.isPending,
                      onTap: () => _onVehicleSelected(vehicle),
                    ),
                  );
                },
                childCount: queueState.vehicles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
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
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load queue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We could not load the vehicle queue. Please try again.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(subscribeToQueueProvider(widget.routeId))();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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

  void _onVehicleSelected(QueueVehicle vehicle) async {
    if (!vehicle.canBoard) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vehicle.isFull
                ? 'This vehicle is full'
                : 'Cannot board this vehicle',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show seat selection dialog
    final seats = await _showSeatSelectionDialog(vehicle);
    if (seats == null || seats <= 0) return;

    // Select vehicle with optimistic UI
    final success = await ref.read(
      selectVehicleProvider(widget.routeId),
    )(vehicle.vehicleId, seats);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to select vehicle. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<int?> _showSeatSelectionDialog(QueueVehicle vehicle) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int selectedSeats = 1;

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Select Number of Seats',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Vehicle info
                    Text(
                      '${vehicle.registrationNumber} - ${vehicle.availableSeats} seats available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Seat selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: selectedSeats > 1
                              ? () => setState(() => selectedSeats--)
                              : null,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                            foregroundColor: AppColors.primaryBlue,
                            disabledBackgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '$selectedSeats',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: selectedSeats < vehicle.availableSeats
                              ? () => setState(() => selectedSeats++)
                              : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                            foregroundColor: AppColors.primaryBlue,
                            disabledBackgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(selectedSeats),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Confirm $selectedSeats Seat${selectedSeats > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SyncingBanner extends StatelessWidget {
  const _SyncingBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? Colors.blue[900] : Colors.blue[50],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isDark ? Colors.white : Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Updating...',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.blue[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingSelectionBanner extends StatelessWidget {
  const _PendingSelectionBanner({
    required this.pendingSelection,
    required this.isDark,
  });

  final PendingVehicleSelection pendingSelection;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String message;
    IconData icon;

    if (pendingSelection.hasFailed) {
      backgroundColor = isDark ? Colors.red[900]! : Colors.red[50]!;
      textColor = isDark ? Colors.white : Colors.red[800]!;
      message = pendingSelection.failureReason ?? 'Selection failed';
      icon = Icons.error_outline;
    } else if (pendingSelection.isConfirmed) {
      backgroundColor = isDark ? Colors.green[900]! : Colors.green[50]!;
      textColor = isDark ? Colors.white : Colors.green[800]!;
      message = 'Selection confirmed!';
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = isDark ? Colors.orange[900]! : Colors.orange[50]!;
      textColor = isDark ? Colors.white : Colors.orange[800]!;
      message = 'Confirming your selection...';
      icon = Icons.hourglass_top;
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueSummary extends StatelessWidget {
  const _QueueSummary({
    required this.vehicleCount,
    required this.totalSeats,
    required this.lastUpdated,
    required this.isDark,
  });

  final int vehicleCount;
  final int totalSeats;
  final DateTime? lastUpdated;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: 'Vehicles',
              value: vehicleCount.toString(),
              icon: Icons.directions_bus,
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          Expanded(
            child: _SummaryItem(
              label: 'Seats Available',
              value: totalSeats.toString(),
              icon: Icons.event_seat,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
