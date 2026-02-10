/// API endpoint constants.
///
/// All API endpoints are defined here for easy reference and maintenance.
/// Endpoints are organized by feature/resource.
library;

/// Contains all API endpoint paths.
class ApiEndpoints {
  const ApiEndpoints._();

  // ─────────────────────────────────────────────────────────────────────────
  // Authentication
  // ─────────────────────────────────────────────────────────────────────────

  /// Login endpoint.
  static const String login = '/api/MobileAppAuth/login';

  /// Registration endpoint.
  static const String register = '/api/MobileAppAuth/registration';

  /// OTP verification endpoint.
  static const String verifyOtp = '/api/MobileAppAuth/verify-otp';

  /// Password reset endpoint.
  static const String resetPassword = '/api/MobileAppAuth/reset-password';

  /// Complete reset password endpoint.
  static const String completeResetPassword = '/api/MobileAppAuth/complete-reset-password';

  /// Token refresh endpoint.
  static const String refreshToken = '/api/MobileAppAuth/refresh-token';

  // ─────────────────────────────────────────────────────────────────────────
  // Web Application Authentication
  // ─────────────────────────────────────────────────────────────────────────

  /// Web login endpoint.
  static const String webLogin = '/api/WebAppAuth/login';

  /// Web registration endpoint.
  static const String webRegister = '/api/WebAppAuth/registration';

  /// Web password reset endpoint.
  static const String webResetPassword = '/api/WebAppAuth/reset-password';

  /// Web 2FA endpoint.
  static const String webSend2Fa = '/api/WebAppAuth/send-2fa';

  // ─────────────────────────────────────────────────────────────────────────
  // Users
  // ─────────────────────────────────────────────────────────────────────────

  /// Users base endpoint.
  static const String users = '/api/Users';

  /// Get user by ID.
  static String userById(String id) => '/api/Users/$id';

  // ─────────────────────────────────────────────────────────────────────────
  // Organizations (Saccos)
  // ─────────────────────────────────────────────────────────────────────────

  /// Organizations base endpoint.
  static const String organizations = '/api/Organizations';

  /// Get organization by ID.
  static String organizationById(String id) => '/api/Organizations/$id';

  // ─────────────────────────────────────────────────────────────────────────
  // Routes
  // ─────────────────────────────────────────────────────────────────────────

  /// Routes base endpoint.
  static const String routes = '/api/Routes';

  /// Get route by ID.
  static String routeById(String id) => '/api/Routes/$id';

  /// Route stops base endpoint.
  static const String routeStops = '/api/RouteStops';

  /// Get route stops by route ID.
  static String routeStopsByRoute(String routeId) =>
      '/api/RouteStops?routeId=$routeId';

  /// Route fares base endpoint.
  static const String routeFares = '/api/RouteFares';

  /// Get route fares by route ID.
  static String routeFaresByRoute(String routeId) =>
      '/api/RouteFares?routeId=$routeId';

  // ─────────────────────────────────────────────────────────────────────────
  // Vehicles
  // ─────────────────────────────────────────────────────────────────────────

  /// Vehicles base endpoint.
  static const String vehicles = '/api/Vehicles';

  /// Get vehicle by ID.
  static String vehicleById(String id) => '/api/Vehicles/$id';

  /// Assign route to vehicle.
  static const String assignRoute = '/api/Vehicles/assign-route';

  /// Assign route to vehicle (alias).
  static const String vehicleAssignRoute = '/api/Vehicles/assign-route';

  // ─────────────────────────────────────────────────────────────────────────
  // Trips
  // ─────────────────────────────────────────────────────────────────────────

  /// Trips base endpoint.
  static const String trips = '/api/Trips';

  /// Get trip by ID.
  static String tripById(String id) => '/api/Trips/$id';

  // ─────────────────────────────────────────────────────────────────────────
  // Bookings
  // ─────────────────────────────────────────────────────────────────────────

  /// Bookings base endpoint.
  static const String bookings = '/api/Bookings';

  /// Get booking by ID.
  static String bookingById(String id) => '/api/Bookings/$id';

  /// Get bookings by passenger.
  static String bookingsByPassenger(String passengerId) =>
      '/api/Bookings?passengerId=$passengerId';

  /// Get current user's bookings.
  static const String bookingsMy = '/api/Bookings/my';

  /// Cancel a booking.
  static String bookingCancel(String id) => '/api/Bookings/$id/cancel';

  /// Confirm a booking after payment.
  static String bookingConfirm(String id) => '/api/Bookings/$id/confirm';

  // ─────────────────────────────────────────────────────────────────────────
  // Payments
  // ─────────────────────────────────────────────────────────────────────────

  /// Payments base endpoint.
  static const String payments = '/api/Payments';

  /// Get payment by ID.
  static String paymentById(String id) => '/api/Payments/$id';

  /// Daily vehicle totals endpoint.
  static const String dailyVehicleTotals = '/api/DailyVehicleTotals';

  /// Get daily totals by vehicle.
  static String dailyTotalsByVehicle(String vehicleId) =>
      '/api/DailyVehicleTotals?vehicleId=$vehicleId';

  // ─────────────────────────────────────────────────────────────────────────
  // M-Pesa
  // ─────────────────────────────────────────────────────────────────────────

  /// Initiate M-Pesa STK Push payment.
  static const String mpesaStkPush = '/api/Payments/mpesa/stk-push';

  /// Get M-Pesa transaction status.
  static String mpesaStatus(String checkoutRequestId) =>
      '/api/Payments/mpesa/status/$checkoutRequestId';

  /// Cancel M-Pesa transaction.
  static String mpesaCancel(String checkoutRequestId) =>
      '/api/Payments/mpesa/cancel/$checkoutRequestId';

  // ─────────────────────────────────────────────────────────────────────────
  // Wallets
  // ─────────────────────────────────────────────────────────────────────────

  /// Wallets base endpoint.
  static const String wallets = '/api/Wallets';

  /// Get current user's wallet.
  static const String walletMy = '/api/Wallets/my';

  /// Initiate wallet top-up.
  static const String walletTopUp = '/api/Wallets/topup';

  /// Get wallet transactions.
  static const String walletTransactions = '/api/Wallets/transactions';

  /// Get top-up status by transaction ID.
  static String walletTopUpStatus(String transactionId) =>
      '/api/Wallets/topup/$transactionId/status';

  // ─────────────────────────────────────────────────────────────────────────
  // Personnel (Drivers/Touts)
  // ─────────────────────────────────────────────────────────────────────────

  /// Personnel base endpoint.
  static const String personnel = '/api/Personnel';

  /// Get personnel by ID.
  static String personnelById(String id) => '/api/Personnel/$id';

  /// Get current user's driver/tout profile.
  static const String personnelMy = '/api/Personnel/my';

  /// Assign vehicle to personnel.
  static const String assignVehicle = '/api/Personnel/assign-vehicle';

  // ─────────────────────────────────────────────────────────────────────────
  // Driver-Specific Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  /// Get trips for a specific driver.
  static String tripsByDriver(String driverId) => '/api/Trips/driver/$driverId';

  /// Get current driver's trips.
  static const String tripsMyDriver = '/api/Trips/driver/my';

  /// Get vehicle assigned to a specific driver.
  static String vehicleByDriver(String driverId) =>
      '/api/Vehicles/driver/$driverId';

  /// Get current driver's assigned vehicle.
  static const String vehicleMyDriver = '/api/Vehicles/driver/my';

  /// Get driver's earnings summary.
  static const String driverEarnings = '/api/Personnel/earnings';

  /// Get driver's earnings for a specific date.
  static String driverEarningsByDate(String date) =>
      '/api/Personnel/earnings/$date';

  /// Get driver's earnings for a date range.
  static String driverEarningsRange(String startDate, String endDate) =>
      '/api/Personnel/earnings?startDate=$startDate&endDate=$endDate';

  // ─────────────────────────────────────────────────────────────────────────
  // Domains
  // ─────────────────────────────────────────────────────────────────────────

  /// Domains base endpoint.
  static const String domains = '/api/Domains';

  /// Get domain by ID.
  static String domainById(String id) => '/api/Domains/$id';

  // ─────────────────────────────────────────────────────────────────────────
  // Queues
  // ─────────────────────────────────────────────────────────────────────────

  /// Queues base endpoint.
  static const String queues = '/api/Queues';

  /// Get queue by route ID.
  static String queueByRoute(String routeId) => '/api/Queues/route/$routeId';

  /// Get queue by stage/terminal ID.
  static String queueByStage(String stageId) => '/api/Queues/stage/$stageId';

  /// Join a queue (driver action).
  static const String queueJoin = '/api/Queues/join';

  /// Leave a queue (driver action).
  static const String queueLeave = '/api/Queues/leave';

  /// Get current driver's queue position.
  static const String queueMyPosition = '/api/Queues/my-position';

  /// Get queue position for a specific vehicle.
  static String queuePositionByVehicle(String vehicleId) =>
      '/api/Queues/vehicle/$vehicleId';

  // ─────────────────────────────────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────────────────────────────────

  /// Notifications base endpoint.
  static const String notifications = '/api/Notifications';

  /// Get notification by ID.
  static String notificationById(String id) => '/api/Notifications/$id';

  // ─────────────────────────────────────────────────────────────────────────
  // Loyalty Points
  // ─────────────────────────────────────────────────────────────────────────

  /// Get loyalty points (single GET endpoint per Swagger).
  static const String loyaltyPoints = '/api/LoyaltyPoints';

  // ─────────────────────────────────────────────────────────────────────────
  // Passengers
  // ─────────────────────────────────────────────────────────────────────────

  /// Passengers base endpoint.
  static const String passengers = '/api/Passengers';

  /// Get passenger by ID.
  static String passengerById(String id) => '/api/Passengers/$id';

  // ─────────────────────────────────────────────────────────────────────────
  // Tickets
  // ─────────────────────────────────────────────────────────────────────────

  /// Tickets base endpoint.
  static const String tickets = '/api/Tickets';

  /// Get ticket by ID.
  static String ticketById(String id) => '/api/Tickets/$id';

  /// Get ticket by booking ID.
  static String ticketByBooking(String bookingId) =>
      '/api/Tickets/booking/$bookingId';

  /// Get current user's tickets.
  static const String ticketsMy = '/api/Tickets/my';

  /// Confirm boarding for a ticket.
  static String ticketBoard(String ticketId) => '/api/Tickets/$ticketId/board';

  /// Validate a ticket.
  static String ticketValidate(String ticketId) =>
      '/api/Tickets/$ticketId/validate';
}
