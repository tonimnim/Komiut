import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/network/network_info.dart';
import 'package:komiut_app/core/config/app_config.dart';

import 'package:komiut_app/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:komiut_app/shared/auth/data/datasources/auth_mock_datasource.dart';
import 'package:komiut_app/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:komiut_app/shared/auth/data/repositories/auth_repository_impl.dart';
import 'package:komiut_app/shared/auth/domain/repositories/auth_repository.dart';
import 'package:komiut_app/shared/auth/presentation/bloc/auth_bloc.dart';

import 'package:komiut_app/driver/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:komiut_app/driver/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:komiut_app/driver/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:komiut_app/driver/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:komiut_app/driver/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'package:komiut_app/driver/queue/data/datasources/queue_remote_datasource.dart';
import 'package:komiut_app/driver/queue/data/datasources/queue_mock_datasource.dart';
import 'package:komiut_app/driver/queue/data/repositories/queue_repository_impl.dart';
import 'package:komiut_app/driver/queue/domain/repositories/queue_repository.dart';
import 'package:komiut_app/driver/queue/presentation/bloc/queue_bloc.dart';

import 'package:komiut_app/driver/trip/data/datasources/trip_remote_datasource.dart';
import 'package:komiut_app/driver/trip/data/datasources/trip_mock_datasource.dart';
import 'package:komiut_app/driver/trip/data/repositories/trip_repository_impl.dart';
import 'package:komiut_app/driver/trip/domain/repositories/trip_repository.dart';
import 'package:komiut_app/driver/trip/presentation/bloc/trip_bloc.dart';

import 'package:komiut_app/driver/earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:komiut_app/driver/earnings/data/datasources/earnings_mock_datasource.dart';
import 'package:komiut_app/driver/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:komiut_app/driver/earnings/domain/repositories/earnings_repository.dart';
import 'package:komiut_app/driver/earnings/presentation/bloc/earnings_bloc.dart';

import 'package:komiut_app/driver/history/data/datasources/history_remote_datasource.dart';
import 'package:komiut_app/driver/history/data/datasources/history_mock_datasource.dart';
import 'package:komiut_app/driver/history/data/repositories/history_repository_impl.dart';
import 'package:komiut_app/driver/history/domain/repositories/history_repository.dart';
import 'package:komiut_app/driver/history/presentation/bloc/history_bloc.dart';

import 'package:komiut_app/driver/settings/data/datasources/settings_remote_datasource.dart';
import 'package:komiut_app/driver/settings/data/datasources/settings_mock_datasource.dart';
import 'package:komiut_app/driver/settings/data/repositories/settings_repository_impl.dart';
import 'package:komiut_app/driver/settings/domain/repositories/settings_repository.dart';
import 'package:komiut_app/driver/settings/presentation/bloc/settings_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  getIt.registerSingleton<ApiClient>(ApiClient(storage: getIt()));
  getIt.registerSingleton<NetworkInfo>(NetworkInfo());

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
  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(dashboardRepository: getIt()),
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
  getIt.registerFactory<QueueBloc>(
    () => QueueBloc(queueRepository: getIt()),
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
  getIt.registerFactory<TripBloc>(
    () => TripBloc(tripRepository: getIt()),
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
  getIt.registerFactory<EarningsBloc>(
    () => EarningsBloc(repository: getIt()),
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
  getIt.registerFactory<HistoryBloc>(
    () => HistoryBloc(repository: getIt()),
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
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(repository: getIt()),
  );
}
