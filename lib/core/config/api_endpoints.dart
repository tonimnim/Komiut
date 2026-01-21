class ApiEndpoints {
  static const String baseUrl = '/api';
  
  static const String login = '$baseUrl/auth/login';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';
  
  static const String driverProfile = '$baseUrl/driver/profile';
  static const String driverStatus = '$baseUrl/driver/status';
  static const String driverVehicle = '$baseUrl/driver/vehicle';
  static const String driverCircle = '$baseUrl/driver/circle';
  static const String driverRoute = '$baseUrl/driver/route';
  
  static const String queueStatus = '$baseUrl/queue/status';
  static const String queueJoin = '$baseUrl/queue/join';
  static const String queuePosition = '$baseUrl/queue/position';
  static const String queueLeave = '$baseUrl/queue/leave';
  static const String queueList = '$baseUrl/queue/list';
  
  static const String tripStart = '$baseUrl/trips/start';
  static String tripUpdate(String tripId) => '$baseUrl/trips/$tripId/update';
  static String tripEnd(String tripId) => '$baseUrl/trips/$tripId/end';
  static String tripDetails(String tripId) => '$baseUrl/trips/$tripId';
  static const String tripActive = '$baseUrl/trips/active';
  static const String tripHistory = '$baseUrl/trips/history';
  
  static const String earningsSummary = '$baseUrl/earnings/summary';
  static String earningsTrip(String tripId) => '$baseUrl/earnings/trip/$tripId';
  
  static const String notifications = '$baseUrl/notifications';
  static String notificationRead(String id) => '$baseUrl/notifications/$id/read';
}
