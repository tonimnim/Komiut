/// Payment countdown timer widget.
///
/// Displays a countdown timer for STK push timeout with visual
/// progress indicator.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// A countdown timer widget for payment timeout.
class PaymentCountdown extends StatefulWidget {
  const PaymentCountdown({
    super.key,
    required this.durationSeconds,
    required this.onTimeout,
    this.onTick,
    this.showProgress = true,
    this.autoStart = true,
  });

  /// Total duration of the countdown in seconds.
  final int durationSeconds;

  /// Callback when the countdown reaches zero.
  final VoidCallback onTimeout;

  /// Optional callback on each tick with remaining seconds.
  final void Function(int remainingSeconds)? onTick;

  /// Whether to show the progress indicator.
  final bool showProgress;

  /// Whether to start the countdown automatically.
  final bool autoStart;

  @override
  State<PaymentCountdown> createState() => PaymentCountdownState();
}

class PaymentCountdownState extends State<PaymentCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _timer;
  late int _remainingSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );

    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  /// Start the countdown.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  /// Stop the countdown.
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _progressController.stop();
  }

  /// Reset the countdown.
  void reset() {
    stop();
    setState(() {
      _remainingSeconds = widget.durationSeconds;
    });
    _progressController.reset();
  }

  /// Restart the countdown from the beginning.
  void restart() {
    reset();
    start();
  }

  void _onTick(Timer timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }

    setState(() {
      _remainingSeconds--;
    });

    widget.onTick?.call(_remainingSeconds);

    if (_remainingSeconds <= 0) {
      timer.cancel();
      _isRunning = false;
      widget.onTimeout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = _remainingSeconds / widget.durationSeconds;
    final isLow = _remainingSeconds <= 10;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showProgress) ...[
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLow ? AppColors.warning : AppColors.primaryBlue,
                    ),
                  ),
                ),
                // Time display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isLow
                            ? AppColors.warning
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: isLow
                    ? AppColors.warning
                    : (isDark ? Colors.grey[400] : AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatTime(_remainingSeconds)} remaining',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isLow ? FontWeight.w600 : FontWeight.normal,
                  color: isLow
                      ? AppColors.warning
                      : (isDark ? Colors.grey[400] : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '0:${secs.toString().padLeft(2, '0')}';
  }
}

/// A compact linear countdown timer.
class PaymentCountdownLinear extends StatefulWidget {
  const PaymentCountdownLinear({
    super.key,
    required this.durationSeconds,
    required this.onTimeout,
    this.autoStart = true,
  });

  final int durationSeconds;
  final VoidCallback onTimeout;
  final bool autoStart;

  @override
  State<PaymentCountdownLinear> createState() => _PaymentCountdownLinearState();
}

class _PaymentCountdownLinearState extends State<PaymentCountdownLinear>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );

    if (widget.autoStart) {
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        widget.onTimeout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLow = _remainingSeconds <= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time remaining',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
            Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLow
                    ? AppColors.warning
                    : (isDark ? Colors.grey[400] : AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: 1 - _controller.value,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isLow ? AppColors.warning : AppColors.primaryBlue,
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            );
          },
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '0:${secs.toString().padLeft(2, '0')}';
  }
}
