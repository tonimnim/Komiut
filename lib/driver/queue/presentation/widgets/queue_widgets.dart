import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/komiut_map.dart';

class RouteStatsGrid extends StatelessWidget {
  const RouteStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.event_seat_rounded,
          value: '12 seats',
          label: 'AVAILABLE',
          iconColor: Colors.blue.shade600,
        ),
        const SizedBox(width: 12),
        _StatItem(
          icon: Icons.payments_rounded,
          value: r'$2.50',
          label: 'FIXED FARE',
          iconColor: AppColors.primaryGreen,
        ),
        const SizedBox(width: 12),
        _StatItem(
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey100),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
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
  
  const DriverQueueStatusCard({
    super.key,
    required this.position,
    required this.waitMins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 15, offset: Offset(0, 8)),
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
                  style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Position #$position',
                      style: AppTextStyles.heading2.copyWith(fontSize: 32),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pillBlueBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LIVE',
                        style: AppTextStyles.overline.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Estimated wait: $waitMins mins',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.pillBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Refresh Position',
                          style: AppTextStyles.button.copyWith(color: AppColors.primaryBlue, fontSize: 13),
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
                border: Border.all(color: AppColors.grey200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const KomiutMap(
                  initialPosition: LatLng(-1.2867, 36.8172),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.pillBlueBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? AppColors.primaryBlue : AppColors.grey100, width: isMe ? 1.5 : 1),
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
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                      style: AppTextStyles.heading4.copyWith(fontSize: 15),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMe ? '(Me)' : isAhead ? '(Ahead)' : '(Behind)',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'POS #3',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$vehicle • $plate',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (status != null && !isMe)
            Text(
              status!,
              style: AppTextStyles.overline.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          if (isMe)
             const Icon(Icons.drag_handle_rounded, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}

class PassengerCountSelector extends StatefulWidget {
  final int capacity;
  const PassengerCountSelector({super.key, this.capacity = 15});

  @override
  State<PassengerCountSelector> createState() => _PassengerCountSelectorState();
}

class _PassengerCountSelectorState extends State<PassengerCountSelector> {
  int _count = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
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
                      color: AppColors.textMuted,
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
                          style: AppTextStyles.heading1.copyWith(fontSize: 36, color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: ' / ${widget.capacity}',
                          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildCounterBtn(Icons.remove, Colors.white, AppColors.textPrimary, () {
                      if (_count > 1) setState(() => _count--);
                    }),
                    const SizedBox(width: 16),
                    Text(
                      '$_count',
                      style: AppTextStyles.heading4.copyWith(fontSize: 18, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 16),
                    _buildCounterBtn(Icons.add, AppColors.primaryBlue, Colors.white, () {
                      if (_count < widget.capacity) setState(() => _count++);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.tripInProgress, extra: {'passengerCount': _count}),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.airport_shuttle_rounded, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Start Trip',
                    style: AppTextStyles.button.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBtn(IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
             if (bg == Colors.white)
               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

class JoinQueueOverlay extends StatelessWidget {
  const JoinQueueOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups_rounded, color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Your Queue Position',
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.pillBlueBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '3rd in line',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 12,
              backgroundColor: AppColors.grey50,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.body2,
                  children: [
                    const TextSpan(text: 'Approximate wait: '),
                    TextSpan(
                      text: '8 mins',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _avatarOverlapMini(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarOverlapMini() {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 28,
          child: Stack(
            children: [
              Positioned(left: 0, child: _avatar()),
              Positioned(left: 16, child: _avatar()),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
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

  Widget _avatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pillBlueBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Live Tracking',
        style: AppTextStyles.overline.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

