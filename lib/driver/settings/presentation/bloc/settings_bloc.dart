import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/driver/settings/domain/entities/driver_settings.dart';
import 'package:komiut_app/driver/settings/domain/repositories/settings_repository.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class SettingsUpdateProfileRequested extends SettingsEvent {
  final Map<String, dynamic> data;
  const SettingsUpdateProfileRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class SettingsToggleThemeRequested extends SettingsEvent {
  final bool isDarkMode;
  const SettingsToggleThemeRequested(this.isDarkMode);
  @override
  List<Object?> get props => [isDarkMode];
}

class SettingsLogoutRequested extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final DriverSettings settings;
  const SettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class SettingsLogoutSuccess extends SettingsState {}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadSettings);
    on<SettingsUpdateProfileRequested>(_onUpdateProfile);
    on<SettingsLogoutRequested>(_onLogout);
    // Theme toggle would ideally update local prefs and emit new settings
  }

  Future<void> _onLoadSettings(SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await repository.getSettings();
    result.fold(
      (failure) => emit(SettingsError(_mapFailureToMessage(failure))),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onUpdateProfile(SettingsUpdateProfileRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await repository.updateProfile(event.data);
    result.fold(
      (failure) => emit(SettingsError(_mapFailureToMessage(failure))),
      (profile) {
        // Here we should ideally reload full settings or copyWith with new profile
        add(SettingsLoadRequested()); 
      },
    );
  }

  Future<void> _onLogout(SettingsLogoutRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await repository.logout();
    result.fold(
      (failure) => emit(SettingsError(_mapFailureToMessage(failure))),
      (_) => emit(SettingsLogoutSuccess()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return "Unexpected Error";
  }
}
