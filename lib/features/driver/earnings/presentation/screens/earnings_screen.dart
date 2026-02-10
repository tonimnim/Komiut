/// Driver earnings screen.
///
/// Shows the driver's earnings and financial summary:
/// - Today's earnings breakdown
/// - Weekly/monthly summary
/// - Earnings history with charts
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/cards/app_card.dart';
import '../../../../../core/widgets/cards/stat_card.dart';
import '../../../../../core/widgets/feedback/app_error.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/earnings_transaction.dart';
import '../providers/earnings_providers.dart';

/// Earnings screen widget (standalone).
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EarningsContent());
  }
}

/// Earnings content widget (without navigation shell).
///
/// Used by [DriverMainNavigation] in IndexedStack.
class EarningsContent extends ConsumerStatefulWidget {
  const EarningsContent({super.key});

  @override
  ConsumerState<EarningsContent> createState() => _EarningsContentState();
}

class _EarningsContentState extends ConsumerState<EarningsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Earnings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_month,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                  onPressed: () => _showDateRangePicker(context),
                ),
              ],
            ),
          ),
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  isDark ? Colors.grey[400] : AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'History'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_OverviewTab(), _HistoryTab()],
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    ).then((range) {
      if (range != null) {
        ref.read(selectedEarningsPeriodProvider.notifier).state =
            EarningsPeriod.custom;
        ref.read(customStartDateProvider.notifier).state = range.start;
        ref.read(customEndDateProvider.notifier).state = range.end;
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overview Tab
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(earningsSummaryProvider);

    return RefreshIndicator(
      onRefresh: () async => refreshEarnings(ref),
      child: summaryAsync.when(
        loading: () => const _OverviewLoading(),
        error: (error, _) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppErrorWidget(
              title: 'Failed to load earnings',
              message: error.toString().replaceAll('Exception: ', ''),
              type: ErrorType.server,
              onRetry: () => ref.invalidate(earningsSummaryProvider),
            ),
          ),
        ),
        data: (summary) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              const _PeriodSelector(),
              const SizedBox(height: 24),

              // Total Earnings Card
              _TotalEarningsCard(summary: summary),
              const SizedBox(height: 24),

              // Period Stats
              _PeriodStatsSection(summary: summary),
              const SizedBox(height: 24),

              // Quick Stats
              const _SectionHeader(title: 'Summary'),
              const SizedBox(height: 12),
              _QuickStatsCard(summary: summary),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector shimmer
          Row(
            children: List.generate(
              4,
              (i) => const Padding(
                padding: EdgeInsets.only(right: 8),
                child: ShimmerBox(width: 80, height: 32, borderRadius: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Main card shimmer
          const ShimmerCard(height: 180, margin: EdgeInsets.zero),
          const SizedBox(height: 24),
          // Stats shimmer
          const Row(
            children: [
              Expanded(
                child: ShimmerCard(height: 100, margin: EdgeInsets.zero),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerCard(height: 100, margin: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: ShimmerCard(height: 100, margin: EdgeInsets.zero),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerCard(height: 100, margin: EdgeInsets.zero),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedEarningsPeriodProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: EarningsPeriod.values
            .where((p) => p != EarningsPeriod.custom)
            .map((period) {
          final isSelected = selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedEarningsPeriodProvider.notifier).state =
                      period;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TotalEarningsCard extends ConsumerWidget {
  const _TotalEarningsCard({required this.summary});

  final EarningsSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedEarningsPeriodProvider);

    // Get the right amount based on period
    final amount = switch (selectedPeriod) {
      EarningsPeriod.today => summary.displayToday,
      EarningsPeriod.thisWeek => summary.displayWeekly,
      EarningsPeriod.thisMonth => summary.displayMonthly,
      EarningsPeriod.allTime => summary.displayAllTime,
      EarningsPeriod.custom => summary.displayToday,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            selectedPeriod.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (summary.hasPendingPayout) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Pending: ${summary.currency} ${summary.pendingPayout.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodStatsSection extends StatelessWidget {
  const _PeriodStatsSection({required this.summary});

  final EarningsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Today',
                value: summary.displayToday,
                icon: Icons.today,
                valueColor: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'This Week',
                value: summary.displayWeekly,
                icon: Icons.date_range,
                valueColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'This Month',
                value: summary.displayMonthly,
                icon: Icons.calendar_month,
                valueColor: AppColors.secondaryOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'All Time',
                value: summary.displayAllTime,
                icon: Icons.all_inclusive,
                valueColor: AppColors.secondaryPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard({required this.summary});

  final EarningsSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _StatRow(
            label: 'Pending Payout',
            value: summary.hasPendingPayout
                ? '${summary.currency} ${summary.pendingPayout.toStringAsFixed(2)}'
                : 'None',
          ),
          const Divider(),
          _StatRow(
            label: 'Last Payout',
            value: summary.lastPayoutAmount != null
                ? '${summary.currency} ${summary.lastPayoutAmount!.toStringAsFixed(2)}'
                : 'N/A',
          ),
          if (summary.lastPayoutDate != null) ...[
            const Divider(),
            _StatRow(
              label: 'Last Payout Date',
              value: _formatDate(summary.lastPayoutDate!),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Tab
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(earningsHistoryProvider);
    final hasMore = ref.watch(hasMoreEarningsProvider);

    return RefreshIndicator(
      onRefresh: () async => refreshEarnings(ref),
      child: historyAsync.when(
        loading: () => const _HistoryLoading(),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Failed to load history',
            message: error.toString().replaceAll('Exception: ', ''),
            type: ErrorType.server,
            onRetry: () => ref.invalidate(earningsHistoryProvider),
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your earnings history will appear here',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == transactions.length) {
                return Center(
                  child: TextButton(
                    onPressed: () => loadMoreEarnings(ref),
                    child: const Text('Load More'),
                  ),
                );
              }

              final transaction = transactions[index];
              return _TransactionItem(transaction: transaction);
            },
          );
        },
      ),
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: ShimmerListTile(hasTrailing: true),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final EarningsTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount >= 0;
    final color = isPositive ? AppColors.primaryGreen : AppColors.error;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? transaction.typeName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(transaction.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (transactionDate == today) {
      dateStr = 'Today';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dt.day}/${dt.month}/${dt.year}';
    }

    return '$dateStr at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Components
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
