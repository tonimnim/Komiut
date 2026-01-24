/// App-wide configuration settings.
///
/// This file contains global configuration values used throughout
/// the application.
library;

import 'env_config.dart';

/// Global application configuration.
class AppConfig {
  const AppConfig._();

  /// App name displayed in UI.
  static const String appName = 'Komiut';

  /// App version.
  static const String appVersion = '1.0.0';

  // ─────────────────────────────────────────────────────────────────────────
  // API Configuration
  // ─────────────────────────────────────────────────────────────────────────

  /// Base URL for API requests.
  static String get apiBaseUrl => EnvConfig.baseUrl;

  /// Default API request timeout in milliseconds.
  static const int apiTimeoutMs = 30000;

  /// API connection timeout in milliseconds.
  static const int apiConnectTimeoutMs = 15000;

  /// API receive timeout in milliseconds.
  static const int apiReceiveTimeoutMs = 30000;

  /// Maximum number of retry attempts for failed requests.
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts in milliseconds.
  static const int retryDelayMs = 1000;

  // ─────────────────────────────────────────────────────────────────────────
  // Cache Configuration
  // ─────────────────────────────────────────────────────────────────────────

  /// Default cache duration in minutes.
  static const int cacheDurationMinutes = 5;

  /// Maximum cache entries.
  static const int maxCacheEntries = 100;

  // ─────────────────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────────────────

  /// Default page size for paginated requests.
  static const int defaultPageSize = 20;

  /// Maximum page size allowed.
  static const int maxPageSize = 100;

  // ─────────────────────────────────────────────────────────────────────────
  // Secure Storage Keys
  // ─────────────────────────────────────────────────────────────────────────

  /// Key for storing access token.
  static const String accessTokenKey = 'access_token';

  /// Key for storing refresh token.
  static const String refreshTokenKey = 'refresh_token';

  /// Key for storing user ID.
  static const String userIdKey = 'user_id';

  /// Key for storing user role.
  static const String userRoleKey = 'user_role';

  /// Key for storing token expiry time.
  static const String tokenExpiryKey = 'token_expiry';

  // ─────────────────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────────────────

  /// Minimum password length.
  static const int minPasswordLength = 8;

  /// Maximum password length.
  static const int maxPasswordLength = 128;

  /// Phone number regex pattern.
  static const String phonePattern = r'^(\+254|0)[17]\d{8}$';

  /// Email regex pattern.
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // ─────────────────────────────────────────────────────────────────────────
  // Feature Flags
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether to enable loyalty points feature.
  static const bool enableLoyalty = true;

  /// Whether to enable seat selection feature.
  static const bool enableSeatSelection = true;

  /// Whether to enable QR boarding feature.
  static const bool enableQrBoarding = true;

  /// Whether to enable ratings feature.
  static const bool enableRatings = true;

  /// Whether to enable offline mode.
  static const bool enableOfflineMode = false;
}
