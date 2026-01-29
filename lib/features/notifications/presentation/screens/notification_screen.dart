import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(notificationFilterProvider) == NotificationFilter.all ? 0 : 1;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(notificationFilterProvider.notifier).state =
        index == 0 ? NotificationFilter.all : NotificationFilter.unread;
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: const [
          _MarkAllReadButton(),
        ],
      ),
      body: Column(
        children: [
          // Tab bar - separate widget to isolate rebuilds
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TabBar(
              onTabTapped: _onTabTapped,
            ),
          ),

          // Page view for swipe
          Expanded(
            child: _NotificationPageView(
              pageController: _pageController,
              onPageChanged: _onPageChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget - only rebuilds when unreadCount changes
class _MarkAllReadButton extends ConsumerWidget {
  const _MarkAllReadButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: () {
        ref.read(notificationsProvider.notifier).markAllAsRead();
      },
      child: const Text(
        'Mark all read',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Separate widget - only rebuilds when filter or unreadCount changes
class _TabBar extends ConsumerWidget {
  final void Function(int) onTabTapped;

  const _TabBar({required this.onTabTapped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationFilterProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Row(
      children: [
        _TabItem(
          label: 'All',
          isSelected: filter == NotificationFilter.all,
          onTap: () => onTabTapped(0),
        ),
        const SizedBox(width: 24),
        _TabItem(
          label: 'Unread',
          count: unreadCount,
          isSelected: filter == NotificationFilter.unread,
          onTap: () => onTabTapped(1),
        ),
      ],
    );
  }
}

// Separate widget - only rebuilds when notifications data changes
class _NotificationPageView extends ConsumerWidget {
  final PageController pageController;
  final void Function(int) onPageChanged;

  const _NotificationPageView({
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return notificationsAsync.when(
      data: (allNotifications) {
        final unreadNotifications =
            allNotifications.where((n) => !n.isRead).toList();

        return PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: [
            _NotificationList(
              notifications: allNotifications,
              onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
              onMarkAsRead: (id) =>
                  ref.read(notificationsProvider.notifier).markAsRead(id),
              emptyMessage: 'No notifications yet',
            ),
            _NotificationList(
              notifications: unreadNotifications,
              onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
              onMarkAsRead: (id) =>
                  ref.read(notificationsProvider.notifier).markAsRead(id),
              emptyMessage: 'No unread notifications',
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).refresh();
              },
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                if (count != null && count! > 0) ...[
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
}

class _NotificationList extends StatelessWidget {
  final List<NotificationEntity> notifications;
  final Future<void> Function() onRefresh;
  final void Function(String id) onMarkAsRead;
  final String emptyMessage;

  const _NotificationList({
    required this.notifications,
    required this.onRefresh,
    required this.onMarkAsRead,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (notifications.isEmpty) {
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
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isLast = index == notifications.length - 1;
          return NotificationTile(
            notification: notification,
            showDivider: !isLast,
            onTap: () {
              if (!notification.isRead) {
                onMarkAsRead(notification.id);
              }
            },
          );
        },
      ),
    );
  }
}
