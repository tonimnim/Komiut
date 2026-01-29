/// Loyalty screen.
///
/// Main screen for viewing and managing loyalty points.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/loyalty_points.dart';
import '../providers/loyalty_providers.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_transaction_item.dart';
import '../widgets/redeem_points_sheet.dart';
import '../widgets/tier_benefits_card.dart';
import '../widgets/tier_progress_bar.dart';

/// Main loyalty points screen.
///
/// Displays:
/// - Points balance with tier
/// - Progress to next tier
/// - Recent activity
/// - How it works section
class LoyaltyScreen extends ConsumerWidget {
  /// Creates a loyalty screen.
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyaltyAsync = ref.watch(loyaltyPointsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Loyalty Points',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => _showHelpSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(loyaltyPointsProvider);
        },
        child: loyaltyAsync.when(
          data: (loyalty) => _buildContent(context, ref, loyalty),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(context, ref, error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, LoyaltyPoints? loyalty) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (loyalty == null) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points balance card
          PointsBalanceCard(
            loyaltyPoints: loyalty,
            onRedeemPressed: loyalty.hasRedeemablePoints
                ? () => _showRedeemSheet(context, loyalty.availablePoints)
                : null,
          ),
          const SizedBox(height: 24),

          // Tier progress
          TierProgressBar(loyaltyPoints: loyalty),
          const SizedBox(height: 24),

          // Quick actions
          _QuickActionsRow(
            onRedeemPressed: loyalty.hasRedeemablePoints
                ? () => _showRedeemSheet(context, loyalty.availablePoints)
                : null,
            onHistoryPressed: () => _showFullHistory(context, ref),
          ),
          const SizedBox(height: 24),

          // Recent activity section
          _buildSectionHeader(
            context,
            'Recent Activity',
            onSeeAllPressed: () => _showFullHistory(context, ref),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PointsTransactionList(
              transactions: loyalty.recentActivity?.take(5).toList() ?? [],
            ),
          ),
          const SizedBox(height: 24),

          // Your tier benefits
          _buildSectionHeader(context, 'Your Tier Benefits'),
          const SizedBox(height: 12),
          TierBenefitsCard(
            tier: loyalty.tier,
            isCurrentTier: true,
          ),
          const SizedBox(height: 24),

          // How it works
          const HowItWorksSection(),
          const SizedBox(height: 24),

          // All tiers comparison
          _buildSectionHeader(context, 'All Tiers'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAllPressed,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (onSeeAllPressed != null)
          TextButton(
            onPressed: onSeeAllPressed,
            child: Text(
              'See all',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stars_rounded,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Start Earning Points',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Take your first trip to start earning loyalty points and unlock rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/passenger/home'),
              icon: const Icon(Icons.directions_bus),
              label: const Text('Book a Trip'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(loyaltyPointsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemSheet(BuildContext context, int availablePoints) {
    RedeemPointsSheet.show(
      context: context,
      availablePoints: availablePoints,
      bookingId: 'demo-booking', // In real app, this would be an actual booking ID
      onRedeemed: (points, discount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redeemed $points points for KES ${discount.toStringAsFixed(0)} discount!'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  void _showFullHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FullHistorySheet(),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const HowItWorksSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Quick actions row.
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    this.onRedeemPressed,
    this.onHistoryPressed,
  });

  final VoidCallback? onRedeemPressed;
  final VoidCallback? onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.redeem,
            label: 'Redeem Points',
            onTap: onRedeemPressed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.history,
            label: 'Full History',
            onTap: onHistoryPressed,
          ),
        ),
      ],
    );
  }
}

/// Quick action card.
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: onTap != null
                    ? theme.colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onTap != null
                      ? theme.colorScheme.onSurface
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full history bottom sheet.
class _FullHistorySheet extends ConsumerWidget {
  const _FullHistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final historyAsync = ref.watch(pointsHistoryProvider(0));
    final loyaltyAsync = ref.watch(loyaltyPointsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Points History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // History list
              Expanded(
                child: historyAsync.when(
                  data: (transactions) {
                    // Combine with recent activity from loyalty points
                    final allTransactions = transactions.isNotEmpty
                        ? transactions
                        : loyaltyAsync.valueOrNull?.recentActivity ?? [];

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: allTransactions.length,
                      itemBuilder: (context, index) {
                        return PointsTransactionItem(
                          transaction: allTransactions[index],
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(
                    child: Text('Unable to load history'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
