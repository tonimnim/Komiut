import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/driver/trip/domain/entities/trip.dart';
import 'package:komiut_app/driver/trip/domain/repositories/trip_repository.dart';

abstract class TripEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TripStartRequested extends TripEvent {
  final String routeId;
  final String vehicleId;
  TripStartRequested({required this.routeId, required this.vehicleId});
  @override
  List<Object?> get props => [routeId, vehicleId];
}

class TripEndRequested extends TripEvent {
  final String tripId;
  final int finalPassengers;
  final double finalEarnings;

  TripEndRequested({
    required this.tripId,
    required this.finalPassengers,
    required this.finalEarnings,
  });
  
  @override
  List<Object?> get props => [tripId, finalPassengers, finalEarnings];
}

class TripUpdateStatusRequested extends TripEvent {
  final String tripId;
  final TripStatus status;
  final Map<String, dynamic>? data;

  TripUpdateStatusRequested({required this.tripId, required this.status, this.data});

  @override
  List<Object?> get props => [tripId, status, data];
}

class TripDetailsRequested extends TripEvent {
  final String tripId;
  TripDetailsRequested({required this.tripId});
  @override
  List<Object?> get props => [tripId];
}

class TripCurrentRequested extends TripEvent {}

abstract class TripState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}
class TripLoading extends TripState {}

class TripActive extends TripState {
  final Trip trip;
  TripActive({required this.trip});
  @override
  List<Object?> get props => [trip];
}

class TripDetailsLoaded extends TripState {
  final Trip trip;
  TripDetailsLoaded({required this.trip});
  @override
  List<Object?> get props => [trip];
}

class TripEnded extends TripState {
  final Trip trip;
  TripEnded({required this.trip});
  @override
  List<Object?> get props => [trip];
}

class TripError extends TripState {
  final String message;
  TripError({required this.message});
  @override
  List<Object?> get props => [message];
}

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;

  TripBloc({required this.tripRepository}) : super(TripInitial()) {
    on<TripStartRequested>(_onStartRequested);
    on<TripEndRequested>(_onEndRequested);
    on<TripUpdateStatusRequested>(_onUpdateStatusRequested);
    on<TripDetailsRequested>(_onDetailsRequested);
    on<TripCurrentRequested>(_onCurrentRequested);
  }

  Future<void> _onStartRequested(TripStartRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await tripRepository.startTrip(event.routeId, event.vehicleId);
    result.fold(
      (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
      (trip) => emit(TripActive(trip: trip)),
    );
  }

  Future<void> _onEndRequested(TripEndRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await tripRepository.endTrip(
      event.tripId, 
      finalPassengers: event.finalPassengers, 
      finalEarnings: event.finalEarnings,
    );
    result.fold(
      (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
      (trip) => emit(TripEnded(trip: trip)),
    );
  }

  Future<void> _onUpdateStatusRequested(TripUpdateStatusRequested event, Emitter<TripState> emit) async {
    final result = await tripRepository.updateTripStatus(event.tripId, event.status, data: event.data);
    result.fold(
      (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
      (trip) => emit(TripActive(trip: trip)),
    );
  }

  Future<void> _onDetailsRequested(TripDetailsRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await tripRepository.getTripById(event.tripId);
    result.fold(
      (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
      (trip) => emit(TripDetailsLoaded(trip: trip)),
    );
  }

  Future<void> _onCurrentRequested(TripCurrentRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await tripRepository.getActiveTrip();
    result.fold(
      (failure) => emit(TripInitial()), 
      (trip) => emit(TripActive(trip: trip)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is CacheFailure) return "No active trip found";
    return "Unexpected Error";
  }
}

