/// Driver notification screen.
///
/// Shows driver-specific notifications like queue updates, trip assignments,
/// and earnings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/error_widget.dart';
import '../../../../../features/shared/notifications/domain/entities/notification_entity.dart';
import '../../../../../features/shared/notifications/presentation/providers/notification_provider.dart';
import '../../../../../features/shared/notifications/presentation/widgets/notification_tile.dart';

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

  @override
  void initState() {
    super.initState();
    // Refresh notifications when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).refresh();
    });
  }

  List<NotificationEntity> _filterNotifications(
      List<NotificationEntity> notifications) {
    if (_selectedTab == 0) return notifications;
    return notifications.where((n) => !n.isRead).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark, unreadCount),

            // Tab bar
            _buildTabBar(isDark, unreadCount),

            // Notification list
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, __) => CustomErrorWidget(
                  message: error.toString(),
                  onRetry: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                ),
                data: (notifications) {
                  final filtered = _filterNotifications(notifications);
                  if (filtered.isEmpty) {
                    return _buildEmptyState(isDark);
                  }
                  return _buildNotificationList(filtered, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, int unreadCount) {
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
          if (unreadCount > 0)
            GestureDetector(
              onTap: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text(
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

  Widget _buildTabBar(bool isDark, int unreadCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: isDark ? const Color(0xFF111111) : Colors.white,
      child: Row(
        children: [
          _buildTabItem('All', 0, isDark),
          const SizedBox(width: 24),
          _buildTabItem('Unread', 1, isDark, count: unreadCount),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            _selectedTab == 0
                ? 'No notifications yet'
                : 'No unread notifications',
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

  Widget _buildNotificationList(
      List<NotificationEntity> notifications, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isLast = index == notifications.length - 1;

        return NotificationTile(
          notification: notification,
          showDivider: !isLast,
          onTap: () {
            if (!notification.isRead) {
              ref
                  .read(notificationsProvider.notifier)
                  .markAsRead(notification.id);
            }
          },
        );
      },
    );
  }
}
