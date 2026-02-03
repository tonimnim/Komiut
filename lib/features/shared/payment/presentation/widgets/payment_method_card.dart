/// Payment method card widget.
///
/// Displays a selectable payment method option with icon, name,
/// description, and selection state.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Payment method types supported by the app.
enum PaymentMethodType {
  mpesa,
  wallet,
  card,
  split,
}

/// Extension to add display properties to PaymentMethodType.
extension PaymentMethodTypeExtension on PaymentMethodType {
  String get displayName {
    switch (this) {
      case PaymentMethodType.mpesa:
        return 'M-Pesa';
      case PaymentMethodType.wallet:
        return 'Wallet Balance';
      case PaymentMethodType.card:
        return 'Card';
      case PaymentMethodType.split:
        return 'Split Payment';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethodType.mpesa:
        return 'Pay via M-Pesa STK Push';
      case PaymentMethodType.wallet:
        return 'Pay from your wallet balance';
      case PaymentMethodType.card:
        return 'Visa, Mastercard, etc.';
      case PaymentMethodType.split:
        return 'Use wallet + M-Pesa';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.mpesa:
        return Icons.phone_android;
      case PaymentMethodType.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.split:
        return Icons.call_split;
    }
  }

  Color get iconColor {
    switch (this) {
      case PaymentMethodType.mpesa:
        return AppColors.primaryGreen; // M-Pesa green
      case PaymentMethodType.wallet:
        return AppColors.primaryBlue;
      case PaymentMethodType.card:
        return AppColors.secondaryPurple;
      case PaymentMethodType.split:
        return AppColors.secondaryOrange;
    }
  }
}

/// A card widget for displaying a payment method option.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.isEnabled = true,
    this.isComingSoon = false,
    this.subtitle,
  });

  /// The payment method type.
  final PaymentMethodType type;

  /// Whether this method is currently selected.
  final bool isSelected;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Whether the payment method is enabled.
  final bool isEnabled;

  /// Whether to show "Coming soon" badge.
  final bool isComingSoon;

  /// Optional subtitle to override the default description.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: isEnabled && !isComingSoon ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isDark ? AppColors.grey800 : AppColors.grey200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Opacity(
          opacity: isEnabled && !isComingSoon ? 1.0 : 0.5,
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: type.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type.icon,
                  color: type.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Coming soon',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle ?? type.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.grey400
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isEnabled && !isComingSoon)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : (isDark ? AppColors.grey600 : AppColors.grey400),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.white,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
