import 'package:flutter/material.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/dashboard_entities.dart';

class DriverStatusCard extends StatelessWidget {
  final DriverProfile profile;
  final Function(String) onStatusToggle;

  const DriverStatusCard({
    super.key,
    required this.profile,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: profile.profileImage != null
                  ? NetworkImage(profile.profileImage!)
                  : null,
              child: profile.profileImage == null
                  ? const Icon(Icons.person, size: 32, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.rating.toStringAsFixed(1)} • ${profile.totalTrips} trips',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Switch(
                  value: profile.isOnline || profile.isOnTrip,
                  activeColor: AppColors.statusOnline,
                  onChanged: profile.isOnTrip
                      ? null
                      : (value) {
                          onStatusToggle(
                            value ? AppConstants.statusOnline : AppConstants.statusOffline,
                          );
                        },
                ),
                Text(
                  profile.isOnTrip
                      ? 'ON TRIP'
                      : profile.isOnline
                          ? 'ONLINE'
                          : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: profile.isOnTrip
                        ? AppColors.statusOnTrip
                        : profile.isOnline
                            ? AppColors.statusOnline
                            : AppColors.dutyOffline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
