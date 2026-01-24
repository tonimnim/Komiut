/// Top-up processing screen.
///
/// Shows M-Pesa STK push status and payment confirmation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/topup_providers.dart';

/// Top-up processing screen.
///
/// Displays:
/// - Payment initiation status
/// - STK push waiting screen
/// - Payment confirmation polling
/// - Success/failure result
class TopupProcessingScreen extends ConsumerStatefulWidget {
  /// Creates a top-up processing screen.
  const TopupProcessingScreen({super.key});

  @override
  ConsumerState<TopupProcessingScreen> createState() =>
      _TopupProcessingScreenState();
}

class _TopupProcessingScreenState extends ConsumerState<TopupProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the top-up process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(topupStateProvider.notifier).initiateTopup();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDone() {
    // Go back to wallet/home
    context.go(RouteConstants.passengerHome);
  }

  void _onRetry() {
    // Go back to top-up screen
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topupState = ref.watch(topupStateProvider);

    return PopScope(
      canPop: topupState.isComplete,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            if (topupState.isComplete)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: _onDone,
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                _buildContent(topupState, isDark),
                const Spacer(),
                _buildBottomAction(topupState, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TopupState state, bool isDark) {
    switch (state.flowState) {
      case TopupFlowState.initial:
      case TopupFlowState.validating:
      case TopupFlowState.initiating:
        return _buildInitiatingContent(isDark);

      case TopupFlowState.awaitingStkPush:
        return _buildAwaitingStkContent(state, isDark);

      case TopupFlowState.polling:
        return _buildPollingContent(isDark);

      case TopupFlowState.success:
        return _buildSuccessContent(state, isDark);

      case TopupFlowState.failed:
      case TopupFlowState.cancelled:
        return _buildFailedContent(state, isDark);
    }
  }

  Widget _buildInitiatingContent(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                    strokeWidth: 3,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Initiating Payment',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Setting up your M-Pesa payment...',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAwaitingStkContent(TopupState state, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                  child: Icon(
                    Icons.phone_android,
                    color: AppColors.primaryGreen,
                    size: 56,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Check Your Phone',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'An M-Pesa prompt has been sent to your phone.\nEnter your M-Pesa PIN to complete the payment.',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'KES ${state.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPollingContent(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Confirming Payment',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please wait while we confirm your payment...',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessContent(TopupState state, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Center(
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 72,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Top-Up Successful!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your wallet has been credited',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Amount card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount Added',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'KES ${state.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              if (state.newBalance != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'KES ${state.newBalance!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
              if (state.receipt != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'M-Pesa Receipt',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      state.receipt!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFailedContent(TopupState state, bool isDark) {
    final isCancelled = state.flowState == TopupFlowState.cancelled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: (isCancelled ? Colors.orange : AppColors.error)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Center(
            child: Icon(
              isCancelled ? Icons.cancel_outlined : Icons.error_outline,
              color: isCancelled ? Colors.orange : AppColors.error,
              size: 72,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          isCancelled ? 'Payment Cancelled' : 'Payment Failed',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          state.errorMessage ??
              (isCancelled
                  ? 'You cancelled the payment'
                  : 'Something went wrong'),
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomAction(TopupState state, bool isDark) {
    if (state.flowState == TopupFlowState.success) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Done',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (state.flowState == TopupFlowState.failed ||
        state.flowState == TopupFlowState.cancelled) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: _onDone,
              style: TextButton.styleFrom(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Go Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Processing states - show cancel option
    return TextButton(
      onPressed: () {
        ref.read(topupStateProvider.notifier).cancel();
      },
      child: Text(
        'Cancel',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
        ),
      ),
    );
  }
}
