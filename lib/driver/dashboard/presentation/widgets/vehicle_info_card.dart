import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/dashboard_entities.dart';

class VehicleInfoCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleInfoCard({
    super.key,
    required this.vehicle,
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
                  Icons.directions_bus,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vehicle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: 'Plate Number',
              value: vehicle.plateNumber,
              isHighlighted: true,
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    label: 'Model',
                    value: vehicle.model,
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    label: 'Capacity',
                    value: '${vehicle.capacity} seats',
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: isHighlighted
              ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
