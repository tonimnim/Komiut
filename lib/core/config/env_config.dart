/// Environment configuration for different deployment stages.
///
/// This file defines the available environments and their corresponding
/// base URLs and configuration settings.
library;

/// Available deployment environments.
enum Environment {
  /// Development environment for local testing.
  dev,

  /// Staging environment for pre-production testing.
  staging,

  /// Production environment for live users.
  prod,
}

/// Environment-specific configuration values.
class EnvConfig {
  const EnvConfig._();

  /// Current active environment.
  /// Change this to switch between environments.
  static const Environment current = Environment.staging;

  /// Base URLs for each environment.
  static const Map<Environment, String> _baseUrls = {
    Environment.dev: 'https://v2.komiut.com',
    Environment.staging: 'https://v2.komiut.com',
    Environment.prod: 'https://v2.komiut.com',
  };

  /// Tenant IDs for each environment.
  /// Used for multi-tenant API authentication.
  static const Map<Environment, String> _tenantIds = {
    Environment.dev: '@157943731372240',
    Environment.staging: '@157943731372240',
    Environment.prod: '',
  };

  /// Get the base URL for the current environment.
  static String get baseUrl => _baseUrls[current]!;

  /// Get the tenant ID for the current environment.
  static String get tenantId => _tenantIds[current]!;

  /// Get the tenant ID for a specific environment.
  static String getTenantId(Environment env) => _tenantIds[env]!;

  /// Get the base URL for a specific environment.
  static String getBaseUrl(Environment env) => _baseUrls[env]!;

  /// Whether the current environment is development.
  static bool get isDev => current == Environment.dev;

  /// Whether the current environment is staging.
  static bool get isStaging => current == Environment.staging;

  /// Whether the current environment is production.
  static bool get isProd => current == Environment.prod;

  /// Whether to enable debug logging.
  static bool get enableLogging => !isProd;

  /// Whether to enable detailed API logging.
  static bool get enableApiLogging => isDev;
}
