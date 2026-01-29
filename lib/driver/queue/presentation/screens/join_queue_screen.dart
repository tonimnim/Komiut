import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:komiut/core/routes/route_names.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/shared/widgets/komiut_map.dart';
import 'package:komiut/driver/queue/presentation/widgets/queue_widgets.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/di/injection_container.dart';
import 'package:komiut/driver/queue/domain/repositories/queue_repository.dart';
import '../../../../core/widgets/buttons/app_button.dart';

class JoinQueueScreen extends StatefulWidget {
  final DriverProfile? profile;
  final VoidCallback? onQueueJoined;
  const JoinQueueScreen({super.key, this.profile, this.onQueueJoined});

  @override
  State<JoinQueueScreen> createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends State<JoinQueueScreen> {
  bool _isLoading = false;

  Future<void> _joinQueue() async {
    setState(() => _isLoading = true);
    
    try {
      final repository = getIt<QueueRepository>();
      // Using dummy routeId and coords as they are hardcoded in the UI layout
      final result = await repository.joinQueue("402", -1.2867, 36.8172);
      
      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
            );
            setState(() => _isLoading = false);
          },
          (position) {
            // Success - Notify parent to refresh state
            if (widget.onQueueJoined != null) {
              widget.onQueueJoined!();
            } else {
              // Fallback if no callback provided
              context.go(RouteNames.driverDashboard);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: !context.canPop() ? _buildAppBar(context, widget.profile, theme) : null,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapHeader(theme),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const JoinQueueOverlay(
                          isJoined: false,
                          totalVehicles: 15,
                          estimatedWaitMins: 45,
                        ),
                        const SizedBox(height: 24),
                        const RouteStatsGrid(),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Vehicles',
                              style: AppTextStyles.heading3.copyWith(fontSize: 20, color: theme.colorScheme.onSurface),
                            ),
                            const LiveTrackingBadge(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _VehicleItem(
                          id: 'BUS-4021',
                          eta: 'In 3 min',
                          location: 'Approaching Broadway & 5th St',
                          theme: theme,
                        ),
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, DriverProfile? profile, ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Column(
        children: [
          Text(
            'Route 402 - Downtown',
            style: AppTextStyles.heading4.copyWith(fontSize: 16, color: theme.colorScheme.onSurface),
          ),
          Text(
            'EXPRESS SERVICE',
            style: AppTextStyles.overline.copyWith(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMapHeader(ThemeData theme) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Stack(
        children: [
          KomiutMap(
            initialPosition: const LatLng(-1.2867, 36.8172),
            zoom: 14,
            markers: [
              fm.Marker(
                point: const LatLng(-1.2867, 36.8172),
                width: 40,
                height: 40,
                child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 32),
              ),
              fm.Marker(
                point: const LatLng(-1.2880, 36.8190),
                width: 40,
                height: 40,
                child: const Icon(Icons.directions_bus_rounded, color: AppColors.success, size: 28),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: theme.shadowColor.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.my_location_rounded, color: theme.colorScheme.primary, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton.primary(
              label: 'Join Queue',
              icon: Icons.person_add_rounded,
              onPressed: _joinQueue,
              isLoading: _isLoading,
              size: ButtonSize.large,
              // isFullWidth is not needed if wrapped in Expanded, but let's keep it safe or rely on Expanded
              isFullWidth: true,
              gradient: AppColors.primaryGradient,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: IconButton(
              icon: Icon(Icons.share_outlined, color: theme.colorScheme.onSurface, size: 24),
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
  final ThemeData theme;

  const _VehicleItem({
    required this.id,
    required this.eta,
    required this.location,
    required this.theme,
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
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_bus_rounded, color: theme.colorScheme.primary),
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
                      style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    Text(
                      eta,
                      style: AppTextStyles.body1.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

