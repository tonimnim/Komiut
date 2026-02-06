import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:komiut/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:komiut/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:komiut/shared/auth/data/repositories/auth_repository_impl.dart';
import 'package:komiut/shared/auth/domain/repositories/auth_repository.dart';
import 'package:komiut/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:komiut/core/theme/theme_bloc.dart';

// TODO(Phase 2-4): Re-add driver feature dependencies once implemented
// The old driver BLoCs and repositories were removed during Phase 1 refactoring.
// New driver features will use Riverpod providers instead of BLoC.

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  debugPrint('DI: Starting initializeDependencies');
  final sharedPreferences = await SharedPreferences.getInstance();
  debugPrint('DI: SharedPreferences loaded');
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  debugPrint('DI: Storage registered');

  getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(Connectivity()));
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      storage: getIt<FlutterSecureStorage>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
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

  getIt.registerLazySingleton<ThemeBloc>(() => ThemeBloc(getIt()));
}
