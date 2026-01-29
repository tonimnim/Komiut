/// Redeem points bottom sheet widget.
///
/// A bottom sheet for redeeming loyalty points.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/loyalty_rules.dart';
import '../providers/loyalty_providers.dart';

/// Bottom sheet for redeeming points.
///
/// Allows users to:
/// - Select number of points to redeem
/// - See discount value
/// - Confirm redemption
class RedeemPointsSheet extends ConsumerStatefulWidget {
  /// Creates a redeem points sheet.
  const RedeemPointsSheet({
    super.key,
    required this.availablePoints,
    required this.bookingId,
    this.bookingAmount,
    this.onRedeemed,
  });

  /// Available points for redemption.
  final int availablePoints;

  /// Booking ID to apply discount.
  final String bookingId;

  /// Optional booking amount to limit redemption.
  final double? bookingAmount;

  /// Callback when points are successfully redeemed.
  final void Function(int points, double discount)? onRedeemed;

  /// Shows the redeem points sheet.
  static Future<void> show({
    required BuildContext context,
    required int availablePoints,
    required String bookingId,
    double? bookingAmount,
    void Function(int points, double discount)? onRedeemed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RedeemPointsSheet(
        availablePoints: availablePoints,
        bookingId: bookingId,
        bookingAmount: bookingAmount,
        onRedeemed: onRedeemed,
      ),
    );
  }

  @override
  ConsumerState<RedeemPointsSheet> createState() => _RedeemPointsSheetState();
}

class _RedeemPointsSheetState extends ConsumerState<RedeemPointsSheet> {
  late int _selectedPoints;
  late int _maxPoints;

  @override
  void initState() {
    super.initState();
    _calculateMaxPoints();
    _selectedPoints = 0;
  }

  void _calculateMaxPoints() {
    _maxPoints = widget.availablePoints;

    // Limit by booking amount if provided
    if (widget.bookingAmount != null) {
      final maxForBooking = LoyaltyRules.pointsForDiscount(widget.bookingAmount!);
      _maxPoints = _maxPoints.clamp(0, maxForBooking);
    }

    // Limit by maximum redemption
    _maxPoints = _maxPoints.clamp(0, LoyaltyRules.maximumRedemption);

    // Round down to nearest 100
    _maxPoints = (_maxPoints ~/ 100) * 100;
  }

  double get _discountValue => LoyaltyRules.calculateRedemptionValue(_selectedPoints);

  bool get _canRedeem =>
      _selectedPoints >= LoyaltyRules.minimumRedemption &&
      _selectedPoints <= _maxPoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final redeemState = ref.watch(redeemPointsNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Redeem Points',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use your points for a discount',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Points selector
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Available points
                    Text(
                      'Available: ${widget.availablePoints} points',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Points amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PointsButton(
                          icon: Icons.remove,
                          onPressed: _selectedPoints >= 100
                              ? () => setState(() => _selectedPoints -= 100)
                              : null,
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            Text(
                              '$_selectedPoints',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Text(
                              'points',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        _PointsButton(
                          icon: Icons.add,
                          onPressed: _selectedPoints < _maxPoints
                              ? () => setState(() => _selectedPoints += 100)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Slider
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: theme.colorScheme.primary,
                        inactiveTrackColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        thumbColor: theme.colorScheme.primary,
                        overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _selectedPoints.toDouble(),
                        min: 0,
                        max: _maxPoints.toDouble(),
                        divisions: _maxPoints > 0 ? _maxPoints ~/ 100 : 1,
                        onChanged: (value) {
                          setState(() {
                            _selectedPoints = (value ~/ 100) * 100;
                          });
                        },
                      ),
                    ),

                    // Quick select buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QuickSelectChip(
                          label: '100',
                          isSelected: _selectedPoints == 100,
                          onTap: _maxPoints >= 100
                              ? () => setState(() => _selectedPoints = 100)
                              : null,
                        ),
                        _QuickSelectChip(
                          label: '500',
                          isSelected: _selectedPoints == 500,
                          onTap: _maxPoints >= 500
                              ? () => setState(() => _selectedPoints = 500)
                              : null,
                        ),
                        _QuickSelectChip(
                          label: '1000',
                          isSelected: _selectedPoints == 1000,
                          onTap: _maxPoints >= 1000
                              ? () => setState(() => _selectedPoints = 1000)
                              : null,
                        ),
                        _QuickSelectChip(
                          label: 'Max',
                          isSelected: _selectedPoints == _maxPoints,
                          onTap: _maxPoints >= 100
                              ? () => setState(() => _selectedPoints = _maxPoints)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Discount value
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discount Value',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'KES ${_discountValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (redeemState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          redeemState.error!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Redeem button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canRedeem && !redeemState.isLoading
                      ? () async {
                          final notifier =
                              ref.read(redeemPointsNotifierProvider.notifier);
                          notifier.setPoints(_selectedPoints);
                          final success = await notifier.redeem(widget.bookingId);
                          if (success && mounted) {
                            widget.onRedeemed?.call(_selectedPoints, _discountValue);
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: redeemState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _canRedeem
                              ? 'Redeem $_selectedPoints Points'
                              : 'Select at least 100 points',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Info text
              const SizedBox(height: 16),
              Text(
                '100 points = KES 10 discount',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Points increment/decrement button.
class _PointsButton extends StatelessWidget {
  const _PointsButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: onPressed != null
          ? theme.colorScheme.primary.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onPressed != null
                ? theme.colorScheme.primary
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// Quick select chip.
class _QuickSelectChip extends StatelessWidget {
  const _QuickSelectChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onTap != null
                ? theme.colorScheme.primary
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : onTap != null
                    ? theme.colorScheme.primary
                    : Colors.grey,
          ),
        ),
      ),
    );
  }
}
