import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/network/network_info.dart';
import 'package:komiut/core/config/app_config.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:komiut/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:komiut/shared/auth/data/datasources/auth_mock_datasource.dart';
import 'package:komiut/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:komiut/shared/auth/data/repositories/auth_repository_impl.dart';
import 'package:komiut/shared/auth/domain/repositories/auth_repository.dart';
import 'package:komiut/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:komiut/driver/earnings/presentation/bloc/earnings_bloc.dart';
import 'package:komiut/core/theme/theme_bloc.dart';

import 'package:komiut/driver/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:komiut/driver/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:komiut/driver/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:komiut/driver/dashboard/domain/repositories/dashboard_repository.dart';

import 'package:komiut/driver/queue/data/datasources/queue_remote_datasource.dart';
import 'package:komiut/driver/queue/data/datasources/queue_mock_datasource.dart';
import 'package:komiut/driver/queue/data/repositories/queue_repository_impl.dart';
import 'package:komiut/driver/queue/domain/repositories/queue_repository.dart';

import 'package:komiut/driver/trip/data/datasources/trip_remote_datasource.dart';
import 'package:komiut/driver/trip/data/datasources/trip_mock_datasource.dart';
import 'package:komiut/driver/trip/data/repositories/trip_repository_impl.dart';
import 'package:komiut/driver/trip/domain/repositories/trip_repository.dart';

import 'package:komiut/driver/earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:komiut/driver/earnings/data/datasources/earnings_mock_datasource.dart';
import 'package:komiut/driver/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:komiut/driver/earnings/domain/repositories/earnings_repository.dart';

import 'package:komiut/driver/history/data/datasources/history_remote_datasource.dart';
import 'package:komiut/driver/history/data/datasources/history_mock_datasource.dart';
import 'package:komiut/driver/history/data/repositories/history_repository_impl.dart';
import 'package:komiut/driver/history/domain/repositories/history_repository.dart';

import 'package:komiut/driver/settings/data/datasources/settings_remote_datasource.dart';
import 'package:komiut/driver/settings/data/datasources/settings_mock_datasource.dart';
import 'package:komiut/driver/settings/data/repositories/settings_repository_impl.dart';
import 'package:komiut/driver/settings/domain/repositories/settings_repository.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  debugPrint('DI: Starting initializeDependencies');
  final sharedPreferences = await SharedPreferences.getInstance();
  debugPrint('DI: SharedPreferences loaded');
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  debugPrint('DI: Storage registered');

  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(Connectivity()));
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      storage: getIt<FlutterSecureStorage>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Auth
  if (AppConfig.enableMockData) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthMockDataSource(),
    );
  } else {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
    );
  }
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt()),
  );

  // Dashboard
  if (AppConfig.enableMockData) {
    getIt.registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardMockDataSource(),
    );
  } else {
    getIt.registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(getIt()),
    );
  }
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Queue
  if (AppConfig.enableMockData) {
    getIt.registerLazySingleton<QueueRemoteDataSource>(
      () => QueueMockDataSource(),
    );
  } else {
    getIt.registerLazySingleton<QueueRemoteDataSource>(
      () => QueueRemoteDataSourceImpl(getIt()),
    );
  }
  getIt.registerLazySingleton<QueueRepository>(
    () => QueueRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  // Trip
  if (AppConfig.enableMockData) {
    getIt.registerLazySingleton<TripRemoteDataSource>(
      () => TripMockDataSource(),
    );
  } else {
    getIt.registerLazySingleton<TripRemoteDataSource>(
      () => TripRemoteDataSourceImpl(getIt()),
    );
  }
  getIt.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(getIt()),
  );

  // Earnings
  if (AppConfig.enableMockData) {
    getIt.registerLazySingleton<EarningsRemoteDataSource>(
      () => EarningsMockDataSource(),
    );
  } else {
    getIt.registerLazySingleton<EarningsRemoteDataSource>(
      () => EarningsRemoteDataSourceImpl(getIt()),
    );
  }
  getIt.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(getIt()),
  );

  // History
  if (AppConfig.enableMockData) {
    getIt.registerLazySingleton<HistoryRemoteDataSource>(
      () => HistoryMockDataSource(),
    );
  } else {
    getIt.registerLazySingleton<HistoryRemoteDataSource>(
      () => HistoryRemoteDataSourceImpl(getIt()),
    );
  }
  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(getIt()),
  );

  // Settings
  if (AppConfig.enableMockData) {
    getIt.registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsMockDataSource(),
    );
  } else {
    getIt.registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsRemoteDataSourceImpl(getIt()),
    );
  }
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<ThemeBloc>(() => ThemeBloc(getIt()));

  getIt.registerFactory<EarningsBloc>(
    () => EarningsBloc(
      earningsRepository: getIt(),
      historyRepository: getIt(),
    ),
  );
}
