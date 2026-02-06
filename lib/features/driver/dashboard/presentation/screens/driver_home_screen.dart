/// Driver home screen.
///
/// Clean, state-driven dashboard that shows what the driver needs to know
/// and what actions they can take right now.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/navigation/driver_main_navigation.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/notifications/presentation/providers/notification_provider.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../queue/presentation/providers/queue_providers.dart';
import '../../../trips/presentation/providers/trips_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/driver_activity_content.dart';

/// Driver home screen entry point.
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverMainNavigation();
  }
}

/// Driver home content (used in IndexedStack).
class DriverHomeContent extends ConsumerWidget {
  const DriverHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(driverProfileProvider);
          ref.invalidate(driverQueuePositionProvider);
          ref.invalidate(activeTripProvider);
          ref.invalidate(earningsSummaryProvider);
        },
        child: const SingleChildScrollView(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              _DriverHeader(),
              SizedBox(height: 24),

              // ── State-Driven Content ────────────────────────────────
              DriverActivityContent(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Components
// ─────────────────────────────────────────────────────────────────────────────

/// Driver header with avatar, greeting, status, and action icons.
///
/// Extracted as a separate widget to minimize rebuilds when only
/// specific parts of the header change.
class _DriverHeader extends ConsumerWidget {
  const _DriverHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile + Greeting + Status
        Expanded(
          child: Row(
            children: [
              _ProfileAvatar(),
              SizedBox(width: 12),
              Expanded(child: _GreetingAndStatus()),
            ],
          ),
        ),

        // Action Icons
        _HeaderActions(),
      ],
    );
  }
}

/// Profile avatar that opens drawer on tap.
class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileImage = ref.watch(
      authStateProvider.select((state) => state.user?.profileImage),
    );

    final hasValidImage =
        profileImage != null && File(profileImage).existsSync();

    return GestureDetector(
      onTap: () => driverScaffoldKey.currentState?.openDrawer(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          image: hasValidImage
              ? DecorationImage(
                  image: FileImage(File(profileImage)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasValidImage
            ? null
            : Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
              ),
      ),
    );
  }
}

/// Driver name and online status indicator.
class _GreetingAndStatus extends ConsumerWidget {
  const _GreetingAndStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Only rebuild when user name changes
    final userName = ref.watch(
      authStateProvider.select(
        (state) => state.user?.fullName.split(' ').first ?? 'Captain',
      ),
    );

    // Only rebuild when online status changes
    final isOnline = ref.watch(
      driverProfileProvider.select(
        (async) => async.whenOrNull(data: (p) => p.isOnline) ?? false,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        _OnlineStatusIndicator(isOnline: isOnline, isDark: isDark),
      ],
    );
  }
}

/// Online/offline status indicator.
class _OnlineStatusIndicator extends StatelessWidget {
  const _OnlineStatusIndicator({
    required this.isOnline,
    required this.isDark,
  });

  final bool isOnline;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? AppColors.statusOnline : AppColors.statusOffline;
    final statusText = isOnline ? 'Online' : 'Offline';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Settings and notification action icons.
class _HeaderActions extends StatelessWidget {
  const _HeaderActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _NotificationButton(isDark: isDark);
  }
}

/// Notification button with badge.
class _NotificationButton extends ConsumerWidget {
  const _NotificationButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return GestureDetector(
      onTap: () => context.push(RouteConstants.sharedNotifications),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              size: 22,
            ),
            if (unreadCount > 0)
              const Positioned(
                right: 8,
                top: 8,
                child: _NotificationBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Notification badge indicator.
class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
    );
  }
}
