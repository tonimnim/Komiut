import 'package:equatable/equatable.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../../history/domain/entities/trip_history.dart';
import '../../../history/domain/entities/trip_history_details.dart';

abstract class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final EarningsSummary summary;
  final List<TripHistory> tripHistory;

  const EarningsLoaded({
    required this.summary,
    required this.tripHistory,
  });

  @override
  List<Object?> get props => [summary, tripHistory];
}

class TripHistoryDetailsLoaded extends EarningsState {
  final TripHistoryDetails details;

  const TripHistoryDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class EarningsError extends EarningsState {
  final String message;

  const EarningsError(this.message);

  @override
  List<Object?> get props => [message];
}
