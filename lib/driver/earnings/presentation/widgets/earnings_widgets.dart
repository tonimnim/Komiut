import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EarningsToggle extends StatelessWidget {
  final bool isWeekly;
  final Function(bool) onToggle;

  const EarningsToggle({
    super.key,
    required this.isWeekly,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Daily',
              isSelected: !isWeekly,
              onTap: () => onToggle(false),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Weekly',
              isSelected: isWeekly,
              onTap: () => onToggle(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final String amount;
  final String trend;
  const BalanceCard({super.key, required this.amount, required this.trend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.walletCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.3),
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
              Text(
                'Total Balance',
                style: AppTextStyles.label.copyWith(color: Colors.white.withOpacity(0.7)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: AppTextStyles.label.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'KES $amount',
            style: AppTextStyles.heading1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'PAYOUT SCHEDULED FOR OCT 24',
            style: AppTextStyles.overline.copyWith(fontSize: 11, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

class EarningsChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String period;

  const EarningsChart({
    super.key,
    required this.values,
    required this.labels,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Earnings Activity',
              style: AppTextStyles.heading3.copyWith(fontSize: 18),
            ),
            Text(
              period,
              style: AppTextStyles.body2.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    Container(
                      width: values.length > 5 ? 32 : 50,
                      height: (120 * values[index]).clamp(4.0, 120.0),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    labels[index],
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.amount,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        title,
                        style: AppTextStyles.heading4.copyWith(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          date,
                          style: AppTextStyles.body3.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('•', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                        ),
                        Text(
                          status,
                          style: AppTextStyles.body3.copyWith(
                            color: status == 'Completed' ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'KES $amount',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.success, // User requested Green for prices
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
