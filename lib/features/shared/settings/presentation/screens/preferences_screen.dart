/// Passenger preferences screen.
///
/// Allows passengers to configure their default payment method,
/// notification settings, and accessibility options.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/passenger_preferences.dart';
import '../providers/preferences_providers.dart';
import '../widgets/preference_tile.dart';

/// Screen for managing passenger preferences.
class PreferencesScreen extends ConsumerWidget {
  /// Creates a preferences screen.
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(passengerPreferencesProvider);
    final preferences = state.preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Default Payment Method
                  PreferenceSection(
                    title: 'Payment',
                    children: [
                      PreferenceTile.custom(
                        icon: Icons.payment,
                        title: 'Default Payment Method',
                        subtitle: preferences.defaultPaymentMethod.label,
                        onTap: () =>
                            _showPaymentMethodPicker(context, ref, preferences),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.grey[600] : AppColors.textHint,
                        ),
                      ),
                      PreferenceTile.navigation(
                        icon: Icons.credit_card,
                        title: 'Saved Payment Methods',
                        subtitle: 'Manage M-Pesa numbers and cards',
                        onTap: () =>
                            context.push(RouteConstants.settingsPaymentMethods),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Notification Settings
                  PreferenceSection(
                    title: 'Notifications',
                    children: [
                      PreferenceTile.toggle(
                        icon: Icons.directions_bus,
                        title: 'Trip Updates',
                        subtitle: 'Get notified about trip status changes',
                        value: preferences.notifications.tripUpdates,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateNotificationSetting(tripUpdates: value),
                      ),
                      PreferenceTile.toggle(
                        icon: Icons.queue,
                        title: 'Queue Alerts',
                        subtitle: 'Vehicle position and departure alerts',
                        value: preferences.notifications.queueAlerts,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateNotificationSetting(queueAlerts: value),
                      ),
                      PreferenceTile.toggle(
                        icon: Icons.location_on,
                        title: 'Destination Alerts',
                        subtitle: 'Get notified when approaching destination',
                        value: preferences.notifications.destinationAlerts,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateNotificationSetting(
                                destinationAlerts: value),
                      ),
                      PreferenceTile.toggle(
                        icon: Icons.receipt_long,
                        title: 'Payment Receipts',
                        subtitle: 'Receive payment confirmation notifications',
                        value: preferences.notifications.paymentReceipts,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateNotificationSetting(paymentReceipts: value),
                      ),
                      PreferenceTile.toggle(
                        icon: Icons.local_offer,
                        title: 'Promotions',
                        subtitle: 'Offers and promotional updates',
                        value: preferences.notifications.promotions,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateNotificationSetting(promotions: value),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Favorites
                  PreferenceSection(
                    title: 'Favorites',
                    children: [
                      PreferenceTile.navigation(
                        icon: Icons.route,
                        title: 'Saved Routes',
                        subtitle: 'Your favorite routes',
                        onTap: () =>
                            context.push(RouteConstants.settingsSavedRoutes),
                      ),
                      PreferenceTile.navigation(
                        icon: Icons.business,
                        title: 'Saved SACCOs',
                        subtitle: 'Your favorite transport operators',
                        onTap: () =>
                            context.push(RouteConstants.settingsSavedSaccos),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Accessibility
                  PreferenceSection(
                    title: 'Accessibility',
                    children: [
                      PreferenceTile.toggle(
                        icon: Icons.text_fields,
                        title: 'Large Text',
                        subtitle: 'Use larger text sizes throughout the app',
                        value: preferences.accessibility.largeText,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateAccessibilityOption(largeText: value),
                      ),
                      PreferenceTile.toggle(
                        icon: Icons.contrast,
                        title: 'High Contrast',
                        subtitle:
                            'Increase color contrast for better visibility',
                        value: preferences.accessibility.highContrast,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateAccessibilityOption(highContrast: value),
                      ),
                      PreferenceTile.toggle(
                        icon: Icons.motion_photos_off,
                        title: 'Reduced Motion',
                        subtitle: 'Minimize animations and transitions',
                        value: preferences.accessibility.reducedMotion,
                        onChanged: (value) => ref
                            .read(passengerPreferencesProvider.notifier)
                            .updateAccessibilityOption(reducedMotion: value),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showPaymentMethodPicker(
    BuildContext context,
    WidgetRef ref,
    PassengerPreferences preferences,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Select Default Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...PaymentMethod.values.map((method) => ListTile(
                    leading: Icon(
                      _getPaymentMethodIcon(method),
                      color: preferences.defaultPaymentMethod == method
                          ? AppColors.primaryBlue
                          : null,
                    ),
                    title: Text(method.label),
                    trailing: preferences.defaultPaymentMethod == method
                        ? const Icon(Icons.check, color: AppColors.primaryBlue)
                        : null,
                    onTap: () {
                      ref
                          .read(passengerPreferencesProvider.notifier)
                          .setDefaultPaymentMethod(method);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return Icons.phone_android;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
    }
  }
}
