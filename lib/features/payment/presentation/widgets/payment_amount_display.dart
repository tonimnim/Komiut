/// Payment amount display widget.
///
/// Displays the payment amount with currency formatting,
/// optional breakdown, and styling options.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A widget that displays a payment amount with currency.
class PaymentAmountDisplay extends StatelessWidget {
  const PaymentAmountDisplay({
    super.key,
    required this.amount,
    this.currency = 'KES',
    this.label,
    this.size = PaymentAmountSize.large,
    this.showSign = false,
    this.isPositive = true,
    this.breakdown,
  });

  /// The amount to display.
  final double amount;

  /// The currency code.
  final String currency;

  /// Optional label above the amount.
  final String? label;

  /// The size of the amount display.
  final PaymentAmountSize size;

  /// Whether to show a +/- sign.
  final bool showSign;

  /// Whether the amount is positive (for sign display).
  final bool isPositive;

  /// Optional breakdown items to show below the main amount.
  final List<AmountBreakdownItem>? breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: size.labelSize,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.spacing),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (showSign)
              Text(
                isPositive ? '+' : '-',
                style: TextStyle(
                  fontSize: size.amountSize,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            Text(
              currency,
              style: TextStyle(
                fontSize: size.currencySize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _formatAmount(amount),
              style: TextStyle(
                fontSize: size.amountSize,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (breakdown != null && breakdown!.isNotEmpty) ...[
          SizedBox(height: size.spacing * 2),
          ...breakdown!.map((item) => _BreakdownItem(
                item: item,
                currency: currency,
                isDark: isDark,
              )),
        ],
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }
}

/// Size options for the amount display.
enum PaymentAmountSize {
  small,
  medium,
  large,
}

extension PaymentAmountSizeExtension on PaymentAmountSize {
  double get amountSize {
    switch (this) {
      case PaymentAmountSize.small:
        return 18;
      case PaymentAmountSize.medium:
        return 24;
      case PaymentAmountSize.large:
        return 32;
    }
  }

  double get currencySize {
    switch (this) {
      case PaymentAmountSize.small:
        return 14;
      case PaymentAmountSize.medium:
        return 16;
      case PaymentAmountSize.large:
        return 18;
    }
  }

  double get labelSize {
    switch (this) {
      case PaymentAmountSize.small:
        return 11;
      case PaymentAmountSize.medium:
        return 12;
      case PaymentAmountSize.large:
        return 14;
    }
  }

  double get spacing {
    switch (this) {
      case PaymentAmountSize.small:
        return 2;
      case PaymentAmountSize.medium:
        return 4;
      case PaymentAmountSize.large:
        return 6;
    }
  }
}

/// A breakdown item for showing payment details.
class AmountBreakdownItem {
  final String label;
  final double amount;
  final bool isDeduction;

  const AmountBreakdownItem({
    required this.label,
    required this.amount,
    this.isDeduction = false,
  });
}

class _BreakdownItem extends StatelessWidget {
  const _BreakdownItem({
    required this.item,
    required this.currency,
    required this.isDark,
  });

  final AmountBreakdownItem item;
  final String currency;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          Text(
            '${item.isDeduction ? "-" : ""}$currency ${item.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: item.isDeduction
                  ? AppColors.success
                  : (isDark ? Colors.grey[300] : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact amount display for use in lists or cards.
class PaymentAmountCompact extends StatelessWidget {
  const PaymentAmountCompact({
    super.key,
    required this.amount,
    this.currency = 'KES',
    this.textColor,
    this.fontSize = 16,
  });

  final double amount;
  final String currency;
  final Color? textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.onSurface;

    return Text(
      '$currency ${amount.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
