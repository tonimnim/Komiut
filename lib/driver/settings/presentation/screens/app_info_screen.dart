import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/shared/widgets/komiut_app_bar.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: KomiutAppBar(
        title: 'App Information',
        showProfileIcon: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                   Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 24),
                  Text('Komiut Driver', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text('Version 2.0.0 (Build 342)', style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildInfoCard([
              _buildActionRow(Icons.description_outlined, 'Release Notes', () {}, theme),
              _buildActionRow(Icons.verified_user_outlined, 'Licenses', () {}, theme),
              _buildActionRow(Icons.update_rounded, 'Check for Updates', () {}, theme),
            ], theme),
            const SizedBox(height: 24),
            _buildInfoCard([
              _buildDetailRow('Client Platform', 'Flutter v3.19.0', theme),
              _buildDetailRow('API Engine', 'v2.komiut.com', theme),
              _buildDetailRow('Region', 'East Africa (Nairobi)', theme),
            ], theme),
            const SizedBox(height: 48),
            Text(
              '© 2026 Komiut Technologies Ltd. All rights reserved.',
              style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionRow(IconData icon, String title, VoidCallback onTap, ThemeData theme) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
      title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.dividerColor, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

