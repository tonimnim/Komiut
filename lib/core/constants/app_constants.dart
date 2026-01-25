class AppConstants {
  // App Info
  static const String appName = 'Komiut';
  static const String appTagline = 'Seamless Public Transport';

  // Timing
  static const int splashDuration = 3; // seconds
  static const int otpLength = 6;
  static const int networkTimeout = 30; // seconds

  // Mock Credentials (for development)
  static const String mockOtp = '123456';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // Currency
  static const String defaultCurrency = 'KES';
  static const String currencySymbol = 'KSh';

  // Database
  static const String databaseName = 'komiut.db';
  static const int databaseVersion = 2;
}
