class ApiEndpoints {
  static const String baseUrl = '/api';

  // Auth
  static const String login = '$baseUrl/MobileAppAuth/login';
  static const String registration = '$baseUrl/MobileAppAuth/registration';
  static const String resetPassword = '$baseUrl/MobileAppAuth/reset-password';

  // Personnel (Profile)
  static const String personnel = '$baseUrl/Personnel';
  static const String assignVehicle = '$baseUrl/Personnel/assign-vehicle';

  // Vehicles
  static const String vehicles = '$baseUrl/Vehicles';
  static const String assignRoute = '$baseUrl/Vehicles/assign-route';

  // Routes & Stops
  static const String routes = '$baseUrl/Routes';
  static const String routeStops = '$baseUrl/RouteStops';
  static const String routeFares = '$baseUrl/RouteFares';

  // Trips
  static const String trips = '$baseUrl/Trips';

  // Earnings & Totals
  static const String dailyTotals = '$baseUrl/DailyVehicleTotals';
  static const String payments = '$baseUrl/Payments';

  // Domains (Queue/Terminals)
  static const String domains = '$baseUrl/Domains';

  // Bookings
  static const String bookings = '$baseUrl/Bookings';

  // --- API COMPATIBILITY ALIASES (Legacy Support) ---
  static const String driverProfile = personnel;
  static const String driverVehicle = vehicles;
  static const String driverCircle = domains;
  static const String driverRoute = routes;
  static const String driverProfilePhoto = personnel;
  static const String tripStart = trips;
  static const String tripActive = trips;
  static const String tripHistory = trips;
  static const String earningsSummary = dailyTotals;
  static const String queueStatus = bookings;
  static const String queueJoin = bookings;
  static const String queuePosition = bookings;
  static const String queueLeave = bookings;
  static const String queueList = bookings;
  static const String notifications = '$baseUrl/Notifications';

  static String tripUpdate(String id) => trips;
  static String tripEnd(String id) => trips;
  static String tripDetails(String id) => trips;
  static String earningsTrip(String id) => dailyTotals;
  static String notificationRead(String id) =>
      '$baseUrl/Notifications/$id/read';
}
