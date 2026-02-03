class AppConstants {
  static const String roleDriver = 'driver';
  static const String rolePassenger = 'passenger';

  static const String statusOffline = 'offline';
  static const String statusOnline = 'online';
  static const String statusOnTrip = 'on_trip';

  static const String tripPending = 'pending';
  static const String tripInProgress = 'in_progress';
  static const String tripCompleted = 'completed';
  static const String tripCancelled = 'cancelled';

  static const String queueWaiting = 'waiting';
  static const String queueReady = 'ready';
  static const String queueExpired = 'expired';

  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyThemeMode = 'theme_mode';

  static const int otpResendSeconds = 60;
  static const int queuePollIntervalSeconds = 10;
  static const int locationUpdateIntervalSeconds = 5;

  static const int maxPassengerCount = 14;
  static const int minPassengerCount = 1;
  static const double nearPickupDistanceMeters = 500;
}
