/// Ticket screen.
///
/// Displays a single ticket with QR code for boarding.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_providers.dart';
import '../widgets/ticket_qr_code.dart';
import '../widgets/ticket_details.dart';
import '../widgets/ticket_status_badge.dart';

/// Screen displaying a single ticket with QR code.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({
    super.key,
    required this.bookingId,
  });

  /// The booking ID to fetch the ticket for.
  final String bookingId;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketByBookingProvider(widget.bookingId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Ticket',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurface,
            ),
            onSelected: (value) => _handleMenuAction(value, ticketAsync.valueOrNull),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Ticket'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Save to Photos'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Get Help'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ticketAsync.when(
        loading: () => _buildLoading(context),
        error: (error, _) => _buildError(context, error),
        data: (ticket) {
          if (ticket == null) {
            return _buildNotFound(context);
          }
          return _buildContent(context, ticket, isDark);
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryBlue),
          SizedBox(height: 16),
          Text(
            'Loading ticket...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load ticket',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(ticketByBookingProvider(widget.bookingId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ticket Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This ticket may have been cancelled or expired.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Ticket ticket, bool isDark) {
    return Stack(
      children: [
        // Main content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status banner for non-valid tickets
                if (ticket.status != TicketStatus.valid)
                  _buildStatusBanner(ticket, isDark),

                // QR Code
                TicketQRCode(
                  ticket: ticket,
                  size: 220,
                  showBrightnessButton: ticket.status == TicketStatus.valid,
                ),

                const SizedBox(height: 24),

                // Quick info
                _buildQuickInfo(ticket, isDark),

                const SizedBox(height: 16),

                // Toggle details button
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showDetails = !_showDetails);
                  },
                  icon: Icon(
                    _showDetails
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primaryBlue,
                  ),
                  label: Text(
                    _showDetails ? 'Hide Details' : 'Show Details',
                    style: const TextStyle(color: AppColors.primaryBlue),
                  ),
                ),

                // Full details (collapsible)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TicketDetails(
                      ticket: ticket,
                      showStatus: false,
                    ),
                  ),
                  crossFadeState: _showDetails
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

                // Bottom padding for button
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Bottom action bar
        if (ticket.status == TicketStatus.valid)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context, ticket, isDark),
          ),
      ],
    );
  }

  Widget _buildStatusBanner(Ticket ticket, bool isDark) {
    Color bannerColor;
    String message;
    IconData icon;

    switch (ticket.status) {
      case TicketStatus.used:
        bannerColor = AppColors.info;
        message = 'This ticket has already been used';
        icon = Icons.check_circle_outline;
        break;
      case TicketStatus.expired:
        bannerColor = AppColors.warning;
        message = 'This ticket has expired';
        icon = Icons.schedule;
        break;
      case TicketStatus.cancelled:
        bannerColor = AppColors.error;
        message = 'This ticket was cancelled';
        icon = Icons.cancel_outlined;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: bannerColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: bannerColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(Ticket ticket, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Route name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_bus,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  ticket.routeInfo.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stops
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  ticket.pickupStop,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  ticket.dropoffStop,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status and fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedTicketStatusBadge(
                status: ticket.status,
                animate: ticket.status == TicketStatus.valid,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.formattedFare,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Ticket ticket, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to wallet button (future)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _addToWallet(ticket),
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Add to Wallet'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Confirm boarding button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmBoarding(ticket),
              icon: const Icon(Icons.login),
              label: const Text('Board Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Ticket? ticket) {
    if (ticket == null) return;

    switch (action) {
      case 'share':
        _shareTicket(ticket);
        break;
      case 'download':
        _downloadTicket(ticket);
        break;
      case 'help':
        _getHelp(ticket);
        break;
    }
  }

  void _shareTicket(Ticket ticket) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _downloadTicket(Ticket ticket) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _getHelp(Ticket ticket) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help center coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _addToWallet(Ticket ticket) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add to Wallet coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _confirmBoarding(Ticket ticket) {
    HapticFeedback.mediumImpact();
    context.push('/passenger/boarding/${ticket.id}');
  }
}
