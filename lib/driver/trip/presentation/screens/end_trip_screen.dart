import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';

class EndTripScreen extends StatelessWidget {
  final Map<String, dynamic>? tripData;
  const EndTripScreen({super.key, this.tripData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Trip Complete!',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                'You have arrived at Westlands Terminal',
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              
              // Stats Card
              _buildStatsCard(),
              
              const SizedBox(height: 32),
              
              // Earnings Card
              _buildEarningsCard(),
              
              const Spacer(),
              
              // Action Buttons
              AppButton.primary(
                label: 'BACK TO DASHBOARD',
                onPressed: () => context.go(RouteNames.driverDashboard, extra: {'refresh': true}),
                size: ButtonSize.large,
                isFullWidth: true,
              ),
              const SizedBox(height: 16),
              AppButton.text(
                onPressed: () => _showTripDetail(context),
                label: 'View Trip Details',
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final sheetTheme = Theme.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: sheetTheme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trip Details', style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTripDetailRow('Route', 'Nairobi CBD -> Westlands'),
            const SizedBox(height: 20),
            _buildTripDetailRow('Date', 'October 25, 2026'),
            const SizedBox(height: 20),
            _buildTripDetailRow('Passengers', '14'),
            const SizedBox(height: 20),
            _buildTripDetailRow('Distance', '8.5 km'),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            _buildTripDetailRow('Gross Fare', 'KES 1,400'),
            const SizedBox(height: 12),
            _buildTripDetailRow('Platform Fee (10%)', '- KES 140', isRed: true),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net Earnings', style: AppTextStyles.heading4),
                Text('KES 1,260', style: AppTextStyles.heading4.copyWith(color: AppColors.success)),
              ],
            ),
            const Spacer(),
            AppButton.primary(
              onPressed: () => Navigator.pop(context),
              label: 'CLOSE',
              size: ButtonSize.large,
              isFullWidth: true,
            ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripDetailRow(String label, String value, {bool isRed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: isRed ? AppColors.redAccent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStat(tripData?['duration'] ?? '32 min', 'Duration'),
            Container(width: 1, height: 40, color: theme.dividerColor),
            _buildStat(tripData?['distance'] ?? '8.5 km', 'Distance'),
            Container(width: 1, height: 40, color: theme.dividerColor),
            _buildStat('${tripData?['passengers'] ?? 14}', 'Passengers'),
          ],
        ),
      );
    });
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading4),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.overline.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildEarningsCard() {
    final double gross = (tripData?['fare'] ?? 1400.0).toDouble();
    final double fee = gross * 0.1;
    final double net = gross - fee;

    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EARNINGS', style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: 20),
            _buildEarningsRow('Gross Fare', 'KES ${gross.toInt()}'),
            const SizedBox(height: 12),
            _buildEarningsRow('Platform Fee (10%)', '- KES ${fee.toInt()}', isNegative: true),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: theme.dividerColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net Earnings', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'KES ${net.toInt()}',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEarningsRow(String label, String value, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            color: isNegative ? AppColors.error : AppColors.textPrimary,
            fontWeight: isNegative ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
