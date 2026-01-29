import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/shared/widgets/komiut_map.dart';
import '../../../../di/injection_container.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';

import 'package:komiut/shared/widgets/komiut_app_bar.dart';
import 'package:komiut/core/widgets/buttons/app_button.dart';

class TripHistoryDetailsScreen extends StatelessWidget {
  final String tripId;

  const TripHistoryDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => getIt<EarningsBloc>()..add(GetTripHistoryDetailsEvent(tripId)),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: KomiutAppBar(
          title: 'Trip Details',
          showProfileIcon: false, // Detail screen, icon might be overkill or needs profile data
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<EarningsBloc, EarningsState>(
          builder: (context, state) {
            if (state is EarningsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EarningsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is TripHistoryDetailsLoaded) {
              final details = state.details;
              
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: KomiutMap(
                        initialPosition: LatLng(-1.2867, 36.8172),
                        zoom: 14,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM dd, yyyy').format(details.startedAt),
                            style: AppTextStyles.heading4.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard([
                            _buildDetailRow('Start', DateFormat('hh:mm a').format(details.startedAt), theme),
                            _buildDetailRow('End', DateFormat('hh:mm a').format(details.endedAt), theme),
                            _buildDetailRow('Duration', '${details.durationMins} minutes', theme),
                            _buildDetailRow('Distance', '${details.distanceKm} km', theme),
                          ], theme),
                          const SizedBox(height: 24),
                          _buildInfoCard([
                            _buildDetailRow('Route', details.route.name, theme),
                            _buildDetailRow('Status', details.status, theme),
                            _buildDetailRow('Passengers', details.passengerCount.toString(), theme),
                          ], theme),
                          const SizedBox(height: 24),
                          _buildEarningsCard(details.earnings.grossFare, details.earnings.platformFee, details.earnings.netEarnings, theme),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: AppButton.primary(
            onPressed: () => Navigator.pop(context),
            label: 'CLOSE',
            size: ButtonSize.large,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: isRed ? theme.colorScheme.error : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(double gross, double fee, double net, ThemeData theme) {
    final formatter = NumberFormat('#,##0.00');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Gross Fare', 'KES ${formatter.format(gross)}', theme),
          _buildDetailRow('Platform Fee', '- KES ${formatter.format(fee)}', theme, isRed: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Earnings', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
              Text(
                'KES ${formatter.format(net)}',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

