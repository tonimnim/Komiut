/// Earnings providers for managing driver earnings state.
///
/// Provides earnings summary, transaction history, and period selection
/// with Riverpod state management. Depends on dashboard providers
/// to get the driver's vehicleId.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/repositories/earnings_repository.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/earnings_transaction.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Time period for filtering earnings.
enum EarningsPeriod {
  today,
  thisWeek,
  thisMonth,
  allTime,
  custom;

  /// Display label for the period.
  String get label => switch (this) {
        EarningsPeriod.today => 'Today',
        EarningsPeriod.thisWeek => 'This Week',
        EarningsPeriod.thisMonth => 'This Month',
        EarningsPeriod.allTime => 'All Time',
        EarningsPeriod.custom => 'Custom',
      };

  /// Start date for the period.
  DateTime get startDate {
    final now = DateTime.now();
    return switch (this) {
      EarningsPeriod.today => DateTime(now.year, now.month, now.day),
      EarningsPeriod.thisWeek =>
        DateTime(now.year, now.month, now.day - now.weekday + 1),
      EarningsPeriod.thisMonth => DateTime(now.year, now.month, 1),
      EarningsPeriod.allTime => DateTime(2020, 1, 1), // Far past date
      EarningsPeriod.custom =>
        DateTime(now.year, now.month, now.day), // Default
    };
  }

  /// End date for the period (always today for preset periods).
  DateTime get endDate => DateTime.now();
}

// ─────────────────────────────────────────────────────────────────────────────
// State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the currently selected earnings period.
final selectedEarningsPeriodProvider = StateProvider<EarningsPeriod>(
  (ref) => EarningsPeriod.today,
);

/// Provider for custom date range start.
final customStartDateProvider = StateProvider<DateTime?>(
  (ref) => null,
);

/// Provider for custom date range end.
final customEndDateProvider = StateProvider<DateTime?>(
  (ref) => null,
);

// ─────────────────────────────────────────────────────────────────────────────
// Core Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for earnings summary.
///
/// Fetches the complete earnings summary using the driver's vehicleId.
/// Depends on [driverProfileProvider] to get the vehicleId.
///
/// Returns [EarningsSummary] entity or throws on error.
final earningsSummaryProvider = FutureProvider<EarningsSummary>((ref) async {
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    throw Exception('No vehicle assigned to captain');
  }

  final repository = ref.watch(earningsRepositoryProvider);
  final result = await repository.getEarningsSummary(profile.vehicleId!);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (summary) => summary,
  );
});

/// Notifier that accumulates earnings history pages.
class EarningsHistoryNotifier
    extends StateNotifier<AsyncValue<List<EarningsTransaction>>> {
  EarningsHistoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    _hasMore = true;
    await _fetchPage(1, replace: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    await _fetchPage(_currentPage + 1, replace: false);
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> _fetchPage(int page, {required bool replace}) async {
    try {
      final profile = await _ref.read(driverProfileProvider.future);
      if (!profile.hasVehicle) {
        state = AsyncValue.error(
            Exception('No vehicle assigned to captain'), StackTrace.current);
        return;
      }

      final period = _ref.read(selectedEarningsPeriodProvider);
      final customStart = _ref.read(customStartDateProvider);
      final customEnd = _ref.read(customEndDateProvider);

      final DateTime fromDate;
      final DateTime toDate;
      if (period == EarningsPeriod.custom && customStart != null) {
        fromDate = customStart;
        toDate = customEnd ?? DateTime.now();
      } else {
        fromDate = period.startDate;
        toDate = period.endDate;
      }

      final repository = _ref.read(earningsRepositoryProvider);
      final result = await repository.getEarningsHistory(
        vehicleId: profile.vehicleId!,
        fromDate: fromDate,
        toDate: toDate,
        pageNumber: page,
        pageSize: 20,
      );

      result.fold(
        (failure) {
          if (replace) {
            state = AsyncValue.error(
                Exception(failure.message), StackTrace.current);
          }
        },
        (newItems) {
          _currentPage = page;
          _hasMore = newItems.length >= 20;
          final existing =
              replace ? <EarningsTransaction>[] : (state.value ?? []);
          state = AsyncValue.data([...existing, ...newItems]);
        },
      );
    } catch (e, st) {
      if (replace) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

/// Provider for earnings transaction history with pagination accumulation.
final earningsHistoryProvider = StateNotifierProvider<EarningsHistoryNotifier,
    AsyncValue<List<EarningsTransaction>>>((ref) {
  // Re-create when period changes
  ref.watch(selectedEarningsPeriodProvider);
  return EarningsHistoryNotifier(ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// Pagination Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for whether there are more pages to load.
final hasMoreEarningsProvider = Provider<bool>((ref) {
  return ref.watch(earningsHistoryProvider.notifier).hasMore;
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived Providers (Performance Optimized)
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for today's earnings amount.
///
/// Use this on the home screen instead of full summary provider
/// to minimize rebuilds.
final todayEarningsProvider = Provider<AsyncValue<double>>((ref) {
  return ref
      .watch(earningsSummaryProvider)
      .whenData((summary) => summary.today);
});

/// Provider for today's earnings formatted for display.
final todayEarningsDisplayProvider = Provider<AsyncValue<String>>((ref) {
  return ref.watch(earningsSummaryProvider).whenData(
        (summary) => summary.displayToday,
      );
});

/// Provider for whether there is a pending payout.
final hasPendingPayoutProvider = Provider<bool>((ref) {
  final summaryAsync = ref.watch(earningsSummaryProvider);
  return summaryAsync.whenOrNull(
        data: (summary) => summary.hasPendingPayout,
      ) ??
      false;
});

/// Provider for the earnings amount based on selected period.
final selectedPeriodEarningsProvider = Provider<AsyncValue<double>>((ref) {
  final period = ref.watch(selectedEarningsPeriodProvider);
  return ref.watch(earningsSummaryProvider).whenData((summary) {
    return switch (period) {
      EarningsPeriod.today => summary.today,
      EarningsPeriod.thisWeek => summary.thisWeek,
      EarningsPeriod.thisMonth => summary.thisMonth,
      EarningsPeriod.allTime => summary.allTime,
      EarningsPeriod.custom => summary.today, // Will be calculated from history
    };
  });
});

/// Provider for total earnings from transaction history.
///
/// Calculates total from the current history list.
/// Useful for custom date ranges.
final historyTotalEarningsProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(earningsHistoryProvider).whenData((transactions) {
    return transactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  });
});

/// Provider for transaction count in current history.
final transactionCountProvider = Provider<int>((ref) {
  final historyAsync = ref.watch(earningsHistoryProvider);
  return historyAsync.whenOrNull(data: (transactions) => transactions.length) ??
      0;
});

// ─────────────────────────────────────────────────────────────────────────────
// Refresh Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Helper to refresh all earnings data.
///
/// Call this on pull-to-refresh or when returning to the earnings screen.
void refreshEarnings(WidgetRef ref) {
  ref.invalidate(earningsSummaryProvider);
  ref.read(earningsHistoryProvider.notifier).refresh();
}

/// Helper to load the next page of earnings history.
void loadMoreEarnings(WidgetRef ref) {
  ref.read(earningsHistoryProvider.notifier).loadMore();
}
