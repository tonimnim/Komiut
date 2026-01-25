class ApiEndpoints {
  static const String baseUrl = '/api';
  
  static const String login = '$baseUrl/MobileAppAuth/login';
  static const String verifyOtp = '$baseUrl/MobileAppAuth/verify-otp';
  static const String refreshToken = '$baseUrl/MobileAppAuth/refresh';
  static const String logout = '$baseUrl/MobileAppAuth/logout';
  
  static const String driverProfile = '$baseUrl/Personnel';
  static const String driverStatus = '$baseUrl/Personnel/status';
  static const String driverVehicle = '$baseUrl/Vehicles';
  static const String driverCircle = '$baseUrl/Domains';
  static const String driverRoute = '$baseUrl/Routes';
  static const String driverProfilePhoto = '$baseUrl/Personnel/photo';
  
  static const String queueStatus = '$baseUrl/Bookings/status';
  static const String queueJoin = '$baseUrl/Bookings';
  static const String queuePosition = '$baseUrl/Bookings/position';
  static const String queueLeave = '$baseUrl/Bookings/cancel';
  static const String queueList = '$baseUrl/Bookings';
  
  static const String tripStart = '$baseUrl/Trips';
  static String tripUpdate(String tripId) => '$baseUrl/Trips/$tripId';
  static String tripEnd(String tripId) => '$baseUrl/Trips/$tripId/end';
  static String tripDetails(String tripId) => '$baseUrl/Trips/$tripId';
  static const String tripActive = '$baseUrl/Trips/active';
  static const String tripHistory = '$baseUrl/Trips';
  
  static const String earningsSummary = '$baseUrl/DailyVehicleTotals';
  static String earningsTrip(String tripId) => '$baseUrl/DailyVehicleTotals/$tripId';
  
  static const String notifications = '$baseUrl/Notifications';
  static String notificationRead(String id) => '$baseUrl/Notifications/$id/read';
}
