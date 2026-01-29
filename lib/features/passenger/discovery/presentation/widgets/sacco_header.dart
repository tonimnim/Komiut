/// Sacco Header - Header widget for Sacco detail screen.
///
/// Displays the Sacco logo, name, and status badge.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// A header widget displaying Sacco logo, name, and status.
///
/// Used at the top of the Sacco detail screen to provide
/// a visual overview of the organization.
///
/// ```dart
/// SaccoHeader(
///   name: 'Metro Trans Sacco',
///   logoUrl: 'https://example.com/logo.png',
///   isActive: true,
/// )
/// ```
class SaccoHeader extends StatelessWidget {
  /// Creates a SaccoHeader.
  const SaccoHeader({
    super.key,
    required this.name,
    this.logoUrl,
    required this.isActive,
    this.routeCount,
  });

  /// The Sacco name.
  final String name;

  /// URL to the Sacco logo image.
  final String? logoUrl;

  /// Whether the Sacco is currently active.
  final bool isActive;

  /// Optional route count to display.
  final int? routeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          _buildLogo(context, isDark),
          const SizedBox(width: 16),
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Status badge
                    _buildStatusBadge(context, isActive, isDark),
                    if (routeCount != null) ...[
                      const SizedBox(width: 12),
                      // Route count
                      _buildRouteCount(context, isDark),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildLogoPlaceholder(isDark);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primaryBlue,
                    ),
                  );
                },
              ),
            )
          : _buildLogoPlaceholder(isDark),
    );
  }

  Widget _buildLogoPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.directions_bus_rounded,
        size: 40,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primaryGreen : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.primaryGreen : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCount(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.route_outlined,
          size: 14,
          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$routeCount routes',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading placeholder for SaccoHeader.
class SaccoHeaderShimmer extends StatelessWidget {
  /// Creates a SaccoHeaderShimmer.
  const SaccoHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Logo shimmer
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          // Content shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 180,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
