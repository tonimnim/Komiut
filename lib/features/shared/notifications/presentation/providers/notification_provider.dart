import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';

enum NotificationFilter { all, unread }

final notificationFilterProvider = StateProvider<NotificationFilter>((ref) {
  return NotificationFilter.all;
});

final notificationsProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<NotificationEntity>>>((ref) {
  return NotificationNotifier();
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
  NotificationNotifier() : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    state = const AsyncValue.loading();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    final mockNotifications = _generateMockNotifications();
    state = AsyncValue.data(mockNotifications);
  }

  List<NotificationEntity> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationEntity(
        id: '1',
        title: 'Trip Completed',
        message:
            'Your trip from Nairobi CBD to Westlands has been completed. Fare: KES 120',
        type: NotificationType.trip,
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      NotificationEntity(
        id: '2',
        title: 'Payment Successful',
        message: 'Your wallet has been topped up with KES 500 via M-Pesa.',
        type: NotificationType.payment,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationEntity(
        id: '3',
        title: 'Weekend Offer!',
        message: 'Get 20% off on all trips this weekend. Use code WEEKEND20.',
        type: NotificationType.promo,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      NotificationEntity(
        id: '4',
        title: 'Trip Completed',
        message:
            'Your trip from Westlands to Karen has been completed. Fare: KES 350',
        type: NotificationType.trip,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationEntity(
        id: '5',
        title: 'Points Earned',
        message: 'You earned 50 points from your last trip. Keep riding!',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      NotificationEntity(
        id: '6',
        title: 'Payment Successful',
        message: 'Your wallet has been topped up with KES 1,000 via Card.',
        type: NotificationType.payment,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationEntity(
        id: '7',
        title: 'New Route Available',
        message: 'We now have a direct route from CBD to JKIA. Try it today!',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      NotificationEntity(
        id: '8',
        title: 'Trip Failed',
        message: 'Your trip payment failed. Please check your wallet balance.',
        type: NotificationType.trip,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }

  void markAsRead(String id) {
    state.whenData((notifications) {
      final updated = notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }

  void markAllAsRead() {
    state.whenData((notifications) {
      final updated =
          notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = AsyncValue.data(updated);
    });
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}
