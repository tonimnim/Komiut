/// Queue widgets for visual queue representation.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Visual queue showing vehicles in line.
class VisualQueueIndicator extends StatelessWidget {
  const VisualQueueIndicator({
    super.key,
    required this.position,
    required this.totalVisible,
    required this.isDark,
  });

  final int position;
  final int totalVisible;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Calculate which vehicles to show
    // Center the current vehicle in the visible range
    final halfVisible = totalVisible ~/ 2;
    final startPos = (position - halfVisible).clamp(1, position);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalVisible, (index) {
            final vehiclePos = startPos + index;
            final isCurrentVehicle = vehiclePos == position;
            final isPastVehicle = vehiclePos < position;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _VehicleIcon(
                isCurrentVehicle: isCurrentVehicle,
                isPastVehicle: isPastVehicle,
                isDark: isDark,
                index: index,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // YOU indicator
        const Text(
          '▲',
          style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
        ),
        const Text(
          'YOU',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}

class _VehicleIcon extends StatelessWidget {
  const _VehicleIcon({
    required this.isCurrentVehicle,
    required this.isPastVehicle,
    required this.isDark,
    required this.index,
  });

  final bool isCurrentVehicle;
  final bool isPastVehicle;
  final bool isDark;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = isCurrentVehicle
        ? AppColors.primaryBlue
        : isPastVehicle
            ? (isDark ? Colors.grey[600] : Colors.grey[400])
            : (isDark ? Colors.grey[700] : Colors.grey[300]);

    return Icon(
      index % 2 == 0
          ? Icons.directions_bus_rounded
          : Icons.airport_shuttle_rounded,
      size: isCurrentVehicle ? 32 : 24,
      color: color,
    );
  }
}

/// Position badge with gradient.
class PositionBadge extends StatelessWidget {
  const PositionBadge({
    super.key,
    required this.position,
    this.size = 64,
  });

  final int position;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '#$position',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
