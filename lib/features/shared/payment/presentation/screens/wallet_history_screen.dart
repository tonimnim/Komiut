/// Wallet transaction history screen.
///
/// Displays list of all wallet transactions with filtering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../providers/topup_providers.dart';
import '../widgets/amount_selector.dart';
import '../widgets/transaction_list_item.dart';

/// Wallet history screen.
///
/// Shows:
/// - Current balance header
/// - Filter tabs (All, Top-ups, Payments, Refunds)
/// - Transaction list with infinite scroll
class WalletHistoryScreen extends ConsumerStatefulWidget {
  /// Creates a wallet history screen.
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near the bottom
      final notifier = ref.read(allTransactionsProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  void _onFilterChanged(TransactionFilter filter) {
    ref.read(transactionFilterProvider.notifier).state = filter;
    ref.read(allTransactionsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final currentFilter = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Transaction History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            centerTitle: false,
          ),

          // Balance card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: walletAsync.when(
                data: (wallet) => BalanceDisplay(
                  balance: wallet?.balance ?? 0,
                  currency: wallet?.currency ?? 'KES',
                ),
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => const BalanceDisplay(
                  balance: 0,
                  currency: 'KES',
                ),
              ),
            ),
          ),

          // Filter tabs
          SliverToBoxAdapter(
            child: _FilterTabs(
              currentFilter: currentFilter,
              onFilterChanged: _onFilterChanged,
            ),
          ),

          // Transactions list
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(filter: currentFilter),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= transactions.length) {
                      // Loading indicator at bottom
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      );
                    }

                    final transaction = transactions[index];
                    return TransactionListItem(
                      transaction: transaction,
                      showDivider: index < transactions.length - 1,
                      onTap: () =>
                          TransactionDetailSheet.show(context, transaction),
                    );
                  },
                  childCount: transactions.length +
                      (ref.read(allTransactionsProvider.notifier).hasMore
                          ? 1
                          : 0),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
                    ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
                    ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
                    ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
                    ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
                  ],
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: AppErrorWidget(
                title: 'Failed to load transactions',
                message: error.toString(),
                type: ErrorType.server,
                onRetry: () =>
                    ref.read(allTransactionsProvider.notifier).refresh(),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}

/// Filter tabs widget.
class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final TransactionFilter currentFilter;
  final ValueChanged<TransactionFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            isSelected: currentFilter == TransactionFilter.all,
            onTap: () => onFilterChanged(TransactionFilter.all),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Top-ups',
            isSelected: currentFilter == TransactionFilter.topups,
            onTap: () => onFilterChanged(TransactionFilter.topups),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Payments',
            isSelected: currentFilter == TransactionFilter.payments,
            onTap: () => onFilterChanged(TransactionFilter.payments),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Refunds',
            isSelected: currentFilter == TransactionFilter.refunds,
            onTap: () => onFilterChanged(TransactionFilter.refunds),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// Filter chip widget.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
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

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String message;
    IconData icon;

    switch (filter) {
      case TransactionFilter.all:
        message = 'No transactions yet';
        icon = Icons.receipt_long_outlined;
        break;
      case TransactionFilter.topups:
        message = 'No top-ups yet';
        icon = Icons.add_circle_outline;
        break;
      case TransactionFilter.payments:
        message = 'No payments yet';
        icon = Icons.directions_bus_outlined;
        break;
      case TransactionFilter.refunds:
        message = 'No refunds yet';
        icon = Icons.replay;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (filter == TransactionFilter.all ||
              filter == TransactionFilter.topups)
            Text(
              'Top up your wallet to get started',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : AppColors.textHint,
              ),
            ),
        ],
      ),
    );
  }
}
