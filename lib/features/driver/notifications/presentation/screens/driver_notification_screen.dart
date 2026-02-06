/// Driver notification screen.
///
/// Shows driver-specific notifications like queue updates, trip assignments,
/// and earnings. Uses mocked data for now.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';

/// Driver notification types.
enum DriverNotificationType {
  queueUpdate,
  tripAssignment,
  earnings,
  system,
}

/// Driver notification entity.
class DriverNotification {
  final String id;
  final String title;
  final String message;
  final DriverNotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const DriverNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

/// Mock notifications for demo.
final _mockNotifications = [
  DriverNotification(
    id: '1',
    title: "You're up next!",
    message: 'Position #1 in Nairobi CBD - Westlands queue. Start boarding passengers.',
    type: DriverNotificationType.queueUpdate,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    isRead: false,
  ),
  DriverNotification(
    id: '2',
    title: 'Trip completed',
    message: 'You earned KES 850 from your last trip. Great job!',
    type: DriverNotificationType.earnings,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: false,
  ),
  DriverNotification(
    id: '3',
    title: 'Queue position updated',
    message: 'You moved to position #3 in Nairobi CBD - Westlands queue.',
    type: DriverNotificationType.queueUpdate,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
  ),
  DriverNotification(
    id: '4',
    title: 'Daily earnings summary',
    message: 'You completed 8 trips today and earned KES 4,200. Keep it up!',
    type: DriverNotificationType.earnings,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: true,
  ),
  DriverNotification(
    id: '5',
    title: 'New route available',
    message: 'A new route Nairobi CBD - Karen has been added to your sacco.',
    type: DriverNotificationType.system,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  DriverNotification(
    id: '6',
    title: 'Trip assigned',
    message: 'You have been assigned to route Westlands - Kilimani. Check details.',
    type: DriverNotificationType.tripAssignment,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    isRead: true,
  ),
];

/// Driver notification screen.
class DriverNotificationScreen extends ConsumerStatefulWidget {
  const DriverNotificationScreen({super.key});

  @override
  ConsumerState<DriverNotificationScreen> createState() =>
      _DriverNotificationScreenState();
}

class _DriverNotificationScreenState
    extends ConsumerState<DriverNotificationScreen> {
  int _selectedTab = 0;
  late List<DriverNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_mockNotifications);
  }

  List<DriverNotification> get _filteredNotifications {
    if (_selectedTab == 0) return _notifications;
    return _notifications.where((n) => !n.isRead).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = DriverNotification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          createdAt: notification.createdAt,
          isRead: true,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => DriverNotification(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                createdAt: n.createdAt,
                isRead: true,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            // Tab bar
            _buildTabBar(isDark),

            // Notification list
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildNotificationList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: isDark ? const Color(0xFF111111) : Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: isDark ? const Color(0xFF111111) : Colors.white,
      child: Row(
        children: [
          _buildTabItem('All', 0, isDark),
          const SizedBox(width: 24),
          _buildTabItem('Unread', 1, isDark, count: _unreadCount),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, bool isDark, {int? count}) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : (isDark ? Colors.grey[400] : AppColors.textSecondary),
                  ),
                ),
                if (count != null && count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 40 : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 0 ? 'No notifications yet' : 'No unread notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        final isLast = index == _filteredNotifications.length - 1;

        return _DriverNotificationTile(
          notification: notification,
          isDark: isDark,
          showDivider: !isLast,
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification.id);
            }
          },
        );
      },
    );
  }
}

class _DriverNotificationTile extends StatelessWidget {
  const _DriverNotificationTile({
    required this.notification,
    required this.isDark,
    required this.showDivider,
    required this.onTap,
  });

  final DriverNotification notification;
  final bool isDark;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getIconColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconData(),
                color: _getIconColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[600] : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (notification.type) {
      case DriverNotificationType.queueUpdate:
        return Icons.format_list_numbered_rounded;
      case DriverNotificationType.tripAssignment:
        return Icons.directions_bus_rounded;
      case DriverNotificationType.earnings:
        return Icons.account_balance_wallet_rounded;
      case DriverNotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case DriverNotificationType.queueUpdate:
        return AppColors.primaryBlue;
      case DriverNotificationType.tripAssignment:
        return AppColors.primaryGreen;
      case DriverNotificationType.earnings:
        return Colors.orange;
      case DriverNotificationType.system:
        return Colors.purple;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
