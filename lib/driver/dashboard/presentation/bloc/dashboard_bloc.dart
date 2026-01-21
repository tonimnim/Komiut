import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut_app/driver/dashboard/domain/repositories/dashboard_repository.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {}

class DashboardStatusToggled extends DashboardEvent {
  final String newStatus;

  DashboardStatusToggled({required this.newStatus});

  @override
  List<Object?> get props => [newStatus];
}

class DashboardRefreshRequested extends DashboardEvent {}

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DriverProfile profile;
  final Vehicle vehicle;
  final Circle circle;
  final CircleRoute route;
  final EarningsSummary todayEarnings;
  final int currentPassengers;
  final List<AppNotification> notifications;

  DashboardLoaded({
    required this.profile,
    required this.vehicle,
    required this.circle,
    required this.route,
    required this.todayEarnings,
    this.currentPassengers = 0,
    this.notifications = const [],
  });

  @override
  List<Object?> get props => [
        profile,
        vehicle,
        circle,
        route,
        todayEarnings,
        currentPassengers,
        notifications,
      ];

  DashboardLoaded copyWith({
    DriverProfile? profile,
    Vehicle? vehicle,
    Circle? circle,
    CircleRoute? route,
    EarningsSummary? todayEarnings,
    int? currentPassengers,
    List<AppNotification>? notifications,
  }) {
    return DashboardLoaded(
      profile: profile ?? this.profile,
      vehicle: vehicle ?? this.vehicle,
      circle: circle ?? this.circle,
      route: route ?? this.route,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      currentPassengers: currentPassengers ?? this.currentPassengers,
      notifications: notifications ?? this.notifications,
    );
  }
}

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'payment', 'trip', 'system'

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'system',
  });

  @override
  List<Object?> get props => [id, title, message, timestamp, isRead, type];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardBloc({required this.dashboardRepository}) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardStatusToggled>(_onStatusToggled);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        dashboardRepository.getDriverProfile(),
        dashboardRepository.getVehicle(),
        dashboardRepository.getCircle(),
        dashboardRepository.getRoute(),
        dashboardRepository.getTodayEarnings(),
        dashboardRepository.getNotifications(),
        dashboardRepository.getCurrentPassengers(),
      ]);

      final notificationMaps = results[5] as List<Map<String, dynamic>>;
      final notifications = notificationMaps.map((n) {
        return AppNotification(
          id: n['id'] as String,
          title: n['title'] as String,
          message: n['message'] as String,
          timestamp: DateTime.parse(n['timestamp'] as String),
          isRead: n['isRead'] as bool,
          type: n['type'] as String,
        );
      }).toList();

      emit(DashboardLoaded(
        profile: results[0] as DriverProfile,
        vehicle: results[1] as Vehicle,
        circle: results[2] as Circle,
        route: results[3] as CircleRoute,
        todayEarnings: results[4] as EarningsSummary,
        notifications: notifications,
        currentPassengers: results[6] as int,
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onStatusToggled(
    DashboardStatusToggled event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        final newStatus = await dashboardRepository.toggleStatus(event.newStatus);
        final updatedProfile = DriverProfileModel(
          id: currentState.profile.id,
          name: currentState.profile.name,
          phone: currentState.profile.phone,
          email: currentState.profile.email,
          profileImage: currentState.profile.profileImage,
          rating: currentState.profile.rating,
          totalTrips: currentState.profile.totalTrips,
          status: newStatus,
        );
        emit(currentState.copyWith(profile: updatedProfile));
      } catch (e) {
      }
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    add(DashboardLoadRequested());
  }
}

class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.profileImage,
    required super.rating,
    required super.totalTrips,
    required super.status,
  });
}
