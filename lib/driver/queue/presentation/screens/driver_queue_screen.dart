import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/queue_widgets.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';

class DriverQueueScreen extends StatefulWidget {
  final bool isTab;
  final DriverProfile? profile;
  const DriverQueueScreen({super.key, this.isTab = false, this.profile});

  @override
  State<DriverQueueScreen> createState() => _DriverQueueScreenState();
}

class _DriverQueueScreenState extends State<DriverQueueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isTab ? null : _buildAppBar(context),
      body: SafeArea(
        child: Column(
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
                      style: AppTextStyles.heading2.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terminal A • Station Gate 14',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    const DriverQueueStatusCard(
                      position: 3,
                      waitMins: 8,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Queue List',
                          style: AppTextStyles.heading3.copyWith(fontSize: 20),
                        ),
                        Text(
                          '6 Drivers waiting',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
                    const QueueListItem(
                      name: 'You (Me)',
                      vehicle: 'Volkswagen Transporter',
                      plate: 'KYZ 789',
                      isMe: true,
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
            const PassengerCountSelector(capacity: 15),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Driver Queue',
        style: AppTextStyles.heading3,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }
}

