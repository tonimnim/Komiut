import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/dashboard_entities.dart';

class RouteInfoCard extends StatelessWidget {
  final Circle circle;
  final CircleRoute route;

  const RouteInfoCard({
    super.key,
    required this.circle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.route,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Route',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                circle.name,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              route.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.success),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    route.startPoint.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Container(
                width: 2,
                height: 20,
                color: AppColors.grey300,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    route.endPoint.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.payments, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 4),
                      Text(
                        'KES ${route.fare.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 4),
                      Text(
                        '~${route.estimatedDurationMins} mins',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
