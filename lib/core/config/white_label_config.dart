/// White-label configuration.
///
/// Configuration model for white-label customization,
/// allowing different branding and features per deployment.
library;

import 'package:flutter/material.dart';

/// Features that can be enabled/disabled per deployment.
enum AppFeature {
  /// Loyalty points system.
  loyalty,

  /// Seat selection during booking.
  seatSelection,

  /// QR code boarding pass.
  qrBoarding,

  /// Driver/trip ratings.
  ratings,

  /// In-app wallet.
  wallet,

  /// Push notifications.
  notifications,

  /// Offline mode support.
  offlineMode,

  /// Real-time tracking.
  realTimeTracking,

  /// Multiple payment methods.
  multiplePaymentMethods,

  /// Favorite routes.
  favoriteRoutes,

  /// Trip history.
  tripHistory,

  /// Driver earnings dashboard.
  driverEarnings,

  /// Queue management (driver).
  queueManagement,
}

/// White-label configuration for customizing app appearance and features.
class WhiteLabelConfig {
  /// Creates a white-label configuration.
  const WhiteLabelConfig({
    required this.brandName,
    required this.primaryColor,
    this.secondaryColor,
    this.logoPath,
    this.splashLogoPath,
    this.enabledFeatures = const {},
    this.supportEmail,
    this.supportPhone,
    this.termsUrl,
    this.privacyUrl,
    this.defaultLocale = 'en',
    this.defaultCurrency = 'KES',
  });

  /// Default Komiut configuration.
  factory WhiteLabelConfig.komiut() {
    return const WhiteLabelConfig(
      brandName: 'Komiut',
      primaryColor: Color(0xFF0066CC),
      secondaryColor: Color(0xFF00B894),
      logoPath: 'assets/images/appicon.jpg',
      splashLogoPath: 'assets/images/appicon.jpg',
      enabledFeatures: {
        AppFeature.loyalty,
        AppFeature.seatSelection,
        AppFeature.qrBoarding,
        AppFeature.ratings,
        AppFeature.wallet,
        AppFeature.notifications,
        AppFeature.realTimeTracking,
        AppFeature.multiplePaymentMethods,
        AppFeature.favoriteRoutes,
        AppFeature.tripHistory,
        AppFeature.driverEarnings,
        AppFeature.queueManagement,
      },
      supportEmail: 'support@komiut.com',
      defaultCurrency: 'KES',
    );
  }

  /// Brand name displayed in the app.
  final String brandName;

  /// Primary brand color.
  final Color primaryColor;

  /// Secondary brand color.
  final Color? secondaryColor;

  /// Path to logo asset.
  final String? logoPath;

  /// Path to splash screen logo.
  final String? splashLogoPath;

  /// Set of enabled features.
  final Set<AppFeature> enabledFeatures;

  /// Support email address.
  final String? supportEmail;

  /// Support phone number.
  final String? supportPhone;

  /// Terms of service URL.
  final String? termsUrl;

  /// Privacy policy URL.
  final String? privacyUrl;

  /// Default locale code.
  final String defaultLocale;

  /// Default currency code.
  final String defaultCurrency;

  /// Check if a feature is enabled.
  bool isFeatureEnabled(AppFeature feature) {
    return enabledFeatures.contains(feature);
  }

  /// Get the effective secondary color.
  Color get effectiveSecondaryColor {
    return secondaryColor ?? primaryColor.withValues(alpha: 0.7);
  }

  /// Create a copy with modifications.
  WhiteLabelConfig copyWith({
    String? brandName,
    Color? primaryColor,
    Color? secondaryColor,
    String? logoPath,
    String? splashLogoPath,
    Set<AppFeature>? enabledFeatures,
    String? supportEmail,
    String? supportPhone,
    String? termsUrl,
    String? privacyUrl,
    String? defaultLocale,
    String? defaultCurrency,
  }) {
    return WhiteLabelConfig(
      brandName: brandName ?? this.brandName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoPath: logoPath ?? this.logoPath,
      splashLogoPath: splashLogoPath ?? this.splashLogoPath,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      termsUrl: termsUrl ?? this.termsUrl,
      privacyUrl: privacyUrl ?? this.privacyUrl,
      defaultLocale: defaultLocale ?? this.defaultLocale,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }
}

/// Current white-label configuration.
///
/// This can be changed at build time or loaded from a config file.
const currentWhiteLabelConfig = WhiteLabelConfig(
  brandName: 'Komiut',
  primaryColor: Color(0xFF0066CC),
  secondaryColor: Color(0xFF00B894),
  logoPath: 'assets/images/appicon.jpg',
  enabledFeatures: {
    AppFeature.loyalty,
    AppFeature.seatSelection,
    AppFeature.qrBoarding,
    AppFeature.ratings,
    AppFeature.wallet,
    AppFeature.notifications,
    AppFeature.realTimeTracking,
    AppFeature.multiplePaymentMethods,
    AppFeature.favoriteRoutes,
    AppFeature.tripHistory,
    AppFeature.driverEarnings,
    AppFeature.queueManagement,
  },
  defaultCurrency: 'KES',
);

/// Helper extension for checking features.
extension AppFeatureX on AppFeature {
  /// Check if this feature is currently enabled.
  bool get isEnabled => currentWhiteLabelConfig.isFeatureEnabled(this);
}
