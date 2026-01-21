import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_names.dart';
import '../../data/datasources/trip_mock_data.dart';

class TripInProgressScreen extends StatelessWidget {
  const TripInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Full Screen Map
          const Positioned.fill(
            child: _PlaceholderMap(),
          ),

          // 2. Top Status Card
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildTopStatusCard(),
          ),

          // 3. SOS Button
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.sos, color: Colors.white, size: 20),
                onPressed: () {}, // SOS Logic
              ),
            ),
          ),

          // 4. Bottom Trip Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomTripSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusCard() {
    return Container(
      margin: const EdgeInsets.only(right: 60), // Space for SOS
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Colors.green, size: 12),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TRIP IN PROGRESS',
                style: TextStyle(
                  color: Color(0xFF166534), // Green 800
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                TripMockData.destination,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTripSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTripStat('Time', '${TripMockData.estimatedDurationMins} min', Icons.access_time),
              _buildTripStat('Distance', '${TripMockData.totalDistanceKm} km', Icons.map),
              _buildTripStat('Passengers', '${TripMockData.maxCapacity}', Icons.people),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),
          
          // Next Stop
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Next Stop',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  Text(
                    'Uhuru Park',
                    style: TextStyle(
                      color: Color(0xFF1E293B), 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // End Trip Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.endTrip),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), 
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'END TRIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _PlaceholderMap extends StatelessWidget {
  const _PlaceholderMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.blueGrey[300]),
            const SizedBox(height: 16),
            Text(
              'Live Map Placeholder',
              style: TextStyle(color: Colors.blueGrey[400], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
