import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:komiut/core/theme/app_colors.dart';

class KomiutMap extends StatelessWidget {
  final LatLng initialPosition;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final List<CircleMarker> circles;
  final bool showMock;

  const KomiutMap({
    super.key,
    this.initialPosition = const LatLng(-1.2867, 36.8172),
    this.zoom = 14,
    this.markers = const [],
    this.polylines = const [],
    this.circles = const [],
    this.showMock = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showMock) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          image: DecorationImage(
            image: AssetImage('assets/images/mock_map.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.05)),
            const Center(
              child: Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryBlue,
                size: 32,
              ),
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialPosition,
        initialZoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.komiut.driver',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        if (circles.isNotEmpty) CircleLayer(circles: circles),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );
  }
}
