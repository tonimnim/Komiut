import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../driver/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../core/widgets/buttons/app_button.dart';

class StartTripScreen extends StatefulWidget {
  final CircleRoute? route;
  const StartTripScreen({super.key, this.route});

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen> {
  int _passengerCount = 14;
  final double _farePerPassenger = 100.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double totalFare = _passengerCount * _farePerPassenger;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Start Trip'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteInfo(),
            const SizedBox(height: 32),
            _buildPassengerCounter(),
            const SizedBox(height: 40),
            _buildFareSummary(totalFare),
            const SizedBox(height: 48),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ASSIGNED ROUTE',
            style: AppTextStyles.label.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.route?.name ?? 'CBD - Kikuyu',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'KES ${_farePerPassenger.toInt()} per passenger',
                style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCounter() {
    return Column(
      children: [
        Text(
          'How many passengers?',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CounterButton(
              icon: Icons.remove,
              onPressed: () {
                if (_passengerCount > 1) {
                  setState(() => _passengerCount--);
                }
              },
            ),
            const SizedBox(width: 32),
            Text(
              '$_passengerCount',
              style: AppTextStyles.heading1.copyWith(fontSize: 64),
            ),
            const SizedBox(width: 32),
            _CounterButton(
              icon: Icons.add,
              onPressed: () {
                if (_passengerCount < 14) {
                  setState(() => _passengerCount++);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Max capacity: 14',
          style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildFareSummary(double totalFare) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Estimated Total Fare',
            style: AppTextStyles.body1.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(
            'KES ${totalFare.toInt()}',
            style: AppTextStyles.heading3.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return AppButton.primary(
      label: 'START TRIP',
      onPressed: () {
        context.push(RouteNames.tripInProgress);
      },
      size: ButtonSize.large,
      isFullWidth: true,
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CounterButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: theme.colorScheme.onSurface, size: 32),
        ),
      ),
    );
  }
}
