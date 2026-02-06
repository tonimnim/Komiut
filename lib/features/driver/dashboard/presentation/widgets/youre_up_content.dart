/// "You're Up!" content when driver is at front of queue.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../queue/domain/entities/queue_position.dart';
import 'shared_action_buttons.dart';

/// You're Up state - shown when position is 1.
class YoureUpContent extends StatelessWidget {
  const YoureUpContent({super.key, required this.queue});

  final QueuePosition queue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // You're Up banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryGreen, Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "YOU'RE UP!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Start boarding passengers',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Route info
        RouteInfoBar(
          routeName: queue.routeName,
          saccoName: 'Matatu Sacco',
        ),
        const SizedBox(height: 24),

        // Start loading button
        PrimaryActionButton(
          label: 'START LOADING',
          icon: Icons.people_rounded,
          color: AppColors.primaryGreen,
          onTap: () {
            // TODO: Start loading passengers
          },
        ),
      ],
    );
  }
}
