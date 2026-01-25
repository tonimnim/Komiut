import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:komiut_app/core/theme/app_colors.dart';
import 'package:komiut_app/core/theme/app_text_styles.dart';
import 'package:komiut_app/shared/widgets/komiut_map.dart';

class TripHistoryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripHistoryDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: const KomiutMap(
                initialPosition: LatLng(-1.2867, 36.8172),
                zoom: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip['date'] ?? 'January 15, 2024',
                    style: AppTextStyles.heading4.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard([
                    _buildDetailRow('Start', trip['startTime'] ?? '10:00 AM'),
                    _buildDetailRow('End', trip['endTime'] ?? '10:32 AM'),
                    _buildDetailRow('Duration', trip['duration'] ?? '32 minutes'),
                    _buildDetailRow('Distance', trip['distance'] ?? '8.5 km'),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoCard([
                    _buildDetailRow('Route', trip['route'] ?? 'Route 23'),
                    _buildDetailRow('From', trip['from'] ?? 'CBD Stage'),
                    _buildDetailRow('To', trip['to'] ?? 'Westlands'),
                    _buildDetailRow('Passengers', trip['passengers']?.toString() ?? '14'),
                  ]),
                  const SizedBox(height: 24),
                  _buildEarningsCard(trip),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: isRed ? Colors.redAccent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(Map<String, dynamic> trip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Gross Fare', 'KES ${trip['amount'] ?? "1,400"}'),
          _buildDetailRow('Platform Fee', '- KES 140', isRed: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Earnings', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
              Text(
                'KES ${trip['amount'] ?? "1,260"}',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
