/// Route path constants for navigation.
class RouteConstants {
  const RouteConstants._();

  // ─────────────────────────────────────────────────────────────────────────
  // Auth routes
  // ─────────────────────────────────────────────────────────────────────────

  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String twoFactor = '/two-factor';

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy routes (for backwards compatibility)
  // ─────────────────────────────────────────────────────────────────────────

  static const String home = '/home';
  static const String activity = '/activity';
  static const String payments = '/payments';
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String notifications = '/notifications';
  static const String scan = '/scan';

  // ─────────────────────────────────────────────────────────────────────────
  // Passenger routes
  // ─────────────────────────────────────────────────────────────────────────

  static const String passengerHome = '/passenger/home';
  static const String passengerDiscovery = '/passenger/discovery';
  static const String passengerSaccos = '/passenger/saccos';
  static const String passengerSaccoDetail = '/passenger/sacco/:id';
  static const String passengerRouteDetail = '/passenger/routes/:id';
  static const String passengerBooking = '/passenger/booking';
  static const String passengerTrips = '/passenger/trips';
  static const String passengerTripDetail = '/passenger/trips/:id';
  static const String passengerActiveTrip = '/passenger/trip/:tripId';
  static const String passengerPayments = '/passenger/payments';
  static const String passengerTicket = '/passenger/ticket/:bookingId';
  static const String passengerTickets = '/passenger/tickets';
  static const String passengerBoarding = '/passenger/boarding/:ticketId';
  static const String passengerQueue = '/passenger/queue/:routeId';
  static const String passengerLoyalty = '/passenger/loyalty';

  // Payment flow routes
  static const String passengerPaymentMethod = '/passenger/payment/method/:bookingId';
  static const String passengerPaymentProcessing = '/passenger/payment/processing/:bookingId';
  static const String passengerPaymentReceipt = '/passenger/payment/receipt/:bookingId';

  // Wallet routes
  static const String passengerWalletTopup = '/passenger/wallet/topup';
  static const String passengerWalletTopupProcess = '/passenger/wallet/topup/process';
  static const String passengerWalletHistory = '/passenger/wallet/history';

  /// Get route detail path for a specific route.
  static String passengerRouteDetailPath(String id) => '/passenger/routes/$id';

  /// Get sacco detail path for a specific sacco.
  static String passengerSaccoDetailPath(String id) => '/passenger/sacco/$id';

  /// Get trip detail path for a specific trip.
  static String passengerTripDetailPath(String id) => '/passenger/trips/$id';

  /// Get ticket path for a specific booking.
  static String passengerTicketPath(String bookingId) => '/passenger/ticket/$bookingId';

  /// Get boarding confirmation path for a specific ticket.
  static String passengerBoardingPath(String ticketId) => '/passenger/boarding/$ticketId';

  /// Get active trip tracking path for a specific trip.
  static String passengerActiveTripPath(String tripId) => '/passenger/trip/$tripId';

  /// Get queue path for a specific route.
  static String passengerQueuePath(String routeId) => '/passenger/queue/$routeId';

  /// Get payment method selection path for a specific booking.
  static String passengerPaymentMethodPath(String bookingId) =>
      '/passenger/payment/method/$bookingId';

  /// Get payment processing path for a specific booking.
  static String passengerPaymentProcessingPath(String bookingId) =>
      '/passenger/payment/processing/$bookingId';

  /// Get payment receipt path for a specific booking.
  static String passengerPaymentReceiptPath(String bookingId) =>
      '/passenger/payment/receipt/$bookingId';

  // ─────────────────────────────────────────────────────────────────────────
  // Driver routes
  // ─────────────────────────────────────────────────────────────────────────

  static const String driverHome = '/driver/home';
  static const String driverQueue = '/driver/queue';
  static const String driverTrips = '/driver/trips';
  static const String driverTripDetail = '/driver/trips/:id';
  static const String driverEarnings = '/driver/earnings';
  static const String driverEarningsDetail = '/driver/earnings/:date';

  /// Get trip detail path for a specific trip.
  static String driverTripDetailPath(String id) => '/driver/trips/$id';

  /// Get earnings detail path for a specific date.
  static String driverEarningsDetailPath(String date) => '/driver/earnings/$date';

  // ─────────────────────────────────────────────────────────────────────────
  // Shared routes
  // ─────────────────────────────────────────────────────────────────────────

  static const String sharedProfile = '/shared/profile';
  static const String sharedEditProfile = '/shared/profile/edit';
  static const String sharedNotifications = '/shared/notifications';
  static const String sharedSettings = '/shared/settings';

  // ─────────────────────────────────────────────────────────────────────────
  // Settings sub-routes
  // ─────────────────────────────────────────────────────────────────────────

  static const String settingsAbout = '/settings/about';
  static const String settingsHelp = '/settings/help';
  static const String settingsFaq = '/settings/faq';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsTerms = '/settings/terms';

  // Passenger settings routes
  static const String settingsPreferences = '/settings/preferences';
  static const String settingsSavedRoutes = '/settings/saved-routes';
  static const String settingsSavedSaccos = '/settings/saved-saccos';
  static const String settingsPaymentMethods = '/settings/payment-methods';
}
