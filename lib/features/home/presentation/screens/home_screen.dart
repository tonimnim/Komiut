import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../providers/home_providers.dart';
import '../widgets/wallet_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_trips_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final walletAsync = ref.watch(walletProvider);
    final tripsAsync = ref.watch(recentTripsProvider);
    final userName = authState.user?.fullName.split(' ').first ?? 'User';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(recentTripsProvider);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref.read(navigationIndexProvider.notifier).state = 3;
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              image: authState.user?.profileImage != null &&
                                      File(authState.user!.profileImage!).existsSync()
                                  ? DecorationImage(
                                      image: FileImage(File(authState.user!.profileImage!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: authState.user?.profileImage == null ||
                                    !File(authState.user!.profileImage!).existsSync()
                                ? Icon(
                                    Icons.person_outline,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push('/scan');
                          },
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 20),
                        _NotificationBell(isDark: isDark),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                walletAsync.when(
                  data: (wallet) => WalletCard(
                    balance: wallet?.balance ?? 0.0,
                    points: wallet?.points ?? 0,
                    currency: wallet?.currency ?? 'KES',
                  ),
                  loading: () => const WalletCard(
                    balance: 0.0,
                    points: 0,
                    currency: 'KES',
                    isLoading: true,
                  ),
                  error: (_, __) => const WalletCard(
                    balance: 0.0,
                    points: 0,
                    currency: 'KES',
                    hasError: true,
                  ),
                ),
                const SizedBox(height: 24),
                const QuickActions(),
                const SizedBox(height: 24),
              tripsAsync.when(
                data: (trips) => RecentTripsSection(trips: trips),
                loading: () => const RecentTripsSection(trips: [], isLoading: true),
                error: (_, __) => const RecentTripsSection(trips: [], hasError: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends ConsumerWidget {
  final bool isDark;

  const _NotificationBell({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return GestureDetector(
      onTap: () {
        context.push('/notifications');
      },
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              size: 26,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
