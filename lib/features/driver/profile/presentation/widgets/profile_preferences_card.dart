/// Profile preferences card with theme toggle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_provider.dart';
import 'profile_settings_items.dart';

/// Preferences card with theme toggle, notifications, and language.
class ProfilePreferencesCard extends ConsumerWidget {
  const ProfilePreferencesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return ProfileSettingsCard(
      children: [
        // Theme Toggle
        _ThemeToggleItem(
          isDark: isDark,
          themeMode: themeMode,
          onChanged: (value) {
            ref.read(themeProvider.notifier).setTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
          },
        ),
        Divider(
          height: 1,
          indent: 56,
          color: isDark ? Colors.grey[850] : Colors.grey[200],
        ),
        // Notifications
        ProfileSettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          onTap: () {
            // TODO: Navigate to notifications settings
          },
        ),
      ],
    );
  }
}

class _ThemeToggleItem extends StatelessWidget {
  const _ThemeToggleItem({
    required this.isDark,
    required this.themeMode,
    required this.onChanged,
  });

  final bool isDark;
  final ThemeMode themeMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 20,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark ? 'On' : 'Off',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: themeMode == ThemeMode.dark,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}
