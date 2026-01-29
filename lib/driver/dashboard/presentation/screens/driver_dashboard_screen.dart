import 'dart:ui';
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
import 'package:komiut/driver/queue/domain/repositories/queue_repository.dart';
import 'package:komiut/driver/queue/domain/entities/queue_entities.dart';
import 'package:komiut/di/injection_container.dart';
import '../../../../core/widgets/feedback/offline_banner.dart';
import '../../../../core/widgets/buttons/app_button.dart';

class DriverDashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DriverDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  late int _currentIndex;
  DriverProfile? _profile;
  Vehicle? _vehicle;
  CircleRoute? _route;
  EarningsSummary? _earnings;
  int _currentPax = 0;
  int _unreadCount = 0;
  bool _isLoading = true;
  bool _isInQueue = false;
  QueuePosition? _queuePosition;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadData();
  }

  Future<void> _loadData() async {
    try {

      final repository = getIt<DashboardRepository>();
      
      final profile = await repository.getDriverProfile();

      
      final vehicle = await repository.getVehicle();

      
      final route = await repository.getRoute();
      final earnings = await repository.getTodayEarnings();
      final currentPax = await repository.getCurrentPassengers();
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => n['isRead'] == false).length;
      
      bool isInQueue = false;
      QueuePosition? queuePosition;
      
      try {
        final queueRepository = getIt<QueueRepository>();
        final queueResult = await queueRepository.getQueuePosition();
        queueResult.fold(
          (failure) {

            isInQueue = false;
            queuePosition = null;
          },
          (position) {

            isInQueue = true;
            queuePosition = position;
          },
        );
      } catch (qe) {

        isInQueue = false;
      }
      
      if (mounted) {

        setState(() {
          _profile = profile;
          _vehicle = vehicle;
          _route = route;
          _earnings = earnings;
          _currentPax = currentPax;
          _unreadCount = unreadCount;
          _isInQueue = isInQueue;
          _queuePosition = queuePosition;
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
  Future<void> _updateStatus(bool isOnline) async {
    try {
      // Optimistic update
      setState(() {
        _profile = _profile?.copyWith(status: isOnline ? 1 : 0);
      });
      
      final repository = getIt<DashboardRepository>();
      await repository.toggleStatus(isOnline ? 'online' : 'offline');
      
      // Refresh data to confirm status
      await _loadData();
    } catch (e) {
      debugPrint('DASHBOARD: Error toggling status: $e');
      // Revert on error
      if (mounted) {
        setState(() {
          _profile = _profile?.copyWith(status: isOnline ? 0 : 1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = [
      _HomeTab(
        key: const ValueKey('home_tab'),
        profile: _profile,
        vehicle: _vehicle,
        route: _route,
        earnings: _earnings,
        currentPax: _currentPax,
        unreadCount: _unreadCount,
        queuePosition: _queuePosition,
        onStatusChanged: _updateStatus,
        onChangeTab: (index) => setState(() => _currentIndex = index),
        onRefresh: _loadData,
      ),
      _isInQueue 
        ? DriverQueueScreen(
            key: const ValueKey('queue_active_tab'),
            profile: _profile, 
            isTab: true,
            queuePosition: _queuePosition,
            currentPax: _currentPax,
            capacity: _vehicle?.capacity ?? 14,
            onPaxChanged: (pax) => setState(() => _currentPax = pax),
          )
        : JoinQueueScreen(
            key: const ValueKey('join_queue_tab'),
            profile: _profile, 
            onQueueJoined: _loadData
          ),
      EarningsScreen(
        key: const ValueKey('earnings_tab'),
        isTab: true, 
        profile: _profile
      ),
      ProfileScreen(
        key: const ValueKey('profile_tab'),
        profile: _profile, 
        vehicle: _vehicle, 
        onRefresh: _loadData,
        onStatusChanged: _updateStatus,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Material(
          color: theme.scaffoldBackgroundColor,
          child: Stack(
            children: [
              SizedBox.expand(
                child: IndexedStack(
                  index: _currentIndex,
                  children: tabs,
                ),
              ),
              if (_isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppColors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                ),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.8),
            border: const Border(
              top: BorderSide(color: AppColors.grey200, width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_filled, size: 24),
                ),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.format_list_bulleted_rounded, size: 24),
                ),
                label: 'QUEUE',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.account_balance_wallet_rounded, size: 24),
                ),
                label: 'EARNINGS',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_rounded, size: 24),
                ),
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final DriverProfile? profile;
  final Vehicle? vehicle;
  final CircleRoute? route;
  final EarningsSummary? earnings;
  final int currentPax;
  final int unreadCount;
  final QueuePosition? queuePosition;
  final Function(bool)? onStatusChanged;
  final Function(int)? onChangeTab;
  final VoidCallback? onRefresh;

  const _HomeTab({
    super.key,
    this.profile,
    this.vehicle,
    this.route,
    this.earnings,
    this.currentPax = 0,
    required this.unreadCount,
    this.queuePosition,
    this.onStatusChanged,
    this.onChangeTab,
    this.onRefresh,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnTrip = currentPax > 0;
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          floating: true,
          pinned: true,
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => onChangeTab?.call(3), // Go to profile
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: profile?.imageUrl != null ? NetworkImage(profile!.imageUrl!) : null,
                    child: profile?.imageUrl == null ? Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant) : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver Dashboard',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const SizedBox(height: 2),
                  if (profile?.status == 1)
                    Row(
                      children: [
                        Text(
                          'ON DUTY',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('•', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Text(
                          'OFFLINE',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          actions: [
             Padding(
               padding: const EdgeInsets.only(right: 16),
               child: _buildNotificationBell(context),
             ),
          ],
        ),
        
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Status Banner
              if (isOnTrip) 
                _buildActiveTripBanner(context)
              else if (queuePosition != null)
                _buildQueueStatusBanner(context)
              else if (profile?.status == 1)
                _buildStandbyBanner(context)
              else
                _buildOfflineBanner(context),
              
              const SizedBox(height: 24),
              
              // Assigned Route Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YOUR ROUTE',
                    style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.2),
                  ),
                  if (route != null)
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(
                       color: AppColors.primaryBlue.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(4),
                     ),
                     child: Text(
                       'Active',
                       style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 12),
              AssignedSaccoCard(route: route),
              
              const SizedBox(height: 24),
              
              // Vehicle Load Section
              Text(
                'VEHICLE LOAD',
                style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              VehicleCapacityCard(vehicle: vehicle, currentPax: currentPax),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              Text(
                'QUICK ACTIONS',
                style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              DashboardActionButtons(
                route: route, 
                currentPax: currentPax, 
                capacity: vehicle?.capacity ?? 14,
              ),
              
              const SizedBox(height: 24),
              
              // Today's Stats
              Text(
                'TODAY\'S PERFORMANCE',
                style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              DashboardStatsGrid(earnings: earnings),
              
              const SizedBox(height: 24),
              UpcomingRouteCard(route: route),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTripBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car_rounded, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRIP IN PROGRESS',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Driving to ${route?.name.split('->').last.trim() ?? "Destination"}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton.primary(
                label: 'Resume',
                onPressed: () => context.push(RouteNames.tripInProgress, extra: {'passengerCount': currentPax}),
                backgroundColor: AppColors.white.withOpacity(0.9),
                foregroundColor: AppColors.primaryBlue,
                size: ButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStatusBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => onChangeTab?.call(1),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOU ARE IN QUEUE',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Position #${queuePosition?.position ?? "3"}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: AppColors.grey300, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentPax >= (vehicle?.capacity ?? 14) ? 'FULL' : 'LOADING',
                        style: TextStyle(
                          color: currentPax >= (vehicle?.capacity ?? 14) ? AppColors.primaryGreen : AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey400, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStandbyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sensors_rounded, color: AppColors.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STANDBY • ONLINE',
                      style: TextStyle(
                         color: AppColors.primaryGreen, 
                         fontSize: 10,
                         fontWeight: FontWeight.w800,
                         letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready to accept passengers',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AppButton.primary(
              onPressed: () => onChangeTab?.call(1), // Join Queue
              icon: Icons.login_rounded,
              label: 'JOIN DEPARTURE QUEUE',
              isFullWidth: true,
              gradient: AppColors.primaryGradient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.power_off_rounded, color: AppColors.grey500, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM OFFLINE',
                   style: TextStyle(
                     color: AppColors.grey500, 
                     fontSize: 10,
                     fontWeight: FontWeight.w800,
                     letterSpacing: 0.8,
                  ),
                ),
                const Text(
                  'You are currently offline',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AppButton.text(
            onPressed: () => onChangeTab?.call(3), // Profile
            label: 'GO ONLINE',
            foregroundColor: AppColors.primaryBlue,
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
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey200),
            ),
            child: Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
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
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    '$unreadCount',
                    style: TextStyle(color: AppColors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) async {
  final repository = getIt<DashboardRepository>();
  // Mark as StateSetter to refresh inside sheet if needed, or just reload on close
  // For now simple reload on close
  
  await showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: repository.getNotifications(),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            final theme = Theme.of(context);
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                   const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Notifications', style: AppTextStyles.heading3.copyWith(color: theme.colorScheme.onSurface)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none_rounded, size: 64, color: theme.dividerColor),
                                const SizedBox(height: 16),
                                Text('No notifications', style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final n = notifications[index];
                              final isRead = n['isRead'] == true;
                              return ListTile(
                                onTap: () async {
                                  if (!isRead) {
                                    await repository.markNotificationAsRead(n['id']);
                                    setSheetState(() {}); // Refresh list
                                    onRefresh?.call(); // Refresh dashboard badge immediately
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundColor: isRead ? theme.disabledColor.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.notifications, 
                                    color: isRead ? theme.disabledColor : theme.colorScheme.primary
                                  ),
                                ),
                                title: Text(
                                  n['title'] ?? 'Notification',
                                  style: TextStyle(
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  n['message'] ?? '',
                                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                ),
                                trailing: isRead 
                                  ? null 
                                  : Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
                              );
                            },
                          ),
                    ),
                ],
              ),
            );
          }
        );
      }
    ),
  );
  
  // Refresh dashboard badge on close
  onRefresh?.call();
}
}
