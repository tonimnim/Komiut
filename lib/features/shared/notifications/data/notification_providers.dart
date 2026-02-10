import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../domain/repositories/notification_repository.dart';
import 'datasources/notification_remote_datasource.dart';
import 'repositories/notification_repository_impl.dart';

/// Provider for notification repository.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return NotificationRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});
