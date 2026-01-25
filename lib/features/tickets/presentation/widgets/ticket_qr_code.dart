/// Ticket QR code widget.
///
/// Displays the QR code for a ticket with brightness control.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_providers.dart';

/// QR code display for ticket scanning.
class TicketQRCode extends ConsumerStatefulWidget {
  const TicketQRCode({
    super.key,
    required this.ticket,
    this.size = 250,
    this.showBrightnessButton = true,
    this.backgroundColor,
  });

  /// The ticket to generate QR for.
  final Ticket ticket;

  /// Size of the QR code.
  final double size;

  /// Whether to show the brightness boost button.
  final bool showBrightnessButton;

  /// Background color for the QR code.
  final Color? backgroundColor;

  @override
  ConsumerState<TicketQRCode> createState() => _TicketQRCodeState();
}

class _TicketQRCodeState extends ConsumerState<TicketQRCode> {
  // TODO(Platform): Store actual brightness value when platform channel is implemented
  // ignore: unused_field
  double? _previousBrightness;

  @override
  void dispose() {
    _restoreBrightness();
    super.dispose();
  }

  Future<void> _boostBrightness() async {
    try {
      // Store current brightness (would need platform channel for actual implementation)
      // For now, we just set a flag
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: []);
    } catch (_) {
      // Ignore errors
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    } catch (_) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrData = ref.watch(ticketQRDataProvider(widget.ticket));
    final isBrightnessBoosted = ref.watch(brightnessBoostProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Code container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Code
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: widget.size,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primaryDark,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primaryDark,
                ),
                errorStateBuilder: (context, error) {
                  return SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error generating QR',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Ticket number
              Text(
                widget.ticket.ticketNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),

        // Brightness boost button
        if (widget.showBrightnessButton) ...[
          const SizedBox(height: 16),
          _BrightnessButton(
            isBoosted: isBrightnessBoosted,
            onToggle: () {
              final notifier = ref.read(brightnessBoostProvider.notifier);
              if (isBrightnessBoosted) {
                _restoreBrightness();
                notifier.state = false;
              } else {
                _boostBrightness();
                notifier.state = true;
              }
            },
          ),
        ],
      ],
    );
  }
}

/// Brightness boost toggle button.
class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    required this.isBoosted,
    required this.onToggle,
  });

  final bool isBoosted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isBoosted
              ? AppColors.warning.withValues(alpha: 0.2)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isBoosted
                ? AppColors.warning
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBoosted ? Icons.brightness_7 : Icons.brightness_6,
              size: 18,
              color: isBoosted
                  ? AppColors.warning
                  : (isDark ? Colors.grey[400] : AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              isBoosted ? 'Brightness Boosted' : 'Boost for Scanning',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isBoosted
                    ? AppColors.warning
                    : (isDark ? Colors.grey[300] : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact QR code widget for lists.
class CompactTicketQRCode extends ConsumerWidget {
  const CompactTicketQRCode({
    super.key,
    required this.ticket,
    this.size = 80,
  });

  final Ticket ticket;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrData = ref.watch(ticketQRDataProvider(ticket));

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.primaryDark,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
