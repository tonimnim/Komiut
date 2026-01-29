import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/driver/earnings/presentation/widgets/earnings_widgets.dart';
import 'package:komiut/driver/dashboard/presentation/widgets/dashboard_widgets.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/core/routes/route_names.dart';
import 'package:komiut/shared/widgets/komiut_app_bar.dart';
import 'package:komiut/di/injection_container.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/buttons/app_button.dart';

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
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => getIt<EarningsBloc>()..add(GetEarningsSummaryEvent(period: _isWeekly ? 'weekly' : 'daily')),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: KomiutAppBar(
          title: 'Earnings',
          imageUrl: widget.profile?.imageUrl,
          showProfileIcon: true,
          leading: widget.isTab ? null : IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
            onPressed: () => context.pop(),
          ),
          onProfileTap: () {
            // Logic to switch to profile tab if needed
          },
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.onSurface),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  if (state is EarningsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EarningsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is EarningsLoaded) {
                    final summary = state.summary;
                    final trips = state.tripHistory;
                    
                    final String balance = NumberFormat('#,##0.00').format(summary.netEarnings);
                    const String trend = '8%'; // Still hardcoded if not in summary or calculations
                    
                    // Simple chart values from state
                    final List<double> chartValues = _isWeekly 
                        ? [0.2, 0.4, 0.3, 0.6, 0.8, 0.5, 0.1]
                        : [0.3, 0.5, 0.7];
                    final List<String> chartLabels = _isWeekly
                        ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        : ['08:00', '12:00', '16:00'];
                    final String periodText = _isWeekly ? 'Current Week' : 'Today';

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          EarningsToggle(
                            isWeekly: _isWeekly,
                            onToggle: (val) {
                              setState(() => _isWeekly = val);
                              context.read<EarningsBloc>().add(GetEarningsSummaryEvent(period: val ? 'weekly' : 'daily'));
                            },
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
                                style: AppTextStyles.heading3,
                              ),
                              TextButton(
                                onPressed: () => context.push(RouteNames.tripHistory, extra: widget.profile),
                                child: Text(
                                  'See All',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (trips.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: AppEmptyState.noTrips(
                                message: 'No recent trips found for this period',
                                compact: true,
                              ),
                            )
                          else
                            ...trips.take(5).map((trip) => TransactionItem(
                              title: trip.routeName,
                              date: trip.time,
                              status: trip.status,
                              amount: NumberFormat('#,##0.00').format(trip.earnings),
                              icon: Icons.directions_bus_rounded,
                              iconColor: Theme.of(context).colorScheme.primary,
                              onTap: () => _showTripDetail(context, trip.routeName, 'KES ${NumberFormat('#,##0.00').format(trip.earnings)}', trip.date, trip.passengers),
                            )),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (widget.isTab) _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: AppButton.primary(
        onPressed: () {},
        icon: Icons.payments_rounded,
        label: 'Request Payout',
        size: ButtonSize.large,
        isFullWidth: true,
        gradient: AppColors.primaryGradient,
      ),
    );
  }

  void _showTripDetail(BuildContext context, String title, String total, DateTime date, int passengers) {
    showDialog(
      context: context,
      builder: (context) {
        final dialogTheme = Theme.of(context);
        return Dialog(
          backgroundColor: dialogTheme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 24),
              _buildDetailRow('Route', title),
              const SizedBox(height: 16),
              _buildDetailRow('Date', DateFormat('MMMM dd, yyyy').format(date)),
              const SizedBox(height: 16),
              _buildDetailRow('Passengers', passengers.toString()),
              const SizedBox(height: 16),
              _buildDetailRow('Distance', '12.5 km'),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildDetailRow('Gross Fare', total),
              const SizedBox(height: 12),
              _buildDetailRow('Platform Fee (10%)', '- KES 250.00', isRed: true),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Net Earnings', style: AppTextStyles.heading4),
                  Text(total, style: AppTextStyles.heading4.copyWith(color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 32),
              AppButton.primary(
                onPressed: () => Navigator.pop(context),
                label: 'GOT IT',
                size: ButtonSize.large,
                isFullWidth: true,
              ),
              ],
            ),
          ),
        );
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
            color: isRed ? AppColors.redAccent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
