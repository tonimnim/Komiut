import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/earnings_widgets.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../di/injection_container.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import 'package:komiut/shared/widgets/komiut_app_bar.dart';

class TripHistoryScreen extends StatelessWidget {
  final DriverProfile? profile;
  const TripHistoryScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => getIt<EarningsBloc>()..add(const GetTripHistoryEvent()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: KomiutAppBar(
          title: 'Trip History',
          imageUrl: profile?.imageUrl,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<EarningsBloc, EarningsState>(
          builder: (context, state) {
            if (state is EarningsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EarningsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is EarningsLoaded) {
              final trips = state.tripHistory;
              
              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.history_rounded, size: 64, color: theme.dividerColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Trips Yet',
                        style: AppTextStyles.heading4.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Your completed trips or cancelled sessions will appear here.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Group trips by date
              final groupedTrips = <String, List<dynamic>>{};
              for (var trip in trips) {
                final dateStr = DateFormat('EEEE, MMM dd').format(trip.date);
                if (!groupedTrips.containsKey(dateStr)) {
                  groupedTrips[dateStr] = [];
                }
                groupedTrips[dateStr]!.add(trip);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: groupedTrips.length,
                itemBuilder: (context, index) {
                  final date = groupedTrips.keys.elementAt(index);
                  final dateTrips = groupedTrips[date]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateHeader(date, theme),
                      ...dateTrips.map((trip) => TransactionItem(
                        title: trip.routeName,
                        date: trip.time,
                        status: trip.status,
                        amount: NumberFormat('#,##0.00').format(trip.earnings),
                        icon: Icons.directions_bus_rounded,
                        iconColor: theme.colorScheme.primary,
                        onTap: () => context.push(
                          RouteNames.tripHistoryDetails,
                          extra: trip.tripId,
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        date.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.1),
      ),
    );
  }
}

