/// Amount selector widget for top-up flow.
///
/// Provides quick amount buttons and custom amount input.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../providers/topup_providers.dart';

/// Quick amount selection button.
class QuickAmountButton extends StatelessWidget {
  /// Creates a quick amount button.
  const QuickAmountButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Amount value.
  final int amount;

  /// Whether this amount is selected.
  final bool isSelected;

  /// Callback when tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 1.5,
          ),
        ),
        child: Text(
          'KES $amount',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[300] : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Amount selector widget.
///
/// Shows quick amount buttons and custom input field.
class AmountSelector extends StatefulWidget {
  /// Creates an amount selector.
  const AmountSelector({
    required this.selectedAmount,
    required this.onAmountChanged,
    this.quickAmounts = quickTopupAmounts,
    this.minAmount = minTopupAmount,
    this.maxAmount = maxTopupAmount,
    this.currency = 'KES',
    super.key,
  });

  /// Currently selected amount.
  final double selectedAmount;

  /// Callback when amount changes.
  final ValueChanged<double> onAmountChanged;

  /// Quick selection amounts.
  final List<int> quickAmounts;

  /// Minimum allowed amount.
  final double minAmount;

  /// Maximum allowed amount.
  final double maxAmount;

  /// Currency code.
  final String currency;

  @override
  State<AmountSelector> createState() => _AmountSelectorState();
}

class _AmountSelectorState extends State<AmountSelector> {
  late TextEditingController _controller;
  bool _isCustomAmount = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.selectedAmount > 0 &&
        !widget.quickAmounts.contains(widget.selectedAmount.toInt())) {
      _controller.text = widget.selectedAmount.toStringAsFixed(0);
      _isCustomAmount = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQuickAmountTap(int amount) {
    setState(() {
      _isCustomAmount = false;
      _controller.clear();
    });
    widget.onAmountChanged(amount.toDouble());
  }

  void _onCustomAmountChanged(String value) {
    setState(() {
      _isCustomAmount = value.isNotEmpty;
    });
    final amount = double.tryParse(value) ?? 0;
    widget.onAmountChanged(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick amount buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.quickAmounts.map((amount) {
            final isSelected =
                !_isCustomAmount && widget.selectedAmount == amount.toDouble();
            return QuickAmountButton(
              amount: amount,
              isSelected: isSelected,
              onTap: () => _onQuickAmountTap(amount),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Custom amount input
        Text(
          'Or enter custom amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isCustomAmount
                  ? AppColors.primaryBlue
                  : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  widget.currency,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  onChanged: _onCustomAmountChanged,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Amount limits hint
        Text(
          'Min: ${widget.currency} ${widget.minAmount.toInt()} - Max: ${widget.currency} ${widget.maxAmount.toInt()}',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

/// Large balance display widget.
class BalanceDisplay extends StatelessWidget {
  /// Creates a balance display.
  const BalanceDisplay({
    required this.balance,
    this.currency = 'KES',
    this.label = 'Current Balance',
    super.key,
  });

  /// Current balance.
  final double balance;

  /// Currency code.
  final String currency;

  /// Label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$currency ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
