/// Saved item card widget.
///
/// A reusable card for displaying saved routes, Saccos, or payment methods
/// in list views with consistent styling.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A card widget for displaying saved items (routes, Saccos, etc.).
///
/// Provides a consistent visual style for saved items with:
/// - Leading icon or avatar
/// - Title and subtitle
/// - Optional trailing actions
/// - Swipe to delete support
class SavedItemCard extends StatelessWidget {
  /// Creates a saved item card.
  const SavedItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingImageUrl,
    this.trailing,
    this.onTap,
    this.onDelete,
    this.showDeleteAction = true,
  });

  /// The main title text.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Leading icon (used if no image URL is provided).
  final IconData? leadingIcon;

  /// Leading image URL (takes precedence over icon).
  final String? leadingImageUrl;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when delete action is triggered.
  final VoidCallback? onDelete;

  /// Whether to show the delete action on swipe.
  final bool showDeleteAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildLeading(isDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );

    if (showDeleteAction && onDelete != null) {
      return Dismissible(
        key: Key(title),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        confirmDismiss: (_) => _confirmDelete(context),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
        child: card,
      );
    }

    return card;
  }

  Widget _buildLeading(bool isDark) {
    if (leadingImageUrl != null && leadingImageUrl!.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(leadingImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        leadingIcon ?? Icons.bookmark_outline,
        color: AppColors.primaryBlue,
        size: 24,
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Are you sure you want to remove "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// A card specifically designed for saved routes.
class SavedRouteCard extends StatelessWidget {
  /// Creates a saved route card.
  const SavedRouteCard({
    super.key,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    this.customName,
    this.useCount = 0,
    this.onTap,
    this.onDelete,
  });

  final String routeName;
  final String startPoint;
  final String endPoint;
  final String? customName;
  final int useCount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SavedItemCard(
      title: customName ?? routeName,
      subtitle: '$startPoint to $endPoint',
      leadingIcon: Icons.route,
      trailing: useCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$useCount trips',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      onTap: onTap,
      onDelete: onDelete,
    );
  }
}

/// A card specifically designed for saved Saccos.
class SavedSaccoCard extends StatelessWidget {
  /// Creates a saved Sacco card.
  const SavedSaccoCard({
    super.key,
    required this.saccoName,
    this.description,
    this.logoUrl,
    this.routeCount = 0,
    this.onTap,
    this.onDelete,
  });

  final String saccoName;
  final String? description;
  final String? logoUrl;
  final int routeCount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SavedItemCard(
      title: saccoName,
      subtitle: description ?? (routeCount > 0 ? '$routeCount routes' : null),
      leadingImageUrl: logoUrl,
      leadingIcon: Icons.business,
      trailing: routeCount > 0 && description != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$routeCount routes',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.primaryGreen : AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      onTap: onTap,
      onDelete: onDelete,
    );
  }
}

/// A card specifically designed for saved payment methods.
class SavedPaymentMethodCard extends StatelessWidget {
  /// Creates a saved payment method card.
  const SavedPaymentMethodCard({
    super.key,
    required this.name,
    required this.maskedNumber,
    required this.isMpesa,
    this.isDefault = false,
    this.cardBrand,
    this.onTap,
    this.onDelete,
    this.onSetDefault,
  });

  final String name;
  final String maskedNumber;
  final bool isMpesa;
  final bool isDefault;
  final String? cardBrand;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SavedItemCard(
      title: name,
      subtitle: maskedNumber,
      leadingIcon: isMpesa ? Icons.phone_android : Icons.credit_card,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Default',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (onSetDefault != null)
            TextButton(
              onPressed: onSetDefault,
              child: Text(
                'Set Default',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      onDelete: onDelete,
    );
  }
}
