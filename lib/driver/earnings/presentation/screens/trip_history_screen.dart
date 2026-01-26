import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/earnings_widgets.dart';
import '../../../../core/routes/route_names.dart';

class TripHistoryScreen extends StatelessWidget {
  final DriverProfile? profile;
  const TripHistoryScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Trip History',
          style: AppTextStyles.heading4.copyWith(fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: profile?.imageUrl != null ? NetworkImage(profile!.imageUrl!) : null,
              child: profile?.imageUrl == null ? const Icon(Icons.person, size: 16) : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildDateHeader('Today, Oct 22'),
          TransactionItem(
            title: 'Downtown Loop',
            date: '2:45 PM',
            status: 'Completed',
            amount: '2,480.00',
            icon: Icons.directions_bus_rounded,
            iconColor: AppColors.primaryBlue,
            onTap: () => _showTripDetail(context, 'Downtown Loop', 'KES 2,480.00', 'Today, Oct 22'),
          ),
          TransactionItem(
            title: 'Airport Terminal 2',
            date: '11:20 AM',
            status: 'Completed',
            amount: '2,020.00',
            icon: Icons.flight_takeoff_rounded,
            iconColor: AppColors.primaryBlue,
            onTap: () => _showTripDetail(context, 'Airport Terminal 2', 'KES 2,020.00', 'Today, Oct 22'),
          ),
          const SizedBox(height: 24),
          _buildDateHeader('Yesterday, Oct 21'),
          TransactionItem(
            title: 'North Station',
            date: '6:30 PM',
            status: 'Completed',
            amount: '3,220.00',
            icon: Icons.history_rounded,
            iconColor: AppColors.primaryBlue,
            onTap: () => _showTripDetail(context, 'North Station', 'KES 3,220.00', 'Yesterday, Oct 21'),
          ),
          TransactionItem(
            title: 'Westlands Mall',
            date: '1:15 PM',
            status: 'Completed',
            amount: '1,850.00',
            icon: Icons.shopping_bag_rounded,
            iconColor: AppColors.primaryBlue,
            onTap: () => _showTripDetail(context, 'Westlands Mall', 'KES 1,850.00', 'Yesterday, Oct 21'),
          ),
          TransactionItem(
            title: 'South Estate',
            date: '9:00 AM',
            status: 'Completed',
            amount: '2,100.00',
            icon: Icons.home_rounded,
            iconColor: AppColors.primaryBlue,
            onTap: () => _showTripDetail(context, 'South Estate', 'KES 2,100.00', 'Yesterday, Oct 21'),
          ),
          const SizedBox(height: 24),
          _buildDateHeader('Wednesday, Oct 20'),
          TransactionItem(
            title: 'Downtown Loop',
            date: '4:20 PM',
            status: 'Completed',
            amount: '2,480.00',
            icon: Icons.directions_bus_rounded,
            iconColor: AppColors.primaryBlue,
            onTap: () => _showTripDetail(context, 'Downtown Loop', 'KES 2,480.00', 'Wednesday, Oct 20'),
          ),
        ],
      ),
    );
  }

  void _showTripDetail(BuildContext context, String title, String total, String date) {
    context.push(
      RouteNames.tripHistoryDetails,
      extra: {
        'route': title,
        'amount': total,
        'date': date,
        'startTime': '10:00 AM',
        'endTime': '10:32 AM',
        'duration': '32 minutes',
        'distance': '8.5 km',
        'from': 'CBD Stage',
        'to': 'Westlands',
        'passengers': 14,
      },
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

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        date.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: AppColors.textMuted, letterSpacing: 1.1),
      ),
    );
  }
}
