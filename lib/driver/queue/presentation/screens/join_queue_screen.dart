import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/komiut_map.dart';
import '../widgets/queue_widgets.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';

class JoinQueueScreen extends StatelessWidget {
  final DriverProfile? profile;
  const JoinQueueScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, profile),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const JoinQueueOverlay(),
                        const SizedBox(height: 24),
                        const RouteStatsGrid(),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Vehicles',
                              style: AppTextStyles.heading3.copyWith(fontSize: 20),
                            ),
                            const LiveTrackingBadge(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _VehicleItem(
                          id: 'BUS-4021',
                          eta: 'In 3 min',
                          location: 'Approaching Broadway & 5th St',
                        ),
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, DriverProfile? profile) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Column(
        children: [
          Text(
            'Route 402 - Downtown',
            style: AppTextStyles.heading4.copyWith(fontSize: 16),
          ),
          Text(
            'EXPRESS SERVICE',
            style: AppTextStyles.overline.copyWith(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMapHeader() {
    return Container(
      height: 240, // Slightly shorter as in image
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.grey100,
      ),
      child: Stack(
        children: [
          const KomiutMap(
            initialPosition: LatLng(-1.2867, 36.8172),
            zoom: 14,
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.push(RouteNames.driverQueue),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add_rounded, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Join Queue',
                      style: AppTextStyles.button.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grey100),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleItem extends StatelessWidget {
  final String id;
  final String eta;
  final String location;

  const _VehicleItem({
    required this.id,
    required this.eta,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vehicle #$id',
                      style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      eta,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

