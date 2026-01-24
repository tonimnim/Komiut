/// Points transaction item widget.
///
/// Displays a single points transaction in history.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/loyalty_points.dart';

/// A widget displaying a single points transaction.
///
/// Shows:
/// - Transaction type icon
/// - Description
/// - Points amount (with sign)
/// - Timestamp
class PointsTransactionItem extends StatelessWidget {
  /// Creates a points transaction item.
  const PointsTransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  /// The transaction to display.
  final PointsTransaction transaction;

  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            _TransactionIcon(type: transaction.type),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(transaction.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedPoints,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: transaction.type.isPositive
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                Text(
                  'points',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}

/// Transaction type icon widget.
class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.type});

  final PointsTransactionType type;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (type) {
      PointsTransactionType.earned => (Icons.add_circle_outline, AppColors.success),
      PointsTransactionType.redeemed => (Icons.redeem, AppColors.primaryBlue),
      PointsTransactionType.expired => (Icons.timer_off_outlined, AppColors.warning),
      PointsTransactionType.bonus => (Icons.card_giftcard, AppColors.secondaryPurple),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }
}

/// A list of points transactions.
class PointsTransactionList extends StatelessWidget {
  /// Creates a points transaction list.
  const PointsTransactionList({
    super.key,
    required this.transactions,
    this.onTransactionTap,
    this.showLoadMore = false,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  /// List of transactions to display.
  final List<PointsTransaction> transactions;

  /// Callback when a transaction is tapped.
  final void Function(PointsTransaction)? onTransactionTap;

  /// Whether to show load more button.
  final bool showLoadMore;

  /// Callback when load more is pressed.
  final VoidCallback? onLoadMore;

  /// Whether more items are being loaded.
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your points activity will appear here',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...transactions.map((transaction) => PointsTransactionItem(
              transaction: transaction,
              onTap: onTransactionTap != null
                  ? () => onTransactionTap!(transaction)
                  : null,
            )),
        if (showLoadMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isLoadingMore
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: onLoadMore,
                    child: const Text('Load more'),
                  ),
          ),
      ],
    );
  }
}
