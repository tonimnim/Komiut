import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/driver/queue/domain/entities/queue_entities.dart';
import 'package:komiut_app/driver/queue/domain/repositories/queue_repository.dart';

abstract class QueueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class QueueStatusRequested extends QueueEvent {
  final String routeId;
  QueueStatusRequested({required this.routeId});
  @override
  List<Object?> get props => [routeId];
}

class QueueJoinRequested extends QueueEvent {
  final String routeId;
  final double lat;
  final double lng;
  QueueJoinRequested({required this.routeId, required this.lat, required this.lng});
  @override
  List<Object?> get props => [routeId, lat, lng];
}

class QueueLeaveRequested extends QueueEvent {}

class QueuePositionRefreshRequested extends QueueEvent {}

abstract class QueueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {}
class QueueLoading extends QueueState {}

class QueueStatusLoaded extends QueueState {
  final QueueStatus status;
  QueueStatusLoaded({required this.status});
  @override
  List<Object?> get props => [status];
}

class QueueJoined extends QueueState {
  final QueuePosition position;
  QueueJoined({required this.position});
  @override
  List<Object?> get props => [position];
}

class QueueLeft extends QueueState {}

class QueueError extends QueueState {
  final String message;
  QueueError({required this.message});
  @override
  List<Object?> get props => [message];
}

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository queueRepository;

  QueueBloc({required this.queueRepository}) : super(QueueInitial()) {
    on<QueueStatusRequested>(_onStatusRequested);
    on<QueueJoinRequested>(_onJoinRequested);
    on<QueueLeaveRequested>(_onLeaveRequested);
    on<QueuePositionRefreshRequested>(_onPositionRefresh);
  }

  Future<void> _onStatusRequested(QueueStatusRequested event, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    final result = await queueRepository.getQueueStatus(event.routeId);
    result.fold(
      (failure) => emit(QueueError(message: _mapFailureToMessage(failure))),
      (status) => emit(QueueStatusLoaded(status: status)),
    );
  }

  Future<void> _onJoinRequested(QueueJoinRequested event, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    final result = await queueRepository.joinQueue(event.routeId, event.lat, event.lng);
    result.fold(
      (failure) => emit(QueueError(message: _mapFailureToMessage(failure))),
      (position) => emit(QueueJoined(position: position)),
    );
  }

  Future<void> _onLeaveRequested(QueueLeaveRequested event, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    final result = await queueRepository.leaveQueue();
    result.fold(
      (failure) => emit(QueueError(message: _mapFailureToMessage(failure))),
      (_) => emit(QueueLeft()),
    );
  }

  Future<void> _onPositionRefresh(QueuePositionRefreshRequested event, Emitter<QueueState> emit) async {
    final result = await queueRepository.getQueuePosition();
    result.fold(
      (failure) => null, // Silently fail or keep current state
      (position) => emit(QueueJoined(position: position)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return "Unexpected error occurred";
  }
}
