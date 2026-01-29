/// Top-up screen for wallet.
///
/// Allows users to add money to their wallet via M-Pesa.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../providers/topup_providers.dart';
import '../widgets/amount_selector.dart';

/// Top-up screen.
///
/// Displays:
/// - Current balance
/// - Quick amount selection
/// - Custom amount input
/// - Phone number input for M-Pesa
/// - Top-up button
class TopupScreen extends ConsumerStatefulWidget {
  /// Creates a top-up screen.
  const TopupScreen({super.key});

  @override
  ConsumerState<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends ConsumerState<TopupScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Reset state when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(topupStateProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onAmountChanged(double amount) {
    ref.read(topupStateProvider.notifier).setAmount(amount);
  }

  void _onTopupPressed() {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    ref.read(topupStateProvider.notifier).setPhoneNumber(phone);

    // Navigate to processing screen
    context.push(RouteConstants.passengerWalletTopupProcess);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final walletAsync = ref.watch(walletProvider);
    final topupState = ref.watch(topupStateProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Top Up Wallet',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current balance
              walletAsync.when(
                data: (wallet) => BalanceDisplay(
                  balance: wallet?.balance ?? 0,
                  currency: wallet?.currency ?? 'KES',
                ),
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => BalanceDisplay(
                  balance: 0,
                  currency: 'KES',
                ),
              ),

              const SizedBox(height: 32),

              // Amount selection
              Text(
                'Select Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              AmountSelector(
                selectedAmount: topupState.amount,
                onAmountChanged: _onAmountChanged,
              ),

              const SizedBox(height: 32),

              // Payment method
              Text(
                'Payment Method',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // M-Pesa option (only option for now)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    // M-Pesa logo placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'M-Pesa',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pay with your Safaricom M-Pesa',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDark ? Colors.grey[400] : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Phone number input
              Text(
                'M-Pesa Phone Number',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  hintText: '07XX XXX XXX',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+254 ',
                  prefixStyle: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your M-Pesa phone number';
                  }
                  // Remove leading 0 if present for validation
                  final cleaned = value.startsWith('0') ? value.substring(1) : value;
                  if (cleaned.length < 9) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              Text(
                'You will receive an M-Pesa prompt to confirm payment',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                ),
              ),

              const SizedBox(height: 32),

              // Error message
              if (topupState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          topupState.errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount summary
              if (topupState.amount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top-up Amount',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'KES ${topupState.amount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Top-up button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: topupState.amount >= minTopupAmount &&
                          topupState.amount <= maxTopupAmount
                      ? _onTopupPressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        isDark ? Colors.grey[700] : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
