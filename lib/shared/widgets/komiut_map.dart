import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';

class KomiutMap extends StatelessWidget {
  final LatLng initialPosition;
  final double zoom;
  final Set<Marker> markers;
  final bool showMock;

  const KomiutMap({
    super.key,
    this.initialPosition = const LatLng(-1.2867, 36.8172),
    this.zoom = 14,
    this.markers = const {},
    this.showMock = true, // Force mock for now until API key is confirmed
  });

  @override
  Widget build(BuildContext context) {
    if (showMock) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          image: const DecorationImage(
            image: AssetImage('assets/images/mock_map.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Optional: Add some subtle overlays to make it look even more "active"
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

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: zoom,
      ),
      markers: markers,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        // Optional: Style the map to match the app theme
      },
    );
  }
}
