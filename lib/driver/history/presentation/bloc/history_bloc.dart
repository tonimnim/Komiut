import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/driver/history/domain/entities/trip_history.dart';
import 'package:komiut_app/driver/history/domain/entities/trip_history_details.dart';
import 'package:komiut_app/driver/history/domain/repositories/history_repository.dart';

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  final int page;
  final DateTime? startDate;
  final DateTime? endDate;

  const HistoryLoadRequested({this.page = 1, this.startDate, this.endDate});
  @override
  List<Object?> get props => [page, startDate, endDate];
}

class HistoryLoadDetailsRequested extends HistoryEvent {
  final String tripId;
  const HistoryLoadDetailsRequested(this.tripId);
  @override
  List<Object?> get props => [tripId];
}

// States
abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<TripHistory> trips;
  final bool hasReachedMax;

  const HistoryLoaded({required this.trips, this.hasReachedMax = false});
  @override
  List<Object?> get props => [trips, hasReachedMax];
}

class HistoryDetailsLoaded extends HistoryState {
  final TripHistoryDetails details;
  const HistoryDetailsLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository repository;

  HistoryBloc({required this.repository}) : super(HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadHistory);
    on<HistoryLoadDetailsRequested>(_onLoadDetails);
  }

  Future<void> _onLoadHistory(HistoryLoadRequested event, Emitter<HistoryState> emit) async {
    if (state is! HistoryLoaded || event.page == 1) {
      emit(HistoryLoading());
    }
    
    final result = await repository.getTripHistory(
      page: event.page,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(HistoryError(_mapFailureToMessage(failure))),
      (trips) => emit(HistoryLoaded(
        trips: trips, 
        hasReachedMax: trips.isEmpty, // Simple logic, can be improved with pagination metadata
      )),
    );
  }

  Future<void> _onLoadDetails(HistoryLoadDetailsRequested event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    final result = await repository.getTripHistoryDetails(event.tripId);
    result.fold(
      (failure) => emit(HistoryError(_mapFailureToMessage(failure))),
      (details) => emit(HistoryDetailsLoaded(details)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return "Unexpected Error";
  }
}
