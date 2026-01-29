import 'package:equatable/equatable.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

class GetEarningsSummaryEvent extends EarningsEvent {
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetEarningsSummaryEvent({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

class GetTripHistoryEvent extends EarningsEvent {
  final int page;
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? routeId;

  const GetTripHistoryEvent({
    this.page = 1,
    this.limit = 20,
    this.startDate,
    this.endDate,
    this.routeId,
  });

  @override
  List<Object?> get props => [page, limit, startDate, endDate, routeId];
}

class GetTripHistoryDetailsEvent extends EarningsEvent {
  final String tripId;

  const GetTripHistoryDetailsEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}
