/// Payment method selection screen.
///
/// Allows users to select their preferred payment method for a booking,
/// including M-Pesa, wallet balance, or split payment.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../widgets/payment_method_card.dart';

/// Payment method selection screen.
class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({
    super.key,
    required this.bookingId,
  });

  /// The booking ID to pay for.
  final String bookingId;

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PaymentMethodType _selectedMethod = PaymentMethodType.mpesa;
  bool _useSplitPayment = false;
  double _walletAmount = 0;

  // Mock booking data - in production this would come from a provider
  late final _bookingAmount = 150.0;
  late final _currency = 'KES';

  @override
  void initState() {
    super.initState();
    _initPhoneNumber();
  }

  void _initPhoneNumber() {
    final user = ref.read(authStateProvider).user;
    if (user?.phone != null) {
      _phoneController.text = user!.phone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final walletAsync = ref.watch(walletProvider);
    final walletBalance = walletAsync.valueOrNull?.balance ?? 0;
    final hasSufficientBalance = walletBalance >= _bookingAmount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount card
                    _AmountCard(
                      amount: _bookingAmount,
                      currency: _currency,
                      walletBalance: walletBalance,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    // Payment methods section
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // M-Pesa option
                    PaymentMethodCard(
                      type: PaymentMethodType.mpesa,
                      isSelected: _selectedMethod == PaymentMethodType.mpesa && !_useSplitPayment,
                      onTap: () {
                        setState(() {
                          _selectedMethod = PaymentMethodType.mpesa;
                          _useSplitPayment = false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Wallet option
                    PaymentMethodCard(
                      type: PaymentMethodType.wallet,
                      isSelected: _selectedMethod == PaymentMethodType.wallet && !_useSplitPayment,
                      isEnabled: hasSufficientBalance,
                      subtitle: hasSufficientBalance
                          ? 'Balance: $_currency ${walletBalance.toStringAsFixed(0)}'
                          : 'Insufficient balance ($_currency ${walletBalance.toStringAsFixed(0)})',
                      onTap: () {
                        if (hasSufficientBalance) {
                          setState(() {
                            _selectedMethod = PaymentMethodType.wallet;
                            _useSplitPayment = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Split payment option (if wallet has some balance)
                    if (walletBalance > 0 && !hasSufficientBalance)
                      PaymentMethodCard(
                        type: PaymentMethodType.split,
                        isSelected: _useSplitPayment,
                        subtitle: 'Use wallet ($_currency ${walletBalance.toStringAsFixed(0)}) + M-Pesa',
                        onTap: () {
                          setState(() {
                            _useSplitPayment = true;
                            _walletAmount = walletBalance;
                          });
                        },
                      ),
                    if (walletBalance > 0 && !hasSufficientBalance)
                      const SizedBox(height: 12),

                    // Card option (coming soon)
                    PaymentMethodCard(
                      type: PaymentMethodType.card,
                      isSelected: false,
                      isComingSoon: true,
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),

                    // Phone number input for M-Pesa
                    if (_selectedMethod == PaymentMethodType.mpesa || _useSplitPayment) ...[
                      Text(
                        'M-Pesa Phone Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PhoneNumberInput(
                        controller: _phoneController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will receive an M-Pesa prompt on this number',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : AppColors.textHint,
                        ),
                      ),
                    ],

                    // Split payment breakdown
                    if (_useSplitPayment) ...[
                      const SizedBox(height: 24),
                      _SplitPaymentBreakdown(
                        totalAmount: _bookingAmount,
                        walletAmount: _walletAmount,
                        currency: _currency,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom bar with pay button
            _PaymentBottomBar(
              amount: _useSplitPayment
                  ? _bookingAmount - _walletAmount
                  : (_selectedMethod == PaymentMethodType.wallet ? _bookingAmount : _bookingAmount),
              currency: _currency,
              paymentMethod: _useSplitPayment ? 'Split Payment' : _selectedMethod.displayName,
              isDark: isDark,
              onPay: () => _processPayment(context),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) {
    if (_selectedMethod == PaymentMethodType.mpesa || _useSplitPayment) {
      if (!_formKey.currentState!.validate()) return;
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your M-Pesa phone number'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    HapticFeedback.mediumImpact();

    // Navigate to processing screen
    context.push(RouteConstants.passengerPaymentProcessingPath(widget.bookingId));
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.amount,
    required this.currency,
    required this.walletBalance,
    required this.isDark,
  });

  final double amount;
  final String currency;
  final double walletBalance;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount to Pay',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currency ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                'Wallet Balance: $currency ${walletBalance.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhoneNumberInput extends StatelessWidget {
  const _PhoneNumberInput({
    required this.controller,
    required this.isDark,
  });

  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        }
        if (value.length < 9) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: '07XX XXX XXX',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(color: Colors.black),
                    ),
                    Expanded(
                      child: Container(color: Colors.red),
                    ),
                    Expanded(
                      child: Container(color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+254',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}


class _SplitPaymentBreakdown extends StatelessWidget {
  const _SplitPaymentBreakdown({
    required this.totalAmount,
    required this.walletAmount,
    required this.currency,
    required this.isDark,
  });

  final double totalAmount;
  final double walletAmount;
  final String currency;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mpesaAmount = totalAmount - walletAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.grey300 : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '-$currency ${walletAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_android,
                    size: 18,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'M-Pesa',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.grey300 : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '$currency ${mpesaAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: isDark ? AppColors.grey700 : AppColors.grey300),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '$currency ${totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentBottomBar extends StatelessWidget {
  const _PaymentBottomBar({
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.isDark,
    required this.onPay,
  });

  final double amount;
  final String currency;
  final String paymentMethod;
  final bool isDark;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    paymentMethod,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.grey400 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currency ${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
