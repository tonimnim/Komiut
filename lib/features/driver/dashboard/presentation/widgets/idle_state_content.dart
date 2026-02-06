/// Idle state content for driver dashboard.
///
/// Shows wallet balance, today's summary, and GO ONLINE button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';

/// Idle state - Shows wallet, stats, and go online button.
class IdleStateContent extends ConsumerWidget {
  const IdleStateContent({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wallet Balance Card with Go Online toggle
        _DriverWalletCard(
          balance: 12450.00,
          currency: 'KES',
          isOnline: isOnline,
          onToggleOnline: () {
            // TODO: Toggle online status
          },
        ),
        const SizedBox(height: 24),

        // Live Transactions Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LiveTransactionsList(isDark: isDark),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRIVER WALLET CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _DriverWalletCard extends StatelessWidget {
  const _DriverWalletCard({
    required this.balance,
    required this.currency,
    required this.isOnline,
    required this.onToggleOnline,
  });

  final double balance;
  final String currency;
  final bool isOnline;
  final VoidCallback onToggleOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onToggleOnline,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOnline ? Icons.wifi : Icons.power_settings_new_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online' : 'Go Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$currency ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LIVE TRANSACTIONS LIST
// ═══════════════════════════════════════════════════════════════════════════════

class _LiveTransactionsList extends StatelessWidget {
  const _LiveTransactionsList({required this.isDark});

  final bool isDark;

  // Mock M-Pesa transactions (name, receipt, vehicle, amount, time)
  static const _transactions = [
    ('John Kamau', 'SHK7Y2X9LP', 'KDB 123A', 'KES 120', '2 min ago'),
    ('Mary Wanjiku', 'RKL3M8N4QT', 'KDB 123A', 'KES 80', '5 min ago'),
    ('Peter Ochieng', 'QWE5R7T1YU', 'KDB 123A', 'KES 150', '8 min ago'),
    ('Grace Muthoni', 'PLK8W3V6NM', 'KDB 123A', 'KES 100', '12 min ago'),
    ('James Kipruto', 'TYH2J9F4XC', 'KDB 123A', 'KES 80', '15 min ago'),
    ('Faith Akinyi', 'BNM6K1R8QZ', 'KDB 123A', 'KES 120', '18 min ago'),
    ('David Mwangi', 'VCX4L7P2SD', 'KDB 123A', 'KES 150', '22 min ago'),
    ('Susan Njeri', 'ZAQ9W5E3RT', 'KDB 123A', 'KES 80', '25 min ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: _transactions.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.$1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.$2} • ${tx.$3}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tx.$4,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.$5,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
