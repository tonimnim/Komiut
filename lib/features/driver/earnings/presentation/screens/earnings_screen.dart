/// Driver earnings screen.
///
/// Shows the driver's earnings and financial summary:
/// - Today's earnings breakdown
/// - Weekly/monthly summary
/// - Earnings history with charts
/// - Payment method breakdown (cash vs mobile)
///
/// ## TODO(Musa): Implement earnings screen
///
/// ### High Priority
/// - [ ] Create `EarningsProvider` in `providers/earnings_provider.dart`
/// - [ ] Fetch earnings using `ApiEndpoints.driverEarnings`
/// - [ ] Display today's total earnings prominently
/// - [ ] Show breakdown by payment method (cash, M-PESA, wallet)
///
/// ### Medium Priority
/// - [ ] Add weekly earnings chart (use fl_chart package)
/// - [ ] Implement date range filters
/// - [ ] Show per-trip earnings list
/// - [ ] Add monthly summary view
///
/// ### Low Priority
/// - [ ] Add earnings export functionality (CSV/PDF)
/// - [ ] Implement earnings comparison (vs last week/month)
/// - [ ] Add earnings goals/targets
/// - [ ] Implement offline earnings caching
///
/// ### API Endpoints to use:
/// - `ApiEndpoints.driverEarnings` - Get earnings summary
/// - `ApiEndpoints.driverEarningsByDate(date)` - Get earnings for specific date
/// - `ApiEndpoints.driverEarningsRange(start, end)` - Get earnings for date range
/// - `ApiEndpoints.dailyVehicleTotals` - Get daily vehicle totals
///
/// ### Charts Package:
/// Consider using `fl_chart` for earnings visualization:
/// ```yaml
/// dependencies:
///   fl_chart: ^0.66.0
/// ```
///
/// ### Data model needed:
/// ```dart
/// class EarningsSummary {
///   final double totalEarnings;
///   final double cashEarnings;
///   final double mpesaEarnings;
///   final double walletEarnings;
///   final int totalTrips;
///   final int totalPassengers;
///   final List<DailyEarnings> dailyBreakdown;
/// }
///
/// class DailyEarnings {
///   final DateTime date;
///   final double amount;
///   final int trips;
/// }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';

/// Earnings screen widget.
///
/// Displays the driver's earnings with breakdown and history.
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO(Musa): Replace with actual selected period from UI
  String _selectedPeriod = 'Today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.driverHome),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO(Musa): Show date picker for earnings range
              _showDateRangePicker(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO(Musa): Export earnings report
              _showExportOptions(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'By Trip'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context),
          _buildByTripTab(context),
          _buildHistoryTab(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────────────────────────────────────────────────
          // Period Selector
          // ─────────────────────────────────────────────────────────────────────
          _buildPeriodSelector(context),
          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────────
          // Total Earnings Card
          // TODO(Musa): Replace with actual earnings data
          // ─────────────────────────────────────────────────────────────────────
          _buildTotalEarningsCard(context),
          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────────
          // Payment Method Breakdown
          // TODO(Musa): Replace with actual data
          // ─────────────────────────────────────────────────────────────────────
          const Text(
            'Payment Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentBreakdown(context),
          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────────
          // Weekly Chart
          // TODO(Musa): Implement with fl_chart
          // ─────────────────────────────────────────────────────────────────────
          const Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildWeeklyChart(context),
          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────────
          // Quick Stats
          // ─────────────────────────────────────────────────────────────────────
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickStats(context),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final periods = ['Today', 'This Week', 'This Month'];
    return Row(
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(period),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedPeriod = period);
                // TODO(Musa): Fetch earnings for selected period
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalEarningsCard(BuildContext context) {
    // TODO(Musa): Replace with actual earnings data from provider
    return Card(
      color: AppColors.primaryBlue,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _selectedPeriod,
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'KSh --',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEarningsStatItem(
                  icon: Icons.directions_bus,
                  value: '--',
                  label: 'Trips',
                ),
                _buildEarningsStatItem(
                  icon: Icons.people,
                  value: '--',
                  label: 'Passengers',
                ),
                _buildEarningsStatItem(
                  icon: Icons.trending_up,
                  value: '--%',
                  label: 'vs Last Week',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withAlpha(179), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(179),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdown(BuildContext context) {
    // TODO(Musa): Replace with actual breakdown data
    return Row(
      children: [
        Expanded(
          child: _buildPaymentMethodCard(
            icon: Icons.money,
            label: 'Cash',
            value: 'KSh --',
            percentage: '--%',
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPaymentMethodCard(
            icon: Icons.phone_android,
            label: 'M-PESA',
            value: 'KSh --',
            percentage: '--%',
            color: AppColors.secondaryOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPaymentMethodCard(
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            value: 'KSh --',
            percentage: '--%',
            color: AppColors.secondaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String label,
    required String value,
    required String percentage,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    // TODO(Musa): Implement actual chart with fl_chart
    // Example chart data structure:
    // final chartData = [
    //   FlSpot(0, monday_earnings),
    //   FlSpot(1, tuesday_earnings),
    //   ...
    // ];
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Weekly Earnings Chart',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'TODO: Implement with fl_chart',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // Days of week labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Text(
                        day,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    // TODO(Musa): Replace with actual statistics
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Average per trip', 'KSh --'),
            const Divider(),
            _buildStatRow('Best day this week', '--'),
            const Divider(),
            _buildStatRow('Total passengers', '--'),
            const Divider(),
            _buildStatRow('Working hours', '--'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildByTripTab(BuildContext context) {
    // TODO(Musa): Fetch and display per-trip earnings
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // TODO: Replace with actual trip count
      itemBuilder: (context, index) {
        return _buildTripEarningItem(
          route: index % 2 == 0 ? 'CBD - Westlands' : 'Westlands - CBD',
          time: '${8 + index}:30 AM',
          passengers: 10 + index,
          fare: 'KSh ${1000 + index * 100}',
          paymentMethod: index % 2 == 0 ? 'M-PESA' : 'Cash',
        );
      },
    );
  }

  Widget _buildTripEarningItem({
    required String route,
    required String time,
    required int passengers,
    required String fare,
    required String paymentMethod,
  }) {
    final isMpesa = paymentMethod == 'M-PESA';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMpesa
              ? AppColors.secondaryOrange.withAlpha(26)
              : AppColors.primaryGreen.withAlpha(26),
          child: Icon(
            isMpesa ? Icons.phone_android : Icons.money,
            color: isMpesa ? AppColors.secondaryOrange : AppColors.primaryGreen,
          ),
        ),
        title: Text(route),
        subtitle: Text('$time | $passengers passengers | $paymentMethod'),
        trailing: Text(
          fare,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO(Musa): Navigate to trip detail
        },
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    // TODO(Musa): Implement earnings history with date grouping
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDateEarningHeader('Today', 'KSh --'),
        _buildTripEarningItem(
          route: 'CBD - Westlands',
          time: '08:30 AM',
          passengers: 14,
          fare: 'KSh 1,400',
          paymentMethod: 'M-PESA',
        ),
        _buildDateEarningHeader('Yesterday', 'KSh --'),
        _buildTripEarningItem(
          route: 'Westlands - CBD',
          time: '06:00 PM',
          passengers: 10,
          fare: 'KSh 1,000',
          paymentMethod: 'Cash',
        ),
        _buildDateEarningHeader('2 days ago', 'KSh --'),
        _buildTripEarningItem(
          route: 'CBD - Eastleigh',
          time: '02:00 PM',
          passengers: 12,
          fare: 'KSh 600',
          paymentMethod: 'M-PESA',
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () {
              // TODO(Musa): Load more history
            },
            child: const Text('Load More'),
          ),
        ),
      ],
    );
  }

  Widget _buildDateEarningHeader(String date, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            total,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) {
    // TODO(Musa): Implement proper date range picker
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    ).then((range) {
      if (range != null) {
        // TODO(Musa): Fetch earnings for selected range
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selected: ${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}',
            ),
          ),
        );
      }
    });
  }

  void _showExportOptions(BuildContext context) {
    // TODO(Musa): Implement actual export functionality
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Earnings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              subtitle: const Text('Formatted report with charts'),
              onTap: () {
                Navigator.pop(context);
                // TODO(Musa): Generate and share PDF
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TODO: Export PDF')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () {
                Navigator.pop(context);
                // TODO(Musa): Generate and share CSV
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TODO: Export CSV')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, // Earnings tab
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.format_list_numbered_outlined),
          activeIcon: Icon(Icons.format_list_numbered),
          label: 'Queue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_bus_outlined),
          activeIcon: Icon(Icons.directions_bus),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Earnings',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(RouteConstants.driverHome);
            break;
          case 1:
            context.go(RouteConstants.driverQueue);
            break;
          case 2:
            context.go(RouteConstants.driverTrips);
            break;
          case 3:
            // Already on earnings
            break;
        }
      },
    );
  }
}
