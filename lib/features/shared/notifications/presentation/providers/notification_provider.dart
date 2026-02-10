import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/notification_providers.dart';

enum NotificationFilter { all, unread }

final notificationFilterProvider = StateProvider<NotificationFilter>((ref) {
  return NotificationFilter.all;
});

final notificationsProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<NotificationEntity>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    state = const AsyncValue.loading();
    final result = await _repository.getNotifications();

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (notifications) => AsyncValue.data(notifications),
    );
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final currentState = state.value;
    if (currentState != null) {
      final updated = currentState.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      state = AsyncValue.data(updated);
    }

    final result = await _repository.markAsRead(id);
    result.fold(
      (failure) {
        // Revert on failure if needed, or just reload
        _loadNotifications();
      },
      (_) => null,
    );
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    final currentState = state.value;
    if (currentState != null) {
      final updated =
          currentState.map((n) => n.copyWith(isRead: true)).toList();
      state = AsyncValue.data(updated);
    }

    final result = await _repository.markAllAsRead();
    result.fold(
      (failure) {
        _loadNotifications();
      },
      (_) => null,
    );
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}
