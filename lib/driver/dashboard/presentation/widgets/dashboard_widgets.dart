import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/routes/route_names.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';

class DashboardColors {
  static const Color primary = AppColors.primaryBlue;
  static const Color background = AppColors.background;
  static const Color textBlack = AppColors.textPrimary;
  static const Color textGrey = AppColors.textSecondary;
  static const Color green = AppColors.success;
  static const Color progressGrey = AppColors.grey200;
  static const Color upcomingBlueBg = AppColors.pillBlueBg;
  static const Color cardShadow = AppColors.cardShadow;
}

class AssignedSaccoCard extends StatelessWidget {
  final CircleRoute? route;
  const AssignedSaccoCard({super.key, this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASSIGNED SACCO',
                style: AppTextStyles.overline.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                route?.circleName ?? 'Matatu Sacco',
                style: AppTextStyles.heading3.copyWith(fontSize: 20, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ROUTE',
                style: AppTextStyles.overline.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pillBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  route?.code ?? '102',
                  style: AppTextStyles.label.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VehicleCapacityCard extends StatelessWidget {
  final Vehicle? vehicle;
  final int currentPax;
  const VehicleCapacityCard({super.key, this.vehicle, this.currentPax = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int currentCount = currentPax;
    final int totalCapacity = vehicle?.capacity ?? 14;
    final double percent = (totalCapacity > 0) ? currentCount / totalCapacity : 0;
    final bool isFull = currentCount >= totalCapacity;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  backgroundColor: theme.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentCount/$totalCapacity',
                    style: AppTextStyles.heading1.copyWith(fontSize: 32, color: theme.colorScheme.onSurface),
                  ),
                  Text(
                    'Seats filled',
                    style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Vehicle Capacity',
            style: AppTextStyles.heading4.copyWith(fontSize: 18, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Currently loading passengers at Main Terminal',
            style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status', style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFull ? AppColors.pillGreenBg : AppColors.pillBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isFull ? 'Full' : 'Loading',
                  style: AppTextStyles.body2.copyWith(
                    color: isFull ? AppColors.success : theme.colorScheme.primary, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardActionButtons extends StatelessWidget {
  final CircleRoute? route;
  final int currentPax;
  final int capacity;

  const DashboardActionButtons({
    super.key, 
    this.route,
    this.currentPax = 0,
    this.capacity = 14,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFull = currentPax >= capacity;
    final bool isLoading = currentPax > 0 && currentPax < capacity;

    return Row(
      children: [
        _ActionButton(
          label: 'Loading',
          icon: Icons.hourglass_empty_rounded,
          isSelected: isLoading,
          color: AppColors.warning, // Amber/Orange
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ActionButton(
          label: 'Full',
          icon: Icons.chair_rounded,
          isSelected: isFull,
          color: AppColors.success, // Green
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ActionButton(
          label: 'Depart',
          icon: Icons.airport_shuttle_rounded,
          isSelected: false,
          color: AppColors.primaryBlue,
          gradient: AppColors.primaryGradient, // Use gradient for Depart
          onTap: () => context.push(RouteNames.driverQueue, extra: route),
          isPrimary: true,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final Gradient? gradient; // Added gradient support
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
    this.gradient,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Only primary button is filled (Solid). Others are tinted when selected.
    final bool isFilled = isPrimary;
    final bool isTinted = isSelected && !isPrimary;
    
    final Color backgroundColor = isFilled 
        ? color 
        : isTinted 
            ? color.withOpacity(0.1) 
            : theme.cardColor;
            
    final Color contentColor = isFilled 
        ? Colors.white 
        : isTinted 
            ? color 
            : theme.colorScheme.onSurfaceVariant;
            
    final Color borderColor = isFilled || isTinted 
        ? color 
        : theme.dividerColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: gradient == null ? backgroundColor : null,
              gradient: isFilled ? gradient : null, // Apply gradient if filled
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor.withOpacity(isTinted ? 0.5 : (isFilled ? 0 : 1)),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isFilled ? color : theme.shadowColor).withOpacity(isFilled ? 0.3 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isFilled 
                      ? Colors.white.withOpacity(0.2) 
                      : (isTinted ? color.withOpacity(0.1) : theme.colorScheme.surface),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: contentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardStatsGrid extends StatelessWidget {
  final EarningsSummary? earnings;
  const DashboardStatsGrid({super.key, this.earnings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Trips Today',
            value: '${earnings?.tripCount ?? 0}',
            trend: 'Total trips',
            icon: Icons.route_rounded,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Earnings',
            value: 'KES ${earnings?.totalEarnings.toStringAsFixed(0) ?? "0"}',
            trend: 'Today\'s total',
            icon: Icons.payments_rounded,
            color: Colors.white,
            backgroundColor: AppColors.walletCardGradient,
            isDark: true,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;
  final Gradient? backgroundColor;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor = isDark ? Colors.white.withOpacity(0.8) : theme.colorScheme.onSurfaceVariant;
    
    return Container(
      padding: const EdgeInsets.all(16), // Minimize layout
      decoration: BoxDecoration(
        color: backgroundColor == null ? theme.cardColor : null,
        gradient: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: backgroundColor == null ? Border.all(color: theme.dividerColor) : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0D9488) : theme.shadowColor).withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: isDark ? Colors.white : color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(fontSize: 20, color: textColor), // Reduced font size
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: isDark ? Colors.white : color, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      trend,
                      style: AppTextStyles.overline.copyWith(
                        color: isDark ? Colors.white : color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UpcomingRouteCard extends StatelessWidget {
  final CircleRoute? route;
  const UpcomingRouteCard({super.key, this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.preQueue),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.pillBlueBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Route',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route?.name ?? 'Central Station \u2192 West End',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '15:30',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'EST KES 350',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


