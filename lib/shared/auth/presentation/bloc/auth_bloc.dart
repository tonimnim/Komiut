import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:komiut_app/shared/auth/domain/entities/user.dart';
import 'package:komiut_app/shared/auth/domain/repositories/auth_repository.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String phone;
  final String? password;

  AuthLoginRequested({required this.phone, this.password});

  @override
  List<Object?> get props => [phone, password];
}

class AuthOtpVerifyRequested extends AuthEvent {
  final String verificationId;
  final String otp;

  AuthOtpVerifyRequested({required this.verificationId, required this.otp});

  @override
  List<Object?> get props => [verificationId, otp];
}

class AuthLogoutRequested extends AuthEvent {}

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String verificationId;

  AuthOtpSent({required this.verificationId});

  @override
  List<Object?> get props => [verificationId];
}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final verificationId = await authRepository.login(event.phone, event.password);
      emit(AuthOtpSent(verificationId: verificationId));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.verifyOtp(event.verificationId, event.otp);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
