/// Boarding success animation widget.
///
/// Animated success display shown when boarding is confirmed.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';

/// Success animation for boarding confirmation.
class BoardingSuccessAnimation extends StatefulWidget {
  const BoardingSuccessAnimation({
    super.key,
    required this.ticket,
    this.onComplete,
    this.message = 'Boarding Confirmed!',
    this.autoHide = true,
    this.autoHideDuration = const Duration(seconds: 3),
  });

  /// The ticket that was boarded.
  final Ticket ticket;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  /// Custom success message.
  final String message;

  /// Whether to auto-hide after animation.
  final bool autoHide;

  /// Duration before auto-hide.
  final Duration autoHideDuration;

  @override
  State<BoardingSuccessAnimation> createState() =>
      _BoardingSuccessAnimationState();
}

class _BoardingSuccessAnimationState extends State<BoardingSuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale pulse animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: Curves.easeOutBack,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation sequence
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Start scale animation
    await _scaleController.forward();

    // Start check animation
    _checkController.forward();

    // Fade in content
    await _fadeController.forward();

    // Success haptic
    HapticFeedback.heavyImpact();

    // Auto-hide if enabled
    if (widget.autoHide) {
      await Future.delayed(widget.autoHideDuration);
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon with animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedBuilder(
                  listenable: _checkAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(60, 60),
                      painter: _CheckPainter(
                        progress: _checkAnimation.value,
                        color: AppColors.success,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Success message
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Have a safe trip!',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Ticket info summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.directions_bus_outlined,
                        label: widget.ticket.routeInfo.name,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label: widget.ticket.ticketNumber,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label:
                            '${widget.ticket.pickupStop} → ${widget.ticket.dropoffStop}',
                      ),
                      if (widget.ticket.seatNumber != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.event_seat_outlined,
                          label: 'Seat ${widget.ticket.seatNumber}',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for animated check mark.
class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Check mark points (relative to size)
    final startPoint = Offset(size.width * 0.2, size.height * 0.5);
    final midPoint = Offset(size.width * 0.4, size.height * 0.7);
    final endPoint = Offset(size.width * 0.8, size.height * 0.3);

    // Calculate how far to draw based on progress
    if (progress <= 0.5) {
      // First stroke (going down)
      final firstProgress = progress * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(
        startPoint.dx + (midPoint.dx - startPoint.dx) * firstProgress,
        startPoint.dy + (midPoint.dy - startPoint.dy) * firstProgress,
      );
    } else {
      // Complete first stroke
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(midPoint.dx, midPoint.dy);

      // Second stroke (going up)
      final secondProgress = (progress - 0.5) * 2;
      path.lineTo(
        midPoint.dx + (endPoint.dx - midPoint.dx) * secondProgress,
        midPoint.dy + (endPoint.dy - midPoint.dy) * secondProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Info row for success display.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact success indicator.
class BoardingSuccessIndicator extends StatefulWidget {
  const BoardingSuccessIndicator({
    super.key,
    this.size = 48,
  });

  final double size;

  @override
  State<BoardingSuccessIndicator> createState() =>
      _BoardingSuccessIndicatorState();
}

class _BoardingSuccessIndicatorState extends State<BoardingSuccessIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: widget.size * 0.6,
        ),
      ),
    );
  }
}

/// Helper widget for animated building.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
