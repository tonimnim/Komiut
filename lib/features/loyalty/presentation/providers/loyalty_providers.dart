/// Loyalty feature providers.
///
/// Provides all loyalty-related state management and dependencies.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/loyalty_remote_datasource.dart';
import '../../data/models/loyalty_models.dart';
import '../../domain/entities/loyalty_points.dart';
import '../../domain/loyalty_rules.dart';

/// Provider for the current user's loyalty points.
///
/// Fetches and caches the user's loyalty points status.
final loyaltyPointsProvider = FutureProvider<LoyaltyPoints?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final dataSource = ref.watch(loyaltyRemoteDataSourceProvider);

  if (authState.user == null) return null;

  final result = await dataSource.getLoyaltyPoints();

  return result.fold(
    (failure) {
      // Return mock data for development/demo
      return LoyaltyPoints(
        userId: authState.user!.id.toString(),
        totalPoints: 1250,
        availablePoints: 1100,
        pendingPoints: 150,
        tier: LoyaltyTier.silver,
        pointsToNextTier: 750,
        nextTier: LoyaltyTier.gold,
        lifetimePoints: 1250,
        recentActivity: [
          PointsTransaction(
            id: '1',
            type: PointsTransactionType.earned,
            points: 50,
            description: 'Trip: CBD to Westlands',
            bookingId: 'booking-001',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          PointsTransaction(
            id: '2',
            type: PointsTransactionType.earned,
            points: 80,
            description: 'Trip: Westlands to Karen',
            bookingId: 'booking-002',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          PointsTransaction(
            id: '3',
            type: PointsTransactionType.redeemed,
            points: 200,
            description: 'Discount on booking',
            bookingId: 'booking-003',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
          ),
          PointsTransaction(
            id: '4',
            type: PointsTransactionType.bonus,
            points: 100,
            description: 'Welcome bonus',
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      );
    },
    (points) => points,
  );
});

/// Provider for points transaction history.
///
/// Supports pagination for loading more history.
final pointsHistoryProvider = FutureProvider.family<List<PointsTransaction>, int>(
  (ref, offset) async {
    final dataSource = ref.watch(loyaltyRemoteDataSourceProvider);

    final result = await dataSource.getPointsHistory(
      limit: 20,
      offset: offset,
    );

    return result.fold(
      (failure) => [],
      (transactions) => transactions,
    );
  },
);

/// Provider for redeeming points.
///
/// Returns a function to perform the redemption.
final redeemPointsProvider = Provider<
    Future<RedemptionResult> Function({
      required int points,
      required String bookingId,
    })>((ref) {
  return ({required int points, required String bookingId}) async {
    final dataSource = ref.read(loyaltyRemoteDataSourceProvider);

    final result = await dataSource.redeemPoints(
      points: points,
      bookingId: bookingId,
    );

    return result.fold(
      (failure) => RedemptionResult(
        success: false,
        pointsRedeemed: 0,
        discountValue: 0,
        remainingPoints: 0,
        message: failure.message,
      ),
      (redemption) {
        // Invalidate loyalty points to refresh after redemption
        ref.invalidate(loyaltyPointsProvider);
        return redemption;
      },
    );
  };
});

/// Provider for calculating points earned for a given amount.
///
/// Use with `.family` for different amounts.
final pointsEarnedForAmountProvider = Provider.family<int, double>((ref, amount) {
  final loyaltyPoints = ref.watch(loyaltyPointsProvider).valueOrNull;
  final tier = loyaltyPoints?.tier;

  return LoyaltyRules.calculatePointsEarned(amount, tier: tier);
});

/// Provider for calculating redemption value.
final redemptionValueProvider = Provider.family<double, int>((ref, points) {
  return LoyaltyRules.calculateRedemptionValue(points);
});

/// Provider for refreshing loyalty points.
final refreshLoyaltyProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(loyaltyPointsProvider);
  };
});

/// Provider for tier benefits.
final tierBenefitsProvider = Provider.family<List<String>, LoyaltyTier>((ref, tier) {
  return LoyaltyRules.getTierBenefits(tier);
});

/// State for redeem points form.
class RedeemPointsState {
  const RedeemPointsState({
    this.selectedPoints = 0,
    this.isLoading = false,
    this.error,
    this.result,
  });

  final int selectedPoints;
  final bool isLoading;
  final String? error;
  final RedemptionResult? result;

  double get discountValue => LoyaltyRules.calculateRedemptionValue(selectedPoints);

  RedeemPointsState copyWith({
    int? selectedPoints,
    bool? isLoading,
    String? error,
    RedemptionResult? result,
  }) {
    return RedeemPointsState(
      selectedPoints: selectedPoints ?? this.selectedPoints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result,
    );
  }
}

/// Notifier for redeem points state.
class RedeemPointsNotifier extends StateNotifier<RedeemPointsState> {
  RedeemPointsNotifier(this._ref) : super(const RedeemPointsState());

  final Ref _ref;

  void setPoints(int points) {
    state = state.copyWith(selectedPoints: points, error: null);
  }

  void incrementPoints(int amount, int maxPoints) {
    final newPoints = (state.selectedPoints + amount).clamp(0, maxPoints);
    state = state.copyWith(selectedPoints: newPoints, error: null);
  }

  void decrementPoints(int amount) {
    final newPoints = (state.selectedPoints - amount).clamp(0, state.selectedPoints);
    state = state.copyWith(selectedPoints: newPoints, error: null);
  }

  Future<bool> redeem(String bookingId) async {
    if (state.selectedPoints < LoyaltyRules.minimumRedemption) {
      state = state.copyWith(
        error: 'Minimum ${LoyaltyRules.minimumRedemption} points required',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    final redeemFn = _ref.read(redeemPointsProvider);
    final result = await redeemFn(
      points: state.selectedPoints,
      bookingId: bookingId,
    );

    if (result.success) {
      state = state.copyWith(isLoading: false, result: result);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.message ?? 'Redemption failed',
      );
      return false;
    }
  }

  void reset() {
    state = const RedeemPointsState();
  }
}

/// Provider for redeem points notifier.
final redeemPointsNotifierProvider =
    StateNotifierProvider<RedeemPointsNotifier, RedeemPointsState>((ref) {
  return RedeemPointsNotifier(ref);
});
