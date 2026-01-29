import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/komiut_map.dart';
import 'package:komiut/di/injection_container.dart';
import 'package:komiut/driver/trip/domain/repositories/trip_repository.dart';

import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../core/widgets/buttons/app_button.dart';

class TripInProgressScreen extends StatefulWidget {
  final int? passengerCount;
  final DriverProfile? profile;
  const TripInProgressScreen({super.key, this.passengerCount, this.profile});

  @override
  State<TripInProgressScreen> createState() => _TripInProgressScreenState();
}

class _TripInProgressScreenState extends State<TripInProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildMapHeader(),
          _buildAppBar(context),
          _buildStatsSheet(context),
        ],
      ),
    );
  }

  Widget _buildMapHeader() {
    final theme = Theme.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      child: KomiutMap(
        initialPosition: const LatLng(-1.2867, 36.8172),
        zoom: 15,
        polylines: [
          fm.Polyline(
            points: const [
              LatLng(-1.2867, 36.8172),
              LatLng(-1.2875, 36.8185),
              LatLng(-1.2885, 36.8200),
              LatLng(-1.2900, 36.8210),
            ],
            color: theme.colorScheme.primary,
            strokeWidth: 4,
          ),
        ],
        markers: [
          fm.Marker(
            point: const LatLng(-1.2875, 36.8185),
            width: 40,
            height: 40,
            child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.shadowColor.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                   Container(
                     width: 8,
                     height: 8,
                     decoration: const BoxDecoration(
                       color: AppColors.success, 
                       shape: BoxShape.circle,
                       boxShadow: [BoxShadow(color: AppColors.success, blurRadius: 4)],
                     ),
                   ),
                   const SizedBox(width: 8),
                   Text(
                     'TRIP IN PROGRESS',
                     style: AppTextStyles.overline.copyWith(
                       fontWeight: FontWeight.w900, 
                       color: theme.colorScheme.onSurface,
                       letterSpacing: 0.5,
                     ),
                   ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: widget.profile?.imageUrl != null ? NetworkImage(widget.profile!.imageUrl!) : null,
                    child: widget.profile?.imageUrl == null ? Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.error.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.sos_rounded, color: Colors.white, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSheet(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatTile('12:34', 'Duration', Icons.access_time_filled_rounded, theme),
                _buildStatTile('3.5km', 'Distance', Icons.straighten_rounded, theme),
                _buildStatTile('${widget.passengerCount ?? 14}', 'Passengers', Icons.people_alt_rounded, theme),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Stop: Uhuru Park',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '2.1km away • Est. 5 mins',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.onSurfaceVariant, size: 16),
              ],
            ),
            const SizedBox(height: 32),
            AppButton.primary(
              label: 'END TRIP',
              onPressed: () async {
                final pax = widget.passengerCount ?? 14;
                final fare = pax * 100.0;
                
                try {
                  await getIt<TripRepository>().endTrip(
                    'mock-trip-123', 
                    finalPassengers: pax, 
                    finalEarnings: fare
                  );
                } catch (e) {
                   // Error handling suppressed
                }

                if (context.mounted) {
                  context.push(RouteNames.endTrip, extra: {
                    'duration': '32 min',
                    'distance': '8.5 km',
                    'passengers': pax,
                    'fare': fare,
                  });
                }
              },
              size: ButtonSize.large,
              isFullWidth: true,
              gradient: AppColors.primaryGradient,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String value, String label, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(fontSize: 20, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
