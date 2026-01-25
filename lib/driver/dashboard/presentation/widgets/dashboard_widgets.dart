import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';

class DashboardColors {
  static const Color primary = AppColors.primaryBlue;
  static const Color background = AppColors.background;
  static const Color textBlack = AppColors.textPrimary;
  static const Color textGrey = AppColors.textSecondary;
  static const Color green = AppColors.primaryGreen;
  static const Color progressGrey = AppColors.grey200;
  static const Color upcomingBlueBg = AppColors.pillBlueBg;
  static const Color cardShadow = AppColors.cardShadow;
}

class AssignedSaccoCard extends StatelessWidget {
  final CircleRoute? route;
  const AssignedSaccoCard({super.key, this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
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
                style: AppTextStyles.overline.copyWith(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                route?.circleName ?? 'Matatu Sacco',
                style: AppTextStyles.heading3.copyWith(fontSize: 22, color: AppColors.textPrimary),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ROUTE',
                style: AppTextStyles.overline.copyWith(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pillBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  route?.code ?? 'Route 102',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryBlue,
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
  const VehicleCapacityCard({super.key, this.vehicle});

  @override
  Widget build(BuildContext context) {
    final int currentCount = 8;
    final int totalCapacity = vehicle?.capacity ?? 14;
    final double percent = currentCount / totalCapacity;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
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
                  backgroundColor: AppColors.grey100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentCount/$totalCapacity',
                    style: AppTextStyles.heading1.copyWith(fontSize: 32),
                  ),
                  Text(
                    'Seats filled',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Vehicle Capacity',
            style: AppTextStyles.heading4.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Currently loading passengers at Main Terminal',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              Text(
                'Loading',
                style: AppTextStyles.body2.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.grey100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSpecRow(Vehicle? vehicle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSpecItem('MODEL', vehicle?.model ?? 'Hiace'),
          _buildSpecDivider(),
          _buildSpecItem('YEAR', '${vehicle?.year ?? 2020}'),
          _buildSpecDivider(),
          _buildSpecItem('COLOR', vehicle?.color ?? 'White'),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.overline.copyWith(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSpecDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.grey200,
    );
  }
}



class DashboardActionButtons extends StatelessWidget {
  final CircleRoute? route;
  const DashboardActionButtons({super.key, this.route});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          label: 'Loading',
          icon: Icons.hourglass_empty_rounded,
          isSelected: true,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ActionButton(
          label: 'Full',
          icon: Icons.chair_rounded,
          isSelected: false,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ActionButton(
          label: 'Depart',
          icon: Icons.airport_shuttle_rounded,
          isSelected: false,
          onTap: () => context.push(RouteNames.driverQueue, extra: route),
          isBlue: true,
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
  final bool isBlue;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isBlue = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = isSelected || isBlue;
    return Expanded(
      child: Material(
        color: isBlue ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: active ? AppColors.primaryBlue : AppColors.grey100),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isBlue ? Colors.white : (isSelected ? AppColors.primaryBlue : AppColors.textSecondary),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    color: isBlue ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
  const DashboardStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Trips Today',
            value: '12',
            trend: '+2 vs yesterday',
            icon: Icons.route_rounded,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Earnings',
            value: r'$142.50',
            trend: '+12% this week',
            icon: Icons.payments_rounded,
            color: AppColors.primaryBlue,
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                trend,
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.primaryGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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
      onTap: () => context.push(RouteNames.joinQueue),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.pillBlueBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map_rounded, color: Colors.white, size: 28),
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
                    style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Text(
              '15:30 PM',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


