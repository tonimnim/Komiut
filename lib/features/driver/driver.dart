/// Driver feature barrel file.
///
/// Exports all driver-related screens and providers.
///
/// ## For Musa - Getting Started with Driver Features
///
/// This module contains all driver-specific functionality:
///
/// ### Screens to implement:
/// - `DriverHomeScreen` - Main dashboard with trip status and earnings
/// - `QueueScreen` - Queue position and management
/// - `DriverTripsScreen` - Trip history and active trips
/// - `EarningsScreen` - Earnings breakdown and history
///
/// ### Key patterns to follow:
/// 1. Clean Architecture: domain -> data -> presentation
/// 2. Use Riverpod for state management
/// 3. Use Either<Failure, T> for error handling
/// 4. Follow existing widget patterns in `lib/core/widgets/`
///
/// ### Useful imports:
/// ```dart
/// import 'package:komiut/core/widgets/widgets.dart';  // Shared widgets
/// import 'package:komiut/core/domain/exports.dart';  // Domain entities
/// import 'package:komiut/core/network/api_endpoints.dart';  // API endpoints
/// import 'package:komiut/core/theme/app_colors.dart';  // App colors
/// ```
///
/// ### API endpoints for driver features:
///
/// **Profile & Vehicle:**
/// - `ApiEndpoints.personnelMy` - GET current driver profile
/// - `ApiEndpoints.vehicleMyDriver` - GET assigned vehicle
///
/// **Trips:**
/// - `ApiEndpoints.tripsMyDriver` - GET driver's trips
/// - `ApiEndpoints.tripsByDriver(id)` - GET trips by driver ID
/// - `ApiEndpoints.trips` - POST to start trip
///
/// **Queue:**
/// - `ApiEndpoints.queueMyPosition` - GET current queue position
/// - `ApiEndpoints.queueJoin` - POST to join queue
/// - `ApiEndpoints.queueLeave` - POST to leave queue
/// - `ApiEndpoints.queueByRoute(routeId)` - GET queue for route
///
/// **Earnings:**
/// - `ApiEndpoints.driverEarnings` - GET earnings summary
/// - `ApiEndpoints.driverEarningsByDate(date)` - GET daily earnings
/// - `ApiEndpoints.driverEarningsRange(start, end)` - GET range
/// - `ApiEndpoints.dailyVehicleTotals` - GET daily totals
///
/// ### Recommended packages:
/// - `fl_chart` for earnings charts
/// - `intl` for date/currency formatting
///
/// ### Getting help:
/// - See `lib/features/shared/README.md` for detailed documentation
/// - Check `lib/features/passenger/` for reference implementations
/// - Review `lib/core/domain/entities/` for available entities
///
/// Happy coding!
library;

// ─────────────────────────────────────────────────────────────────────────────
// Screens
// ─────────────────────────────────────────────────────────────────────────────

export 'home/presentation/screens/driver_home_screen.dart';
export 'queue/presentation/screens/queue_screen.dart';
export 'trips/presentation/screens/driver_trips_screen.dart';
export 'earnings/presentation/screens/earnings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers (TODO: Musa to implement)
// ─────────────────────────────────────────────────────────────────────────────

// TODO(Musa): Create and export these providers:
// export 'home/presentation/providers/driver_home_provider.dart';
// export 'queue/presentation/providers/queue_provider.dart';
// export 'trips/presentation/providers/driver_trips_provider.dart';
// export 'earnings/presentation/providers/earnings_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain (TODO: Musa to implement if needed)
// ─────────────────────────────────────────────────────────────────────────────

// TODO(Musa): Create driver-specific entities if needed:
// export 'domain/entities/queue_position.dart';
// export 'domain/entities/earnings_summary.dart';
// export 'domain/entities/driver_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data (TODO: Musa to implement)
// ─────────────────────────────────────────────────────────────────────────────

// TODO(Musa): Create data layer:
// export 'data/datasources/driver_remote_datasource.dart';
// export 'data/models/queue_position_model.dart';
// export 'data/models/earnings_model.dart';
// export 'data/repositories/driver_repository_impl.dart';
