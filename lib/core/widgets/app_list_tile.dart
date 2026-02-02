import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../extensions/context_extensions.dart';

class AppListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailing;
  final String? trailingSubtitle;
  final Color? trailingColor;
  final Color? trailingSubtitleColor;
  final bool showDivider;
  final Widget? badge;
  final VoidCallback? onTap;

  const AppListTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.trailingSubtitle,
    this.trailingColor,
    this.trailingSubtitleColor,
    this.showDivider = true,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge != null) badge!,
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey[400]
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null || trailingSubtitle != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (trailing != null)
                        Text(
                          trailing!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: trailingColor ?? theme.colorScheme.onSurface,
                          ),
                        ),
                      if (trailingSubtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          trailingSubtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trailingSubtitleColor ??
                                (isDark
                                    ? Colors.grey[400]
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
        ],
      ),
    );
  }
}

// Unread indicator badge
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
    );
  }
}
