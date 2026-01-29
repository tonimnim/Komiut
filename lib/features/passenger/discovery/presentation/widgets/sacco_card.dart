/// SaccoCard - Card widget for displaying a Sacco.
///
/// Displays sacco information including logo, name, route count,
/// and operating status.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/sacco.dart';

/// A card widget for displaying Sacco information.
class SaccoCard extends StatelessWidget {
  /// Creates a SaccoCard.
  const SaccoCard({
    super.key,
    required this.sacco,
    this.onTap,
  });

  /// The sacco to display.
  final Sacco sacco;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Sacco logo or placeholder
                _buildLogo(theme, isDark),
                const SizedBox(width: 16),

                // Sacco details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      Text(
                        sacco.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Route count and status row
                      Row(
                        children: [
                          // Route count
                          if (sacco.routeCount > 0) ...[
                            Icon(
                              Icons.route_outlined,
                              size: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${sacco.routeCount} ${sacco.routeCount == 1 ? 'route' : 'routes'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.grey[400]
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          // Status indicator
                          _buildStatusIndicator(theme, isDark),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : AppColors.textHint,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme, bool isDark) {
    if (sacco.logoUrl != null && sacco.logoUrl!.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.grey[800] : Colors.grey[100],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          sacco.logoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderLogo(theme, isDark);
          },
        ),
      );
    }

    return _buildPlaceholderLogo(theme, isDark);
  }

  Widget _buildPlaceholderLogo(ThemeData theme, bool isDark) {
    final initial = sacco.name.isNotEmpty ? sacco.name[0].toUpperCase() : 'S';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: isDark ? 0.3 : 0.15),
            AppColors.primaryGreen.withValues(alpha: isDark ? 0.3 : 0.15),
          ],
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryGreen],
          ).createShader(bounds),
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, bool isDark) {
    final statusColor = sacco.isActive ? AppColors.success : AppColors.textHint;
    final statusText = sacco.isActive ? 'Active' : 'Inactive';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
