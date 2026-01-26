/// Connection status indicator widget.
///
/// Displays the current real-time connection status for queue updates.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/queue_state.dart';

/// Displays the connection status for real-time queue updates.
///
/// Shows an icon and label indicating whether the queue is receiving
/// live updates, is reconnecting, or has a connection error.
class ConnectionStatusIndicator extends StatelessWidget {
  /// Creates a ConnectionStatusIndicator.
  const ConnectionStatusIndicator({
    required this.connectionState,
    this.compact = false,
    super.key,
  });

  /// Current connection state.
  final QueueConnectionState connectionState;

  /// Whether to show compact version (just icon and short label).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final config = _getConfig(isDark);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.isAnimated)
            _AnimatedIndicator(color: config.color)
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.color,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            config.shortLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.isAnimated)
            _AnimatedIndicator(color: config.color)
          else
            Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 6),
          Text(
            connectionState.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _IndicatorConfig _getConfig(bool isDark) {
    switch (connectionState) {
      case QueueConnectionState.connected:
        return _IndicatorConfig(
          icon: Icons.wifi,
          color: AppColors.success,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          shortLabel: 'Live',
          isAnimated: true,
        );

      case QueueConnectionState.connecting:
        return _IndicatorConfig(
          icon: Icons.sync,
          color: AppColors.info,
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          shortLabel: 'Connecting',
          isAnimated: true,
        );

      case QueueConnectionState.reconnecting:
        return _IndicatorConfig(
          icon: Icons.sync,
          color: AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          shortLabel: 'Reconnecting',
          isAnimated: true,
        );

      case QueueConnectionState.disconnected:
        return _IndicatorConfig(
          icon: Icons.wifi_off,
          color: isDark ? Colors.grey[400]! : AppColors.textSecondary,
          backgroundColor: (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          shortLabel: 'Offline',
          isAnimated: false,
        );

      case QueueConnectionState.error:
        return _IndicatorConfig(
          icon: Icons.error_outline,
          color: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          shortLabel: 'Error',
          isAnimated: false,
        );
    }
  }
}

/// Configuration for the indicator appearance.
class _IndicatorConfig {
  const _IndicatorConfig({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.shortLabel,
    required this.isAnimated,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String shortLabel;
  final bool isAnimated;
}

/// Animated pulsing indicator for live/connecting states.
class _AnimatedIndicator extends StatefulWidget {
  const _AnimatedIndicator({required this.color});

  final Color color;

  @override
  State<_AnimatedIndicator> createState() => _AnimatedIndicatorState();
}

class _AnimatedIndicatorState extends State<_AnimatedIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
