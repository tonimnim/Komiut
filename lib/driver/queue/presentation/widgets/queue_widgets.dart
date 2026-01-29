import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/komiut_map.dart';
import '../../../../core/widgets/buttons/app_button.dart';

class RouteStatsGrid extends StatelessWidget {
  const RouteStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _StatItem(
          icon: Icons.event_seat_rounded,
          value: '12 seats',
          label: 'AVAILABLE',
          iconColor: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        const _StatItem(
          icon: Icons.payments_rounded,
          value: r'$2.50',
          label: 'FIXED FARE',
          iconColor: AppColors.success,
        ),
        const SizedBox(width: 12),
        const _StatItem(
          icon: Icons.access_time_filled_rounded,
          value: '5 mins',
          label: 'DEPARTURE',
          iconColor: AppColors.primaryOrange,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(fontSize: 15, color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DriverQueueStatusCard extends StatelessWidget {
  final int position;
  final int waitMins;
  final String status;
  final Color? statusColor;
  
  const DriverQueueStatusCard({
    super.key,
    required this.position,
    required this.waitMins,
    this.status = 'LIVE',
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        gradient: AppColors.walletCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR STATUS',
                  style: AppTextStyles.label.copyWith(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Position #$position',
                      style: AppTextStyles.heading2.copyWith(fontSize: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.overline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Estimated wait: $waitMins mins',
                  style: AppTextStyles.body2.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Refresh Position',
                          style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: KomiutMap(
                  initialPosition: const LatLng(-1.2867, 36.8172),
                  zoom: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QueueListItem extends StatelessWidget {
  final String name;
  final String vehicle;
  final String plate;
  final String? status;
  final bool isMe;
  final bool isAhead;

  const QueueListItem({
    super.key,
    required this.name,
    required this.vehicle,
    required this.plate,
    this.status,
    this.isMe = false,
    this.isAhead = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? theme.colorScheme.primary.withOpacity(0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? theme.colorScheme.primary.withOpacity(0.2) : theme.dividerColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isMe ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/100?u=user'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                if (status == 'IN LOADING' || name == 'Alex M.')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.cardColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.heading4.copyWith(fontSize: 15, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMe ? '(Me)' : isAhead ? '(Ahead)' : '(Behind)',
                      style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'POS #3',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$vehicle • $plate',
                  style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (status != null && !isMe)
            Text(
              status!,
              style: AppTextStyles.overline.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          if (isMe)
             Icon(Icons.drag_handle_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class PassengerCountSelector extends StatefulWidget {
  final int capacity;
  final int initialCount;
  final Function(int)? onCountChanged;
  final VoidCallback? onStartTrip;
  final bool showStartButton;

  const PassengerCountSelector({
    super.key, 
    this.capacity = 15,
    this.initialCount = 12,
    this.onCountChanged,
    this.onStartTrip,
    this.showStartButton = false,
  });

  @override
  State<PassengerCountSelector> createState() => _PassengerCountSelectorState();
}

class _PassengerCountSelectorState extends State<PassengerCountSelector> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _updateCount(int newCount) {
    setState(() => _count = newCount);
    if (widget.onCountChanged != null) {
      widget.onCountChanged!(newCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PASSENGER COUNT',
                    style: AppTextStyles.overline.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_count',
                          style: AppTextStyles.heading1.copyWith(fontSize: 36, color: theme.colorScheme.onSurface),
                        ),
                        TextSpan(
                          text: ' / ${widget.capacity}',
                          style: AppTextStyles.body1.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildCounterBtn(Icons.remove, theme.cardColor, theme.colorScheme.onSurface, () {
                      if (_count > 1) _updateCount(_count - 1);
                    }, theme),
                    const SizedBox(width: 16),
                    Text(
                      '$_count',
                      style: AppTextStyles.heading4.copyWith(fontSize: 18, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(width: 16),
                    _buildCounterBtn(Icons.add, theme.colorScheme.primary, Colors.white, () {
                      if (_count < widget.capacity) _updateCount(_count + 1);
                    }, theme),
                  ],
                ),
              ),
            ],
          ),
          if (widget.showStartButton) ...[
            const SizedBox(height: 24),
            AppButton.primary(
              label: 'Start Trip',
              onPressed: widget.onStartTrip,
              size: ButtonSize.large,
              isFullWidth: true,
              icon: Icons.airport_shuttle_rounded,
              backgroundColor: theme.colorScheme.primary, 
              // Removed AppColors.primaryGradient to follow theme
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounterBtn(IconData icon, Color bg, Color iconColor, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
             if (bg == theme.cardColor)
               const BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

class JoinQueueOverlay extends StatelessWidget {
  final bool isJoined;
  final int totalVehicles;
  final int estimatedWaitMins;

  const JoinQueueOverlay({
    super.key,
    this.isJoined = false,
    this.totalVehicles = 15,
    this.estimatedWaitMins = 45,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.groups_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    isJoined ? 'Your Queue Position' : 'Terminal Status',
                    style: AppTextStyles.heading3.copyWith(fontSize: 18, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  isJoined ? '3rd in line' : '$totalVehicles Waiting',
                  style: AppTextStyles.label.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isJoined)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.6,
                minHeight: 12,
                backgroundColor: theme.scaffoldBackgroundColor,
                color: theme.colorScheme.primary,
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Join now to secure your spot in the departure queue.',
                    style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.body2,
                  children: [
                    TextSpan(text: isJoined ? 'Approximate wait: ' : 'Avg. wait time: ', style: TextStyle(color: theme.colorScheme.onSurface)),
                    TextSpan(
                      text: '$estimatedWaitMins mins',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _avatarOverlapMini(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarOverlapMini(ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 28,
          child: Stack(
            children: [
              Positioned(left: 0, child: _avatar(theme)),
              Positioned(left: 16, child: _avatar(theme)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: theme.cardColor, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            '+5',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _avatar(ThemeData theme) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.cardColor, width: 2),
        image: const DecorationImage(
          image: NetworkImage('https://i.pravatar.cc/100?u=a'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class LiveTrackingBadge extends StatelessWidget {
  const LiveTrackingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Live Tracking',
        style: AppTextStyles.overline.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

