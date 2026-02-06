/// Premium driver status card with gradient design.
///
/// Matches passenger's WalletCard styling for consistency.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../providers/dashboard_providers.dart';

/// Premium status card showing driver's online status and vehicle info.
class DriverStatusCard extends ConsumerWidget {
  const DriverStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);

    return profileAsync.when(
      loading: () => const _DriverStatusCardContent(
        isOnline: false,
        isLoading: true,
      ),
      error: (_, __) => const _DriverStatusCardContent(
        isOnline: false,
      ),
      data: (profile) => _DriverStatusCardContent(
        isOnline: profile.isOnline,
        vehicleId: profile.vehicleId,
      ),
    );
  }
}

class _DriverStatusCardContent extends StatelessWidget {
  const _DriverStatusCardContent({
    required this.isOnline,
    this.vehicleId,
    this.isLoading = false,
  });

  final bool isOnline;
  final String? vehicleId;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Use different gradient based on online status
    final gradient = isOnline
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryGreen, Color(0xFF059669)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
          );

    final shadowColor = isOnline
        ? AppColors.primaryGreen.withValues(alpha: 0.3)
        : AppColors.primaryBlue.withValues(alpha: 0.3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(
                height: 16,
                width: 100,
                borderRadius: 8,
                baseColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.4),
              ),
              ShimmerBox(
                height: 32,
                width: 60,
                borderRadius: 16,
                baseColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ShimmerBox(
            height: 36,
            width: 140,
            borderRadius: 8,
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          ShimmerBox(
            height: 20,
            width: 180,
            borderRadius: 8,
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Captain Status',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildStatusToggle(),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        if (vehicleId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_bus_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  'Vehicle: $vehicleId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'No vehicle assigned',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: () {
        // TODO: Toggle online status
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? Colors.white : Colors.white54,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'ON' : 'OFF',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
