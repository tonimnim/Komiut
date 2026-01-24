/// Ticket status badge widget.
///
/// Displays the current status of a ticket with appropriate styling.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';

/// Badge showing ticket status with color coding.
class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge({
    super.key,
    required this.status,
    this.size = TicketStatusBadgeSize.medium,
    this.showIcon = true,
  });

  /// The ticket status to display.
  final TicketStatus status;

  /// Size of the badge.
  final TicketStatusBadgeSize size;

  /// Whether to show the status icon.
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    final sizeConfig = _getSizeConfig(size);

    return Container(
      padding: sizeConfig.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: sizeConfig.iconSize,
              color: config.textColor,
            ),
            SizedBox(width: sizeConfig.spacing),
          ],
          Text(
            status.label,
            style: TextStyle(
              fontSize: sizeConfig.fontSize,
              fontWeight: FontWeight.w600,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(TicketStatus status) {
    switch (status) {
      case TicketStatus.valid:
        return _StatusConfig(
          icon: Icons.check_circle_outline,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          borderColor: AppColors.success.withValues(alpha: 0.3),
          textColor: AppColors.success,
        );
      case TicketStatus.used:
        return _StatusConfig(
          icon: Icons.done_all,
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          borderColor: AppColors.info.withValues(alpha: 0.3),
          textColor: AppColors.info,
        );
      case TicketStatus.expired:
        return _StatusConfig(
          icon: Icons.schedule,
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          textColor: AppColors.warning,
        );
      case TicketStatus.cancelled:
        return _StatusConfig(
          icon: Icons.cancel_outlined,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          borderColor: AppColors.error.withValues(alpha: 0.3),
          textColor: AppColors.error,
        );
    }
  }

  _SizeConfig _getSizeConfig(TicketStatusBadgeSize size) {
    switch (size) {
      case TicketStatusBadgeSize.small:
        return const _SizeConfig(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          fontSize: 11,
          iconSize: 12,
          spacing: 4,
          borderRadius: 6,
        );
      case TicketStatusBadgeSize.medium:
        return const _SizeConfig(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          fontSize: 13,
          iconSize: 14,
          spacing: 6,
          borderRadius: 8,
        );
      case TicketStatusBadgeSize.large:
        return const _SizeConfig(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          fontSize: 15,
          iconSize: 18,
          spacing: 8,
          borderRadius: 10,
        );
    }
  }
}

/// Size variants for the badge.
enum TicketStatusBadgeSize { small, medium, large }

/// Configuration for status styling.
class _StatusConfig {
  const _StatusConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}

/// Configuration for badge sizing.
class _SizeConfig {
  const _SizeConfig({
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.spacing,
    required this.borderRadius,
  });

  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double spacing;
  final double borderRadius;
}

/// Animated status badge that pulses for valid tickets.
class AnimatedTicketStatusBadge extends StatefulWidget {
  const AnimatedTicketStatusBadge({
    super.key,
    required this.status,
    this.animate = true,
  });

  final TicketStatus status;
  final bool animate;

  @override
  State<AnimatedTicketStatusBadge> createState() =>
      _AnimatedTicketStatusBadgeState();
}

class _AnimatedTicketStatusBadgeState extends State<AnimatedTicketStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate && widget.status == TicketStatus.valid) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTicketStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && widget.status == TicketStatus.valid) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || widget.status != TicketStatus.valid) {
      return TicketStatusBadge(
        status: widget.status,
        size: TicketStatusBadgeSize.large,
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: TicketStatusBadge(
        status: widget.status,
        size: TicketStatusBadgeSize.large,
      ),
    );
  }
}
