import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../queue/presentation/providers/notification_providers.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsContent();
  }
}

class SettingsContent extends ConsumerStatefulWidget {
  const SettingsContent({super.key});

  @override
  ConsumerState<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<SettingsContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Use select to only rebuild when user changes, not on every auth state change
    final user = ref.watch(currentUserProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: user),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          image: user?.profileImage != null &&
                                  File(user!.profileImage!).existsSync()
                              ? DecorationImage(
                                  image: FileImage(File(user.profileImage!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user?.profileImage == null ||
                                !File(user!.profileImage!).existsSync()
                            ? const Icon(
                                Icons.person,
                                color: AppColors.primaryBlue,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'User',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.grey[600] : AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context: context,
                      icon: Icons.queue_outlined,
                      title: 'Queue Notifications',
                      subtitle: 'Vehicle position & departure alerts',
                      value: notificationSettings.queueNotificationsEnabled,
                      onChanged: (value) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .setQueueNotificationsEnabled(value);
                      },
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey[800] : AppColors.divider),
                    _buildSwitchTile(
                      context: context,
                      icon: Icons.directions_bus_outlined,
                      title: 'Trip Notifications',
                      subtitle: 'Trip start & destination alerts',
                      value: notificationSettings.tripNotificationsEnabled,
                      onChanged: (value) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .setTripNotificationsEnabled(value);
                      },
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey[800] : AppColors.divider),
                    _buildSwitchTile(
                      context: context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      value: isDark,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey[800] : AppColors.divider),
                    _buildTile(
                      context: context,
                      icon: Icons.tune,
                      title: 'More Preferences',
                      onTap: () => context.push(RouteConstants.settingsPreferences),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildTile(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => context.push(RouteConstants.settingsHelp),
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey[800] : AppColors.divider),
                    _buildTile(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () => context.push(RouteConstants.settingsAbout),
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey[800] : AppColors.divider),
                    _buildTile(
                      context: context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => context.push(RouteConstants.settingsPrivacy),
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey[800] : AppColors.divider),
                    _buildTile(
                      context: context,
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => context.push(RouteConstants.settingsTerms),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(RouteConstants.login);
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Komiut v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[600] : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
