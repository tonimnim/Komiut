library;

import 'env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// Domain ID for white-label backend identification.
  /// Sent as `_domain` header with every API request.
  static const String domainId = '75fcf243-e029-4721-abae-08de656ef6a0';

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

  /// DEV MODE: Skip authentication and go directly to home screen.
  /// Set to true to preview UI without logging in.
  /// ⚠️ PRODUCTION: Must be false before deployment!
  static const bool skipAuth = false;

  /// DEV MODE: Use simulated auth with hardcoded test credentials.
  /// When true, login will work with test accounts below (no API needed).
  /// ⚠️ PRODUCTION: Must be false before deployment!
  static const bool useSimulatedAuth = false;

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

  // ─────────────────────────────────────────────────────────────────────────
  // Driver Specific Extras
  // ─────────────────────────────────────────────────────────────────────────

  /// Google Maps API Key.
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Whether to enable mock data for development/testing.
  /// ⚠️ PRODUCTION: Must be false to use real API!
  static bool get enableMockData => false;
}
