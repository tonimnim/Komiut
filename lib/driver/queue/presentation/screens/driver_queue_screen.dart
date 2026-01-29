import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/driver/queue/presentation/widgets/queue_widgets.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/driver/queue/domain/entities/queue_entities.dart';
import 'package:komiut/core/routes/route_names.dart';
import 'package:komiut/shared/widgets/komiut_app_bar.dart';

class DriverQueueScreen extends StatefulWidget {
  final bool isTab;
  final DriverProfile? profile;
  final QueuePosition? queuePosition;
  final int currentPax;
  final int capacity;
  final Function(int)? onPaxChanged;

  const DriverQueueScreen({
    super.key, 
    this.isTab = false, 
    this.profile,
    this.queuePosition,
    this.currentPax = 0,
    this.capacity = 14,
    this.onPaxChanged,
  });

  @override
  State<DriverQueueScreen> createState() => _DriverQueueScreenState();
}

class _DriverQueueScreenState extends State<DriverQueueScreen> {
  late int _passengerCount;

  @override
  void initState() {
    super.initState();
    _passengerCount = widget.currentPax;
  }

  @override
  void didUpdateWidget(DriverQueueScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPax != oldWidget.currentPax) {
      _passengerCount = widget.currentPax;
    }
  }

  void _onPaxChanged(int count) {
    setState(() => _passengerCount = count);
    widget.onPaxChanged?.call(count);
  }

  String get _status => _passengerCount >= widget.capacity ? 'FULL' : 'LOADING';
  Color _statusColor(ThemeData theme) => _passengerCount >= widget.capacity ? AppColors.success : theme.colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isTab ? null : _buildAppBar(context, theme),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Route 402 - Downtown Express',
                    style: AppTextStyles.heading3.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terminal A • Station Gate 14',
                    style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  DriverQueueStatusCard(
                    position: widget.queuePosition?.position ?? 3,
                    waitMins: widget.queuePosition?.estimatedWaitMins ?? 8,
                    status: _status,
                    statusColor: _statusColor(theme),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queue List',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '6 Drivers waiting',
                        style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const QueueListItem(
                    name: 'Alex M.',
                    vehicle: 'Toyota Hiace',
                    plate: 'KBD 123',
                    status: 'IN LOADING',
                    isAhead: true,
                  ),
                  QueueListItem(
                    name: 'You (Me)',
                    vehicle: 'Volkswagen Transporter',
                    plate: 'KYZ 789',
                    isMe: true,
                    status: _status, // Show my status
                  ),
                  const QueueListItem(
                    name: 'Sarah L.',
                    vehicle: 'Mercedes Sprinter',
                    plate: 'LMN 456',
                    status: '10M WAIT',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          PassengerCountSelector(
            capacity: widget.capacity,
            initialCount: _passengerCount,
            onCountChanged: _onPaxChanged,
            showStartButton: _passengerCount >= widget.capacity,
            onStartTrip: () => context.push(RouteNames.tripInProgress, extra: {
              'passengerCount': _passengerCount,
              'profile': widget.profile,
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return KomiutAppBar(
      title: 'Driver Queue',
      imageUrl: widget.profile?.imageUrl,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
        onPressed: () => context.pop(),
      ),
      onProfileTap: () {
        // Navigate to profile tab or screen
        if (widget.isTab) {
          // If it's a tab, we probably want to tell the parent to switch tab
        } else {
          // If it's a separate screen, we can push profile
          context.push(RouteNames.driverDashboard, extra: {'initialTab': 3});
        }
      },
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}


