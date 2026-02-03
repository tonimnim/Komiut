/// Profile header widget.
///
/// Shows avatar, name, verification badge, email, and rating.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/domain/entities/driver_profile.dart';

/// Profile header with avatar, name, and rating.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.profile});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileImage = ref.watch(
      authStateProvider.select((state) => state.user?.profileImage),
    );
    final hasValidImage =
        profileImage != null && File(profileImage).existsSync();

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
      ),
      child: Column(
        children: [
          // Back button row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),

          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 3,
              ),
              image: hasValidImage
                  ? DecorationImage(
                      image: FileImage(File(profileImage)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasValidImage
                ? null
                : Icon(
                    Icons.person,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
          ),
          const SizedBox(height: 16),

          // Name with verification badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.fullName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (profile.isVerified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            profile.email,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Rating stars
          if (profile.rating != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(5, (index) {
                  final rating = profile.rating ?? 0;
                  return Icon(
                    index < rating.floor()
                        ? Icons.star_rounded
                        : index < rating
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  profile.displayRating,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Quick stats row showing trips, rating, and member since.
class ProfileQuickStats extends StatelessWidget {
  const ProfileQuickStats({super.key, required this.profile});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '${profile.totalTrips ?? 0}',
              label: 'Trips',
              icon: Icons.route_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          Expanded(
            child: _StatItem(
              value: profile.displayRating,
              label: 'Rating',
              icon: Icons.star_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          const Expanded(
            child: _StatItem(
              value: '2y',
              label: 'Member',
              icon: Icons.calendar_today_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[500] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
