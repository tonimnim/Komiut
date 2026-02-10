/// Real-time map widget for active driver trips.
///
/// Displays the driver's current GPS location, route path,
/// and stop markers using FlutterMap with OpenStreetMap tiles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/driver_trip.dart';

/// Map widget showing driver's live position and trip route.
class DriverTripMap extends ConsumerStatefulWidget {
  const DriverTripMap({
    super.key,
    required this.trip,
    this.height = 250,
    this.showControls = true,
  });

  /// The active trip to display.
  final DriverTrip trip;

  /// Height of the map container.
  final double height;

  /// Whether to show zoom controls.
  final bool showControls;

  @override
  ConsumerState<DriverTripMap> createState() => _DriverTripMapState();
}

class _DriverTripMapState extends ConsumerState<DriverTripMap> {
  final MapController _mapController = MapController();

  // Default to Nairobi CBD
  static const _defaultPosition = LatLng(-1.2921, 36.8219);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get current driver position (mock for now, will use GPS later)
    final driverPosition = _getDriverPosition();

    // Build route stops
    final stops = _buildStops();

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: driverPosition,
              initialZoom: 14,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              // Map tiles
              TileLayer(
                // DEBUG: Force standard OSM tiles
                tileProvider: NetworkTileProvider(),
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.komiut_app',
              ),

              // Route polyline
              if (stops.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: stops,
                      color: AppColors.primaryBlue,
                      strokeWidth: 4,
                    ),
                  ],
                ),

              // Stop markers
              MarkerLayer(
                markers: [
                  // Driver position marker
                  Marker(
                    point: driverPosition,
                    width: 40,
                    height: 40,
                    child: _DriverMarker(),
                  ),

                  // Start marker
                  if (stops.isNotEmpty)
                    Marker(
                      point: stops.first,
                      width: 30,
                      height: 30,
                      child: const _StopMarker(
                        label: 'A',
                        color: AppColors.primaryGreen,
                      ),
                    ),

                  // End marker
                  if (stops.length > 1)
                    Marker(
                      point: stops.last,
                      width: 30,
                      height: 30,
                      child:
                          const _StopMarker(label: 'B', color: AppColors.error),
                    ),
                ],
              ),
            ],
          ),

          // Map controls overlay
          if (widget.showControls)
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _MapControlButton(
                    icon: Icons.my_location,
                    onTap: () => _centerOnDriver(driverPosition),
                  ),
                  const SizedBox(height: 8),
                  _MapControlButton(icon: Icons.add, onTap: () => _zoomIn()),
                  const SizedBox(height: 8),
                  _MapControlButton(
                    icon: Icons.remove,
                    onTap: () => _zoomOut(),
                  ),
                ],
              ),
            ),

          // Trip info overlay
          Positioned(
            left: 12,
            top: 12,
            child: _TripInfoChip(trip: widget.trip),
          ),
        ],
      ),
    );
  }

  LatLng _getDriverPosition() {
    // TODO: Replace with actual GPS from provider
    // For now, use a position along the route
    return _defaultPosition;
  }

  List<LatLng> _buildStops() {
    // TODO: Get actual route coordinates from trip data
    // Mock route for demo
    return const [
      LatLng(-1.2921, 36.8219), // CBD
      LatLng(-1.2673, 36.8114), // Westlands
    ];
  }

  void _centerOnDriver(LatLng position) {
    _mapController.move(position, _mapController.camera.zoom);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18) {
      _mapController.move(_mapController.camera.center, currentZoom + 1);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 10) {
      _mapController.move(_mapController.camera.center, currentZoom - 1);
    }
  }
}

/// Driver location marker with pulsing effect.
class _DriverMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.navigation, color: Colors.white, size: 20),
    );
  }
}

/// Stop marker (A, B, etc).
class _StopMarker extends StatelessWidget {
  const _StopMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Map control button.
class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Trip info chip overlay.
class _TripInfoChip extends StatelessWidget {
  const _TripInfoChip({required this.trip});

  final DriverTrip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '${trip.passengerCount} passengers',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
