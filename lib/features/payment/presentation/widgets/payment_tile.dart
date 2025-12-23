import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentTile extends StatelessWidget {
  final PaymentEntity payment;
  final bool showDivider;

  const PaymentTile({
    super.key,
    required this.payment,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = context.isDarkMode;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.description ?? payment.typeLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatSmartDate(payment.transactionDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.signedAmount,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: payment.isMoneyIn ? AppColors.success : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
      ],
    );
  }

  IconData _getIcon() {
    switch (payment.type) {
      case PaymentType.topUp:
        return Icons.add_circle_outline;
      case PaymentType.trip:
        return Icons.directions_bus;
      case PaymentType.refund:
        return Icons.refresh;
    }
  }

  Color _getIconColor() {
    switch (payment.type) {
      case PaymentType.topUp:
        return AppColors.success;
      case PaymentType.trip:
        return AppColors.primaryBlue;
      case PaymentType.refund:
        return Colors.orange;
    }
  }

  Color _getStatusColor() {
    switch (payment.status) {
      case PaymentStatus.completed:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.pending:
        return Colors.orange;
    }
  }
}
