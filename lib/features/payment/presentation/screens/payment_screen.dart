import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_entity.dart';
import '../providers/payment_providers.dart';
import '../widgets/payment_tile.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentContent();
  }
}

class PaymentContent extends ConsumerStatefulWidget {
  const PaymentContent({super.key});

  @override
  ConsumerState<PaymentContent> createState() => _PaymentContentState();
}

class _PaymentContentState extends ConsumerState<PaymentContent> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = _getFilterIndex(ref.read(paymentFilterProvider));
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getFilterIndex(PaymentFilter filter) {
    switch (filter) {
      case PaymentFilter.all:
        return 0;
      case PaymentFilter.topUps:
        return 1;
      case PaymentFilter.payments:
        return 2;
    }
  }

  PaymentFilter _getFilterFromIndex(int index) {
    switch (index) {
      case 0:
        return PaymentFilter.all;
      case 1:
        return PaymentFilter.topUps;
      case 2:
        return PaymentFilter.payments;
      default:
        return PaymentFilter.all;
    }
  }

  void _onPageChanged(int index) {
    ref.read(paymentFilterProvider.notifier).state = _getFilterFromIndex(index);
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Transactions',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TabBar(onTabTapped: _onTabTapped),
          ),

          // Payment list
          Expanded(
            child: _PaymentPageView(
              pageController: _pageController,
              onPageChanged: _onPageChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends ConsumerWidget {
  final void Function(int) onTabTapped;

  const _TabBar({required this.onTabTapped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(paymentFilterProvider);

    return Row(
      children: [
        _TabItem(
          label: 'All',
          isSelected: filter == PaymentFilter.all,
          onTap: () => onTabTapped(0),
        ),
        const SizedBox(width: 24),
        _TabItem(
          label: 'Top-ups',
          isSelected: filter == PaymentFilter.topUps,
          onTap: () => onTabTapped(1),
        ),
        const SizedBox(width: 24),
        _TabItem(
          label: 'Payments',
          isSelected: filter == PaymentFilter.payments,
          onTap: () => onTabTapped(2),
        ),
      ],
    );
  }
}

class _PaymentPageView extends ConsumerWidget {
  final PageController pageController;
  final void Function(int) onPageChanged;

  const _PaymentPageView({
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return paymentsAsync.when(
      data: (allPayments) {
        final topUps = allPayments.where((p) => p.isTopUp).toList();
        final payments = allPayments.where((p) => p.isTrip).toList();

        return PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: [
            _PaymentList(
              payments: allPayments,
              onRefresh: () => ref.refresh(paymentsProvider.future),
              emptyMessage: 'No transactions yet',
            ),
            _PaymentList(
              payments: topUps,
              onRefresh: () => ref.refresh(paymentsProvider.future),
              emptyMessage: 'No top-ups yet',
            ),
            _PaymentList(
              payments: payments,
              onRefresh: () => ref.refresh(paymentsProvider.future),
              emptyMessage: 'No payments yet',
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.refresh(paymentsProvider.future),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryBlue
                    : (isDark ? Colors.grey[400] : AppColors.textSecondary),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 40 : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentList extends StatelessWidget {
  final List<PaymentEntity> payments;
  final Future<void> Function() onRefresh;
  final String emptyMessage;

  const _PaymentList({
    required this.payments,
    required this.onRefresh,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          final isLast = index == payments.length - 1;
          return PaymentTile(
            payment: payment,
            showDivider: !isLast,
          );
        },
      ),
    );
  }
}
