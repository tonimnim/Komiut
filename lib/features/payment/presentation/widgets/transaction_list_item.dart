/// Transaction list item widget.
///
/// Displays a single wallet transaction in a list.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../home/domain/entities/wallet_entity.dart';

/// Transaction list item widget.
///
/// Shows transaction type, description, amount, and timestamp.
class TransactionListItem extends StatelessWidget {
  /// Creates a transaction list item.
  const TransactionListItem({
    required this.transaction,
    this.onTap,
    this.showDivider = true,
    super.key,
  });

  /// The transaction to display.
  final WalletTransaction transaction;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Whether to show divider at bottom.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Description and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.displayLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            Formatters.formatSmartDate(transaction.timestamp),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (transaction.reference != null) ...[
                            Text(
                              ' - ',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                transaction.reference!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : AppColors.textHint,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  transaction.signedAmount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: transaction.isCredit
                        ? AppColors.success
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              indent: 74,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.type) {
      case TransactionType.topup:
        return Icons.add_circle_outline;
      case TransactionType.payment:
        return Icons.directions_bus;
      case TransactionType.refund:
        return Icons.replay;
      case TransactionType.bonus:
        return Icons.card_giftcard;
    }
  }

  Color _getIconColor() {
    switch (transaction.type) {
      case TransactionType.topup:
        return AppColors.success;
      case TransactionType.payment:
        return AppColors.primaryBlue;
      case TransactionType.refund:
        return Colors.orange;
      case TransactionType.bonus:
        return AppColors.secondaryPurple;
    }
  }

  Color _getIconBackgroundColor(bool isDark) {
    final baseColor = _getIconColor();
    return isDark
        ? baseColor.withValues(alpha: 0.15)
        : baseColor.withValues(alpha: 0.1);
  }
}

/// Transaction detail bottom sheet.
class TransactionDetailSheet extends StatelessWidget {
  /// Creates a transaction detail sheet.
  const TransactionDetailSheet({
    required this.transaction,
    super.key,
  });

  /// The transaction to display.
  final WalletTransaction transaction;

  /// Show the sheet.
  static Future<void> show(BuildContext context, WalletTransaction transaction) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIcon(),
              color: _getIconColor(),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Amount
          Text(
            transaction.signedAmount,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: transaction.isCredit
                  ? AppColors.success
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Type label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              transaction.type.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getIconColor(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Details
          _DetailRow(
            label: 'Date & Time',
            value: Formatters.formatDateTime(transaction.timestamp),
            isDark: isDark,
          ),
          if (transaction.description != null)
            _DetailRow(
              label: 'Description',
              value: transaction.description!,
              isDark: isDark,
            ),
          if (transaction.reference != null)
            _DetailRow(
              label: 'Reference',
              value: transaction.reference!,
              isDark: isDark,
            ),
          _DetailRow(
            label: 'Balance After',
            value: 'KES ${transaction.balanceAfter.toStringAsFixed(2)}',
            isDark: isDark,
          ),
          _DetailRow(
            label: 'Transaction ID',
            value: transaction.id,
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.type) {
      case TransactionType.topup:
        return Icons.add_circle_outline;
      case TransactionType.payment:
        return Icons.directions_bus;
      case TransactionType.refund:
        return Icons.replay;
      case TransactionType.bonus:
        return Icons.card_giftcard;
    }
  }

  Color _getIconColor() {
    switch (transaction.type) {
      case TransactionType.topup:
        return AppColors.success;
      case TransactionType.payment:
        return AppColors.primaryBlue;
      case TransactionType.refund:
        return Colors.orange;
      case TransactionType.bonus:
        return AppColors.secondaryPurple;
    }
  }

  Color _getIconBackgroundColor(bool isDark) {
    final baseColor = _getIconColor();
    return isDark
        ? baseColor.withValues(alpha: 0.15)
        : baseColor.withValues(alpha: 0.1);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
