/// Trip ETA display widget.
///
/// Displays the estimated time of arrival, distance remaining,
/// and stops remaining to destination.
library;

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/active_trip.dart';

/// A display showing ETA, distance, and stops remaining.
class TripETADisplay extends StatefulWidget {
  const TripETADisplay({
    super.key,
    required this.trip,
    this.style = TripETADisplayStyle.card,
  });

  /// The active trip to display ETA for.
  final ActiveTrip trip;

  /// Display style (card or inline).
  final TripETADisplayStyle style;

  @override
  State<TripETADisplay> createState() => _TripETADisplayState();
}

/// Display style options.
enum TripETADisplayStyle {
  /// Card style with background.
  card,

  /// Inline style without background.
  inline,

  /// Prominent style with large ETA.
  prominent,
}

class _TripETADisplayState extends State<TripETADisplay> {
  late Timer _timer;
  late String _formattedETA;

  @override
  void initState() {
    super.initState();
    _updateETA();
    // Update ETA every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateETA());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateETA() {
    setState(() {
      _formattedETA = widget.trip.formattedETA;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case TripETADisplayStyle.card:
        return _buildCardStyle(context);
      case TripETADisplayStyle.inline:
        return _buildInlineStyle(context);
      case TripETADisplayStyle.prominent:
        return _buildProminentStyle(context);
    }
  }

  Widget _buildCardStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ETA
          Expanded(
            child: _ETAItem(
              icon: Icons.access_time,
              label: 'Arriving in',
              value: _formattedETA,
              valueColor: AppColors.primaryBlue,
              isDark: isDark,
            ),
          ),

          _VerticalDivider(isDark: isDark),

          // Distance
          Expanded(
            child: _ETAItem(
              icon: Icons.straighten,
              label: 'Distance',
              value: widget.trip.formattedDistance,
              isDark: isDark,
            ),
          ),

          _VerticalDivider(isDark: isDark),

          // Stops
          Expanded(
            child: _ETAItem(
              icon: Icons.location_on_outlined,
              label: 'Stops left',
              value: '${widget.trip.stopsRemaining}',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _InlineETAItem(
          icon: Icons.access_time,
          value: _formattedETA,
          isDark: isDark,
          isHighlighted: true,
        ),
        _InlineETAItem(
          icon: Icons.straighten,
          value: widget.trip.formattedDistance,
          isDark: isDark,
        ),
        _InlineETAItem(
          icon: Icons.location_on_outlined,
          value: '${widget.trip.stopsRemaining} stops',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildProminentStyle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main ETA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arriving in',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    _formattedETA,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Secondary info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProminentInfoItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: widget.trip.formattedDistance,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.2),
                ),
                _ProminentInfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Stops',
                  value: '${widget.trip.stopsRemaining}',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.2),
                ),
                _ProminentInfoItem(
                  icon: Icons.speed,
                  label: 'Speed',
                  value: widget.trip.currentVehiclePosition?.speed != null
                      ? '${widget.trip.currentVehiclePosition!.speed!.toStringAsFixed(0)} km/h'
                      : '--',
                ),
              ],
            ),
          ),

          // Arrival time
          if (widget.trip.estimatedArrival != null) ...[
            const SizedBox(height: 12),
            Text(
              'Estimated arrival at ${_formatTime(widget.trip.estimatedArrival!)}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

/// ETA item for card style.
class _ETAItem extends StatelessWidget {
  const _ETAItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : AppColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Vertical divider for card style.
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }
}

/// ETA item for inline style.
class _InlineETAItem extends StatelessWidget {
  const _InlineETAItem({
    required this.icon,
    required this.value,
    required this.isDark,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String value;
  final bool isDark;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlighted
              ? AppColors.primaryBlue
              : (isDark ? Colors.grey[400] : AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            color: isHighlighted
                ? AppColors.primaryBlue
                : (isDark ? Colors.grey[400] : AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Info item for prominent style.
class _ProminentInfoItem extends StatelessWidget {
  const _ProminentInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white70,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

/// Compact ETA badge for use in app bars or small spaces.
class TripETABadge extends StatelessWidget {
  const TripETABadge({
    super.key,
    required this.eta,
    this.backgroundColor,
  });

  /// The formatted ETA string.
  final String eta;

  /// Optional background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 14,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            eta,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
