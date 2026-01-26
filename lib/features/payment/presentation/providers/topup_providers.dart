/// Top-up feature providers.
///
/// Provides state management for wallet top-up flow.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/datasources/wallet_remote_datasource.dart';
import '../../../home/data/models/wallet_api_model.dart';
import '../../../home/domain/entities/wallet_entity.dart';
import '../../../home/presentation/providers/home_providers.dart';

/// Top-up flow state.
enum TopupFlowState {
  /// Initial state - entering amount
  initial,

  /// Validating input
  validating,

  /// Initiating top-up (sending to server)
  initiating,

  /// Waiting for STK push prompt on user's phone
  awaitingStkPush,

  /// Polling for payment confirmation
  polling,

  /// Top-up completed successfully
  success,

  /// Top-up failed
  failed,

  /// Top-up cancelled by user
  cancelled,
}

/// Top-up state holder.
class TopupState {
  const TopupState({
    this.flowState = TopupFlowState.initial,
    this.amount = 0,
    this.phoneNumber = '',
    this.transactionId,
    this.checkoutRequestId,
    this.errorMessage,
    this.receipt,
    this.newBalance,
  });

  /// Current flow state.
  final TopupFlowState flowState;

  /// Selected amount.
  final double amount;

  /// Phone number for M-Pesa.
  final String phoneNumber;

  /// Transaction ID from server.
  final String? transactionId;

  /// M-Pesa checkout request ID.
  final String? checkoutRequestId;

  /// Error message if failed.
  final String? errorMessage;

  /// M-Pesa receipt number on success.
  final String? receipt;

  /// New wallet balance after successful top-up.
  final double? newBalance;

  /// Whether currently processing.
  bool get isProcessing =>
      flowState == TopupFlowState.initiating ||
      flowState == TopupFlowState.awaitingStkPush ||
      flowState == TopupFlowState.polling;

  /// Whether completed (success or failure).
  bool get isComplete =>
      flowState == TopupFlowState.success ||
      flowState == TopupFlowState.failed ||
      flowState == TopupFlowState.cancelled;

  /// Create a copy with updated fields.
  TopupState copyWith({
    TopupFlowState? flowState,
    double? amount,
    String? phoneNumber,
    String? transactionId,
    String? checkoutRequestId,
    String? errorMessage,
    String? receipt,
    double? newBalance,
  }) {
    return TopupState(
      flowState: flowState ?? this.flowState,
      amount: amount ?? this.amount,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      transactionId: transactionId ?? this.transactionId,
      checkoutRequestId: checkoutRequestId ?? this.checkoutRequestId,
      errorMessage: errorMessage ?? this.errorMessage,
      receipt: receipt ?? this.receipt,
      newBalance: newBalance ?? this.newBalance,
    );
  }
}

/// Top-up amount provider.
///
/// Holds the currently selected top-up amount.
final topupAmountProvider = StateProvider<double>((ref) => 0);

/// Top-up phone number provider.
final topupPhoneNumberProvider = StateProvider<String>((ref) => '');

/// Top-up state notifier provider.
final topupStateProvider =
    StateNotifierProvider<TopupStateNotifier, TopupState>((ref) {
  return TopupStateNotifier(ref);
});

/// Top-up state notifier.
///
/// Manages the top-up flow state machine.
class TopupStateNotifier extends StateNotifier<TopupState> {
  TopupStateNotifier(this.ref) : super(const TopupState());

  final Ref ref;
  Timer? _pollingTimer;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 60; // 60 attempts at 3 seconds = 3 minutes
  static const Duration _pollInterval = Duration(seconds: 3);

  /// Reset state to initial.
  void reset() {
    _cancelPolling();
    state = const TopupState();
  }

  /// Set the amount.
  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  /// Set the phone number.
  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  /// Initiate the top-up.
  Future<void> initiateTopup() async {
    if (state.amount < 50) {
      state = state.copyWith(
        flowState: TopupFlowState.failed,
        errorMessage: 'Minimum top-up amount is KES 50',
      );
      return;
    }

    if (state.amount > 10000) {
      state = state.copyWith(
        flowState: TopupFlowState.failed,
        errorMessage: 'Maximum top-up amount is KES 10,000',
      );
      return;
    }

    if (state.phoneNumber.isEmpty) {
      state = state.copyWith(
        flowState: TopupFlowState.failed,
        errorMessage: 'Please enter your M-Pesa phone number',
      );
      return;
    }

    // Start initiating
    state = state.copyWith(flowState: TopupFlowState.initiating);

    final dataSource = ref.read(walletRemoteDataSourceProvider);
    final result = await dataSource.topUp(
      amount: state.amount,
      paymentMethod: 'mpesa',
      phoneNumber: state.phoneNumber,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          flowState: TopupFlowState.failed,
          errorMessage: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          flowState: TopupFlowState.awaitingStkPush,
          transactionId: response.transactionId,
          checkoutRequestId: response.checkoutRequestId,
        );

        // Start polling after a short delay (give user time to enter PIN)
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && state.flowState == TopupFlowState.awaitingStkPush) {
            state = state.copyWith(flowState: TopupFlowState.polling);
            _startPolling();
          }
        });
      },
    );
  }

  /// Start polling for payment status.
  void _startPolling() {
    _pollAttempts = 0;
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _pollStatus());
  }

  /// Cancel polling.
  void _cancelPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollAttempts = 0;
  }

  /// Poll for status.
  Future<void> _pollStatus() async {
    if (!mounted) {
      _cancelPolling();
      return;
    }

    _pollAttempts++;

    if (_pollAttempts > _maxPollAttempts) {
      _cancelPolling();
      state = state.copyWith(
        flowState: TopupFlowState.failed,
        errorMessage: 'Payment verification timed out. Please check your M-Pesa messages.',
      );
      return;
    }

    final transactionId = state.transactionId;
    if (transactionId == null) {
      _cancelPolling();
      return;
    }

    final dataSource = ref.read(walletRemoteDataSourceProvider);
    final result = await dataSource.getTopUpStatus(transactionId);

    result.fold(
      (failure) {
        // Continue polling on network errors
        // Only fail on final status errors
      },
      (status) {
        switch (status.status) {
          case TopUpStatus.completed:
            _cancelPolling();
            state = state.copyWith(
              flowState: TopupFlowState.success,
              receipt: status.mpesaReceiptNumber,
              newBalance: status.balanceAfter,
            );
            // Refresh wallet
            ref.invalidate(walletProvider);
            break;

          case TopUpStatus.failed:
            _cancelPolling();
            state = state.copyWith(
              flowState: TopupFlowState.failed,
              errorMessage: status.message ?? 'Payment failed',
            );
            break;

          case TopUpStatus.cancelled:
            _cancelPolling();
            state = state.copyWith(
              flowState: TopupFlowState.cancelled,
              errorMessage: 'Payment was cancelled',
            );
            break;

          case TopUpStatus.pending:
            // Continue polling
            break;
        }
      },
    );
  }

  /// Cancel the current top-up.
  void cancel() {
    _cancelPolling();
    state = state.copyWith(flowState: TopupFlowState.cancelled);
  }

  @override
  void dispose() {
    _cancelPolling();
    super.dispose();
  }
}

/// Wallet transactions filter.
enum TransactionFilter {
  all,
  topups,
  payments,
  refunds,
}

/// Current transaction filter provider.
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

/// Wallet transactions provider.
///
/// Fetches paginated wallet transactions.
final walletTransactionsProvider = FutureProvider.family<List<WalletTransaction>, int>((ref, offset) async {
  final dataSource = ref.watch(walletRemoteDataSourceProvider);
  final filter = ref.watch(transactionFilterProvider);

  TransactionType? type;
  switch (filter) {
    case TransactionFilter.all:
      type = null;
      break;
    case TransactionFilter.topups:
      type = TransactionType.topup;
      break;
    case TransactionFilter.payments:
      type = TransactionType.payment;
      break;
    case TransactionFilter.refunds:
      type = TransactionType.refund;
      break;
  }

  final result = await dataSource.getTransactions(
    limit: 20,
    offset: offset,
    type: type,
  );

  return result.fold(
    (failure) => [],
    (transactions) => transactions,
  );
});

/// All loaded transactions provider.
///
/// Accumulates transactions as user scrolls.
final allTransactionsProvider = StateNotifierProvider<AllTransactionsNotifier, AsyncValue<List<WalletTransaction>>>((ref) {
  return AllTransactionsNotifier(ref);
});

/// All transactions state notifier.
class AllTransactionsNotifier extends StateNotifier<AsyncValue<List<WalletTransaction>>> {
  AllTransactionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  final Ref ref;
  int _offset = 0;
  bool _hasMore = true;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;

  Future<void> _loadInitial() async {
    _offset = 0;
    _hasMore = true;

    final dataSource = ref.read(walletRemoteDataSourceProvider);
    final filter = ref.read(transactionFilterProvider);

    TransactionType? type;
    switch (filter) {
      case TransactionFilter.all:
        type = null;
        break;
      case TransactionFilter.topups:
        type = TransactionType.topup;
        break;
      case TransactionFilter.payments:
        type = TransactionType.payment;
        break;
      case TransactionFilter.refunds:
        type = TransactionType.refund;
        break;
    }

    final result = await dataSource.getTransactions(
      limit: _pageSize,
      offset: 0,
      type: type,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (transactions) {
        _hasMore = transactions.length >= _pageSize;
        _offset = transactions.length;
        state = AsyncValue.data(transactions);
      },
    );
  }

  /// Load more transactions.
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentTransactions = state.valueOrNull ?? [];

    final dataSource = ref.read(walletRemoteDataSourceProvider);
    final filter = ref.read(transactionFilterProvider);

    TransactionType? type;
    switch (filter) {
      case TransactionFilter.all:
        type = null;
        break;
      case TransactionFilter.topups:
        type = TransactionType.topup;
        break;
      case TransactionFilter.payments:
        type = TransactionType.payment;
        break;
      case TransactionFilter.refunds:
        type = TransactionType.refund;
        break;
    }

    final result = await dataSource.getTransactions(
      limit: _pageSize,
      offset: _offset,
      type: type,
    );

    result.fold(
      (failure) {
        // Keep current data, just stop loading more
        _hasMore = false;
      },
      (newTransactions) {
        _hasMore = newTransactions.length >= _pageSize;
        _offset += newTransactions.length;
        state = AsyncValue.data([...currentTransactions, ...newTransactions]);
      },
    );
  }

  /// Refresh transactions.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadInitial();
  }
}

/// Quick top-up amounts.
const List<int> quickTopupAmounts = [100, 200, 500, 1000];

/// Minimum top-up amount.
const double minTopupAmount = 50;

/// Maximum top-up amount.
const double maxTopupAmount = 10000;

/// Validate top-up amount.
String? validateTopupAmount(double? amount) {
  if (amount == null || amount <= 0) {
    return 'Please enter an amount';
  }
  if (amount < minTopupAmount) {
    return 'Minimum amount is KES ${minTopupAmount.toInt()}';
  }
  if (amount > maxTopupAmount) {
    return 'Maximum amount is KES ${maxTopupAmount.toInt()}';
  }
  return null;
}
