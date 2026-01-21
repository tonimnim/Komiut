import 'package:flutter/material.dart';
import 'package:komiut_app/core/theme/app_colors.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final String? subLabel;
  final CrossAxisAlignment crossAxisAlignment;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.subLabel,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Column(
        children: [
          Icon(icon, color: AppColors.grey500, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (subLabel == null) ...[
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ] else ...[
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9), // Slate 100
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Grid background to simulate map
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),
          // Simulated route line
          CustomPaint(
            size: Size.infinite,
            painter: _RouteLinePainter(),
          ),
          // Animated vehicle indicator
          const Center(
            child: _PulsingVehicleMarker(),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw some "land" shapes to make it look less blank
    final landPaint = Paint()..color = Colors.green.withOpacity(0.05);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.3, size.height * 0.4), landPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.5, size.width * 0.4, size.height * 0.5), landPaint);

    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.9);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.35);
    path.lineTo(size.width * 0.9, size.height * 0.1);

    canvas.drawPath(path, paint);

    // Draw some waypoints
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 6, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsingVehicleMarker extends StatefulWidget {
  const _PulsingVehicleMarker();

  @override
  State<_PulsingVehicleMarker> createState() => _PulsingVehicleMarkerState();
}

class _PulsingVehicleMarkerState extends State<_PulsingVehicleMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 2.5).animate(_controller),
          child: FadeTransition(
            opacity: Tween(begin: 0.5, end: 0.0).animate(_controller),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
          child: const Icon(Icons.navigation, color: Colors.white, size: 16),
        ),
      ],
    );
  }
}

class SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subValue;
  final Color? subValueColor;

  const SummaryMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subValue,
    this.subValueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (subValue != null)
                Text(
                  subValue!,
                  style: TextStyle(
                    color: subValueColor ?? const Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CounterButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String time;
  final String location;
  final bool isFirst;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.time,
    required this.location,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: isFirst || isLast ? AppColors.accent : AppColors.grey300,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.grey100,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.grey100),
          boxShadow: isSelected 
            ? [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] 
            : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary, 
            fontWeight: FontWeight.bold, 
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
