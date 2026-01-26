import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/earnings_widgets.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../core/routes/route_names.dart';

class EarningsScreen extends StatefulWidget {
  final bool isTab;
  final DriverProfile? profile;
  const EarningsScreen({super.key, this.isTab = false, this.profile});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _isWeekly = true;

  @override
  Widget build(BuildContext context) {
    final String balance = _isWeekly ? '14,250.00' : '4,500.00';
    final String trend = _isWeekly ? '12%' : '8%';
    final List<double> chartValues = _isWeekly 
        ? [0.2, 0.4, 0.3, 0.6, 0.8, 0.5, 0.1]
        : [0.3, 0.7, 0.4];
    final List<String> chartLabels = _isWeekly
        ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : ['08:00', '12:00', '16:00'];
    final String periodText = _isWeekly ? 'Oct 16 - Oct 22' : 'Today, Oct 22';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.isTab) _buildHeader(context),
             Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    EarningsToggle(
                      isWeekly: _isWeekly,
                      onToggle: (val) => setState(() => _isWeekly = val),
                    ),
                    const SizedBox(height: 24),
                    BalanceCard(amount: balance, trend: trend),
                    const SizedBox(height: 32),
                    EarningsChart(
                      values: chartValues,
                      labels: chartLabels,
                      period: periodText,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Trips',
                          style: AppTextStyles.heading3.copyWith(fontSize: 18),
                        ),
                        TextButton(
                          onPressed: () => context.push(RouteNames.tripHistory, extra: widget.profile),
                          child: Text(
                            'See All',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!_isWeekly) ...[
                      TransactionItem(
                        title: 'Downtown Loop',
                        date: 'Today, 2:45 PM',
                        status: 'Completed',
                        amount: '2,480.00',
                        icon: Icons.directions_bus_rounded,
                        iconColor: AppColors.primaryBlue,
                        onTap: () => _showTripDetail(context, 'Downtown Loop', 'KES 2,480.00'),
                      ),
                      TransactionItem(
                        title: 'Airport Terminal 2',
                        date: 'Today, 11:20 AM',
                        status: 'Completed',
                        amount: '2,020.00',
                        icon: Icons.flight_takeoff_rounded,
                        iconColor: AppColors.primaryBlue,
                        onTap: () => _showTripDetail(context, 'Airport Terminal 2', 'KES 2,020.00'),
                      ),
                    ] else ...[
                      TransactionItem(
                        title: 'Downtown Loop',
                        date: 'Today, 2:45 PM',
                        status: 'Completed',
                        amount: '2,480.00',
                        icon: Icons.directions_bus_rounded,
                        iconColor: AppColors.primaryBlue,
                        onTap: () => _showTripDetail(context, 'Downtown Loop', 'KES 2,480.00'),
                      ),
                      TransactionItem(
                        title: 'Airport Terminal 2',
                        date: 'Today, 11:20 AM',
                        status: 'Completed',
                        amount: '5,800.00',
                        icon: Icons.flight_takeoff_rounded,
                        iconColor: AppColors.primaryBlue,
                        onTap: () => _showTripDetail(context, 'Airport Terminal 2', 'KES 5,800.00'),
                      ),
                      TransactionItem(
                        title: 'North Station',
                        date: 'Yesterday, 6:30 PM',
                        status: 'Archived',
                        amount: '1,220.00',
                        icon: Icons.history_rounded,
                        iconColor: AppColors.textMuted,
                        onTap: () => _showTripDetail(context, 'North Station', 'KES 1,220.00'),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isTab ? null : _buildBottomAction(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Earnings',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading4.copyWith(fontSize: 18),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.grey900,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.payments_rounded, color: Colors.white),
        label: const Text('Request Payout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppTextStyles.button.copyWith(fontSize: 18),
        ),
      ),
    );
  }

  void _showTripDetail(BuildContext context, String title, String total) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
            _buildDetailRow('Route', title),
            const SizedBox(height: 20),
            _buildDetailRow('Date', 'October 22, 2026'),
            const SizedBox(height: 20),
            _buildDetailRow('Passengers', '14'),
            const SizedBox(height: 20),
            _buildDetailRow('Distance', '12.5 km'),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            _buildDetailRow('Gross Fare', total),
            const SizedBox(height: 12),
            _buildDetailRow('Platform Fee (10%)', '- KES 250.00', isRed: true),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net Earnings', style: AppTextStyles.heading4),
                Text(total, style: AppTextStyles.heading4.copyWith(color: AppColors.primaryGreen)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isRed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: isRed ? Colors.redAccent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
