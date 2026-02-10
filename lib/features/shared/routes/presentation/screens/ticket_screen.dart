import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../services/booking_service.dart';

class TicketScreen extends ConsumerWidget {
  final TicketData ticketData;

  const TicketScreen({
    super.key,
    required this.ticketData,
  });

  void _goHome(BuildContext context, WidgetRef ref) {
    // Invalidate providers so home screen refreshes
    ref.invalidate(recentTripsProvider);
    ref.invalidate(allTripsProvider);
    ref.invalidate(walletProvider);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => _goHome(context, ref),
        ),
        title: Text(
          'Ticket',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success message
            const Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your ticket is ready',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Ticket card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          ticketData.routeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticketData.ticketId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QR Code
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:
                            _QRCodePlaceholder(ticketId: ticketData.ticketId),
                      ),
                    ),
                  ),

                  // Dashed divider
                  Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          height: 2,
                          color: index.isEven
                              ? (isDark ? Colors.grey[700] : Colors.grey[300])
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                  // Trip details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _TicketRow(
                          icon: Icons.trip_origin,
                          label: 'From',
                          value: ticketData.fromStop,
                          iconColor: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        _TicketRow(
                          icon: Icons.location_on,
                          label: 'To',
                          value: ticketData.toStop,
                          iconColor: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        _TicketRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: dateFormat.format(ticketData.bookingTime),
                          iconColor: AppColors.primaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _TicketRow(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: timeFormat.format(ticketData.bookingTime),
                          iconColor: AppColors.primaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _TicketRow(
                          icon: Icons.timer,
                          label: 'Valid Until',
                          value:
                              '${dateFormat.format(ticketData.expiryTime)} ${timeFormat.format(ticketData.expiryTime)}',
                          iconColor: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fare Paid',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey[400]
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              ticketData.formattedFare,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]
                    : AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Show this QR code to the bus conductor when boarding',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goHome(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _TicketRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : AppColors.textHint,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _QRCodePlaceholder extends StatelessWidget {
  final String ticketId;

  const _QRCodePlaceholder({required this.ticketId});

  @override
  Widget build(BuildContext context) {
    // Generate a simple visual pattern based on ticket ID
    return CustomPaint(
      size: const Size(160, 160),
      painter: _QRPatternPainter(ticketId),
    );
  }
}

class _QRPatternPainter extends CustomPainter {
  final String ticketId;

  _QRPatternPainter(this.ticketId);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 21;
    final random = ticketId.hashCode;

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
