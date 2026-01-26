import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/driver/dashboard/presentation/widgets/dashboard_widgets.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/core/routes/route_names.dart';
import 'package:komiut/driver/queue/presentation/screens/driver_queue_screen.dart';
import 'package:komiut/driver/queue/presentation/screens/join_queue_screen.dart';
import 'package:komiut/driver/earnings/presentation/screens/earnings_screen.dart';
import 'package:komiut/driver/settings/presentation/screens/profile_screen.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/driver/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:komiut/di/injection_container.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _currentIndex = 0;
  DriverProfile? _profile;
  Vehicle? _vehicle;
  CircleRoute? _route;
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repository = getIt<DashboardRepository>();
      final profile = await repository.getDriverProfile();
      final vehicle = await repository.getVehicle();
      final route = await repository.getRoute();
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => n['isRead'] == false).length;
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _vehicle = vehicle;
          _route = route;
          _unreadCount = unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = [
      _HomeTab(
        profile: _profile,
        vehicle: _vehicle,
        route: _route,
        unreadCount: _unreadCount,
        onStatusChanged: (isOnline) {
          setState(() {
            _profile = _profile?.copyWith(status: isOnline ? 1 : 0);
          });
        },
      ),
      JoinQueueScreen(profile: _profile),
      EarningsScreen(isTab: true, profile: _profile),
      ProfileScreen(profile: _profile, vehicle: _vehicle),
    ];

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: DashboardColors.progressGrey, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: DashboardColors.primary,
        unselectedItemColor: DashboardColors.textGrey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.home_filled, size: 28),
            ),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.list_alt_rounded, size: 28),
            ),
            label: 'QUEUE',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.account_balance_wallet_outlined, size: 28),
            ),
            label: 'EARNINGS',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.person_outline_rounded, size: 28),
            ),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final DriverProfile? profile;
  final Vehicle? vehicle;
  final CircleRoute? route;
  final int unreadCount;
  final Function(bool)? onStatusChanged;

  const _HomeTab({
    this.profile,
    this.vehicle,
    this.route,
    required this.unreadCount,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                AssignedSaccoCard(route: route),
                const SizedBox(height: 16),
                VehicleCapacityCard(vehicle: vehicle),
                const SizedBox(height: 20),
                DashboardActionButtons(route: route),
                const SizedBox(height: 20),
                const DashboardStatsGrid(),
                const SizedBox(height: 20),
                UpcomingRouteCard(route: route),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionBtn(context, 'View Queue', Icons.queue_play_next_rounded, 1),
        const SizedBox(width: 12),
        _buildActionBtn(context, 'History', Icons.history_rounded, null, isHistory: true),
        const SizedBox(width: 12),
        _buildActionBtn(context, 'More', Icons.more_horiz_rounded, 3),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, int? tabIndex, {bool isHistory = false}) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            if (isHistory) {
              context.push(RouteNames.tripHistory, extra: profile);
            } else if (tabIndex != null) {
              final dashboardState = context.findAncestorStateOfType<_DriverDashboardScreenState>();
              dashboardState?.setState(() {
                dashboardState._currentIndex = tabIndex;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey100),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 24),
                const SizedBox(height: 8),
                Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isOnline = profile?.status == 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryBlue,
                backgroundImage: profile?.imageUrl != null ? NetworkImage(profile!.imageUrl!) : null,
                child: profile?.imageUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Driver Dashboard', style: AppTextStyles.heading4.copyWith(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(
                      'ON DUTY • LIVE',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              _buildNotificationBell(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNotifications(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey100),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.notifications_rounded, color: AppColors.textPrimary, size: 24),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionHeaderItem(context, 'View Queue', Icons.queue_play_next_rounded, 1),
        _buildActionHeaderItem(context, 'History', Icons.history_rounded, null, isHistory: true),
        _buildActionHeaderItem(context, 'Profile', Icons.settings_rounded, 3),
      ],
    );
  }

  Widget _buildActionHeaderItem(BuildContext context, String label, IconData icon, int? tabIndex, {bool isHistory = false}) {
    return InkWell(
      onTap: () {
        if (isHistory) {
          context.push(RouteNames.tripHistory, extra: profile);
        } else if (tabIndex != null) {
          final dashboardState = context.findAncestorStateOfType<_DriverDashboardScreenState>();
          dashboardState?.setState(() {
            dashboardState._currentIndex = tabIndex;
          });
        }
      },
      child: Column(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.overline.copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) async {
    final repository = getIt<DashboardRepository>();
    final notifications = await repository.getNotifications();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DefaultTabController(
        length: 2,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications', style: AppTextStyles.heading3),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close', style: TextStyle(color: AppColors.primaryBlue)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  indicatorColor: AppColors.primaryBlue,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'UNREAD'),
                    Tab(text: 'ALL'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildNotificationList(notifications.where((n) => n['isRead'] == false).toList()),
                    _buildNotificationList(notifications),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.grey200),
            const SizedBox(height: 16),
            Text('No notifications', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.grey100),
      itemBuilder: (context, index) {
        final n = items[index];
        IconData icon;
        Color iconColor;
        switch (n['type']) {
          case 'payment':
            icon = Icons.payments_rounded;
            iconColor = AppColors.primaryGreen;
            break;
          case 'stage':
            icon = Icons.location_on_rounded;
            iconColor = AppColors.primaryBlue;
            break;
          case 'status':
            icon = Icons.info_rounded;
            iconColor = Colors.orange;
            break;
          default:
            icon = Icons.notifications_rounded;
            iconColor = AppColors.primaryBlue;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showNotificationDetail(context, n),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(n['title'] ?? 'Notification', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                              if (n['isRead'] == false)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(n['message'] ?? '', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(n['time'] ?? '', style: AppTextStyles.overline.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNotificationDetail(BuildContext context, Map<String, dynamic> n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(n['title'] ?? 'Detail', style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(n['time'] ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Text(n['message'] ?? '', style: AppTextStyles.body1.copyWith(height: 1.5)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('GOT IT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
