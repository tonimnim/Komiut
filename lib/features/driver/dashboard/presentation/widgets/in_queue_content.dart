/// In queue state content for driver dashboard.
///
/// Shows big queue position hero with visual queue representation.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../queue/domain/entities/queue_position.dart';
import 'shared_action_buttons.dart';
import 'youre_up_content.dart';

/// In queue state - big position number with visual queue.
class InQueueContent extends StatelessWidget {
  const InQueueContent({super.key, required this.queue});

  final QueuePosition queue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final position = queue.position;
    final vehiclesAhead = queue.vehiclesAhead ?? (position > 1 ? position - 1 : 0);

    // Show "You're Up" banner if at front of queue
    if (position == 1) {
      return YoureUpContent(queue: queue);
    }

    return Column(
      children: [
        const SizedBox(height: 20),

        // YOUR POSITION header
        Text(
          'YOUR POSITION',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: isDark ? Colors.grey[500] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Big position number
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Visual queue representation
        VisualQueueIndicator(position: position, totalVisible: 7),
        const SizedBox(height: 20),

        // Info text
        Text(
          '$vehiclesAhead ahead  •  ~${_estimateWait(vehiclesAhead)} min wait',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        // Route info
        RouteInfoBar(
          routeName: queue.routeName,
          saccoName: 'Matatu Sacco', // TODO: Get from provider
        ),
        const SizedBox(height: 24),

        // Leave queue button
        SecondaryActionButton(
          label: 'Leave Queue',
          onTap: () {
            // TODO: Leave queue
          },
        ),
      ],
    );
  }

  int _estimateWait(int vehiclesAhead) {
    return vehiclesAhead * 6;
  }
}

/// Visual queue showing vehicles in line.
class VisualQueueIndicator extends StatelessWidget {
  const VisualQueueIndicator({
    super.key,
    required this.position,
    required this.totalVisible,
  });

  final int position;
  final int totalVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalVisible, (index) {
            final isCurrentVehicle = index == position - 1;
            final isPastVehicle = index < position - 1;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                index % 2 == 0
                    ? Icons.directions_bus_rounded
                    : Icons.airport_shuttle_rounded,
                size: isCurrentVehicle ? 32 : 24,
                color: isCurrentVehicle
                    ? AppColors.primaryBlue
                    : isPastVehicle
                        ? (isDark ? Colors.grey[600] : Colors.grey[400])
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
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
