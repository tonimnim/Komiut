/// Idle state content for driver dashboard.
///
/// Shows "Ready to start?" prompt with GO ONLINE / JOIN QUEUE button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import 'shared_action_buttons.dart';

/// Idle state - "Ready to start?" with CTA button.
class IdleStateContent extends ConsumerWidget {
  const IdleStateContent({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big bus icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_bus_outlined,
                size: 48,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Ready to start?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              isOnline
                  ? 'Join a queue to begin your day'
                  : 'Go online and join a queue to begin',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // CTA Button
            if (!isOnline)
              PrimaryActionButton(
                label: 'GO ONLINE',
                icon: Icons.power_settings_new_rounded,
                onTap: () {
                  // TODO: Toggle online status
                },
              )
            else
              PrimaryActionButton(
                label: 'JOIN QUEUE',
                icon: Icons.add_rounded,
                onTap: () {
                  // TODO: Navigate to queue tab
                },
              ),
          ],
        ),
      ),
    );
  }
}
