import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/driver/earnings/domain/entities/earnings.dart';
import 'package:komiut_app/driver/earnings/domain/entities/earnings_summary.dart';
import 'package:komiut_app/driver/earnings/domain/repositories/earnings_repository.dart';

// Events
abstract class EarningsEvent extends Equatable {
  const EarningsEvent();
  @override
  List<Object?> get props => [];
}

class EarningsLoadSummaryRequested extends EarningsEvent {
  final String period; // 'daily', 'weekly', 'monthly'
  const EarningsLoadSummaryRequested({this.period = 'daily'});

  @override
  List<Object?> get props => [period];
}

class EarningsLoadTripEarningsRequested extends EarningsEvent {
  final String tripId;
  const EarningsLoadTripEarningsRequested(this.tripId);
  @override
  List<Object?> get props => [tripId];
}

// States
abstract class EarningsState extends Equatable {
  const EarningsState();
  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsSummaryLoaded extends EarningsState {
  final EarningsSummary summary;
  const EarningsSummaryLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class EarningsTripDetailsLoaded extends EarningsState {
  final Earnings earnings;
  const EarningsTripDetailsLoaded(this.earnings);
  @override
  List<Object?> get props => [earnings];
}

class EarningsError extends EarningsState {
  final String message;
  const EarningsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository repository;

  EarningsBloc({required this.repository}) : super(EarningsInitial()) {
    on<EarningsLoadSummaryRequested>(_onLoadSummary);
    on<EarningsLoadTripEarningsRequested>(_onLoadTripEarnings);
  }

  Future<void> _onLoadSummary(EarningsLoadSummaryRequested event, Emitter<EarningsState> emit) async {
    emit(EarningsLoading());
    final result = await repository.getEarningsSummary(period: event.period);
    result.fold(
      (failure) => emit(EarningsError(_mapFailureToMessage(failure))),
      (summary) => emit(EarningsSummaryLoaded(summary)),
    );
  }

  Future<void> _onLoadTripEarnings(EarningsLoadTripEarningsRequested event, Emitter<EarningsState> emit) async {
    emit(EarningsLoading());
    final result = await repository.getTripEarnings(event.tripId);
    result.fold(
      (failure) => emit(EarningsError(_mapFailureToMessage(failure))),
      (earnings) => emit(EarningsTripDetailsLoaded(earnings)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is CacheFailure) return "Cache Error";
    return "Unexpected Error";
  }
}
