/// Master features barrel file.
///
/// Single entry point for all feature modules in the Komiut app.
library;

// Authentication (special - stays at top level)
// export 'auth/auth.dart';

// Driver-specific features
export 'driver/driver.dart';

// Passenger-specific features
export 'passenger/passenger.dart';

// Shared features (both roles)
export 'shared/shared.dart';
