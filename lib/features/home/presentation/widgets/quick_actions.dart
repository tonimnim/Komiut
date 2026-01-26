import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/main_navigation.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.payment,
          label: 'Pay',
          color: AppColors.primaryBlue,
          onTap: () {
            ref.read(navigationIndexProvider.notifier).state = 2;
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.directions_bus,
          label: 'Explore',
          color: AppColors.secondaryPurple,
          onTap: () {
            context.push(RouteConstants.passengerSaccos);
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.card_giftcard,
          label: 'Points',
          color: AppColors.primaryGreen,
          onTap: () {
            context.push(RouteConstants.passengerLoyalty);
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.add,
          label: 'Top Up',
          color: Colors.orange,
          onTap: () {
            ref.read(navigationIndexProvider.notifier).state = 2;
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
