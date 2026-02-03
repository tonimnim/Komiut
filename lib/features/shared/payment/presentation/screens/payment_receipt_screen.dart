/// Payment receipt screen.
///
/// Displays a receipt after successful payment with transaction details,
/// booking confirmation, QR code for boarding, and sharing options.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../widgets/receipt_item.dart';

/// Payment receipt screen.
class PaymentReceiptScreen extends ConsumerStatefulWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.bookingId,
  });

  /// The booking ID for this receipt.
  final String bookingId;

  @override
  ConsumerState<PaymentReceiptScreen> createState() =>
      _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends ConsumerState<PaymentReceiptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Mock receipt data - in production this would come from a provider
  late final _receiptData = _ReceiptData(
    transactionId:
        'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
    bookingReference: 'BK${widget.bookingId.toUpperCase()}',
    amount: 150.0,
    currency: 'KES',
    paymentMethod: 'M-Pesa',
    mpesaRef: 'QI${Random().nextInt(99999999).toString().padLeft(8, '0')}',
    transactionDate: DateTime.now(),
    routeName: 'Route 46 - CBD',
    fromStop: 'Westlands',
    toStop: 'CBD',
    fare: 150.0,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goHome() {
    // Invalidate providers to refresh data
    ref.invalidate(walletProvider);
    ref.invalidate(recentTripsProvider);

    context.go(RouteConstants.passengerHome);
  }

  void _viewTicket() {
    context.push(RouteConstants.passengerTicketPath(widget.bookingId));
  }

  void _shareReceipt() {
    HapticFeedback.lightImpact();
    // In production, implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _goHome,
          ),
          title: Text(
            'Receipt',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: _shareReceipt,
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your booking is confirmed',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Receipt card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      ReceiptHeader(
                        title: _receiptData.routeName,
                        subtitle: _receiptData.bookingReference,
                        icon: Icons.directions_bus,
                      ),

                      // QR Code
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Center(
                            child: _QRCodePlaceholder(
                              reference: _receiptData.bookingReference,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Show this QR code when boarding',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : AppColors.textHint,
                        ),
                      ),

                      // Dashed divider
                      const ReceiptDivider(dashed: true),

                      // Transaction details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ReceiptItem(
                              icon: Icons.trip_origin,
                              iconColor: AppColors.primaryGreen,
                              label: 'From',
                              value: _receiptData.fromStop,
                            ),
                            ReceiptItem(
                              icon: Icons.location_on,
                              iconColor: AppColors.error,
                              label: 'To',
                              value: _receiptData.toStop,
                            ),
                            ReceiptItem(
                              icon: Icons.calendar_today,
                              iconColor: AppColors.primaryBlue,
                              label: 'Date',
                              value: dateFormat
                                  .format(_receiptData.transactionDate),
                            ),
                            ReceiptItem(
                              icon: Icons.access_time,
                              iconColor: AppColors.primaryBlue,
                              label: 'Time',
                              value: timeFormat
                                  .format(_receiptData.transactionDate),
                            ),
                          ],
                        ),
                      ),

                      const ReceiptDivider(),

                      // Payment details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ReceiptItem(
                              label: 'Method',
                              value: _receiptData.paymentMethod,
                            ),
                            ReceiptItem(
                              label: 'M-Pesa Ref',
                              value: _receiptData.mpesaRef,
                              isCopiable: true,
                            ),
                            ReceiptItem(
                              label: 'Transaction ID',
                              value: _receiptData.transactionId,
                              isCopiable: true,
                            ),
                            const ReceiptDivider(),
                            ReceiptTotal(
                              label: 'Amount Paid',
                              amount: _receiptData.amount,
                              currency: _receiptData.currency,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _viewTicket,
                    icon: const Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'View Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goHome,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color:
                            isDark ? Colors.grey[600]! : AppColors.primaryBlue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.grey[300] : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mock receipt data class.
class _ReceiptData {
  final String transactionId;
  final String bookingReference;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String mpesaRef;
  final DateTime transactionDate;
  final String routeName;
  final String fromStop;
  final String toStop;
  final double fare;

  const _ReceiptData({
    required this.transactionId,
    required this.bookingReference,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.mpesaRef,
    required this.transactionDate,
    required this.routeName,
    required this.fromStop,
    required this.toStop,
    required this.fare,
  });
}

/// QR code placeholder widget.
class _QRCodePlaceholder extends StatelessWidget {
  const _QRCodePlaceholder({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: _QRPatternPainter(reference),
    );
  }
}

class _QRPatternPainter extends CustomPainter {
  final String reference;

  _QRPatternPainter(this.reference);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 21;
    final random = reference.hashCode;

    // Draw corner squares (QR code positioning patterns)
    _drawPositionPattern(canvas, paint, 0, 0, cellSize);
    _drawPositionPattern(canvas, paint, size.width - 7 * cellSize, 0, cellSize);
    _drawPositionPattern(
        canvas, paint, 0, size.height - 7 * cellSize, cellSize);

    // Draw data cells
    for (int i = 0; i < 21; i++) {
      for (int j = 0; j < 21; j++) {
        // Skip corner patterns
        if ((i < 8 && j < 8) || (i < 8 && j > 12) || (i > 12 && j < 8)) {
          continue;
        }

        final hash = (random + i * 31 + j * 17) % 100;
        if (hash > 50) {
          canvas.drawRect(
            Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  void _drawPositionPattern(
      Canvas canvas, Paint paint, double x, double y, double cellSize) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize),
      paint,
    );

    // White inner
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize),
      whitePaint,
    );

    // Black center
    canvas.drawRect(
      Rect.fromLTWH(
          x + 2 * cellSize, y + 2 * cellSize, 3 * cellSize, 3 * cellSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
