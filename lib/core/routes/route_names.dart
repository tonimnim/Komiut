class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';

  static const String driverDashboard = '/driver-dashboard';
  static const String activeDuty = '/driver-active-duty';
  static const String preQueue = '/pre-queue';
  static const String queueManagement = '/driver/queue';
  static const String startTrip = '/driver/trip/start';
  static const String tripInProgress = '/driver/trip/:tripId/progress';
  static const String endTrip = '/driver/trip/:tripId/end';
  static const String tripDetails = '/driver/trip/:tripId/details';
  static const String tripEarnings = '/driver/earnings';
  static const String tripHistory = '/driver/history';
  static const String tripHistoryDetails = '/driver/history/:tripId';
  static const String driverSettings = '/driver/settings';

  static const String passengerHome = '/passenger/home';
  static const String passengerQueuing = '/passenger/queuing';
  static const String passengerTrip = '/passenger/trip';
  static const String passengerPayment = '/passenger/payment';
  static const String passengerHistory = '/passenger/history';
  static const String passengerSettings = '/passenger/settings';

  static String tripProgressPath(String tripId) => '/driver/trip/$tripId/progress';
  static String tripEndPath(String tripId) => '/driver/trip/$tripId/end';
  static String tripDetailsPath(String tripId) => '/driver/trip/$tripId/details';
  static String historyDetailsPath(String tripId) => '/driver/history/$tripId';
}
