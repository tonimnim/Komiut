/// Trips feature module.
///
/// Provides trips/activity functionality with remote API integration.
/// Uses bookings API to represent passenger trips.
library;

// Domain layer - entities
export 'domain/entities/active_trip.dart';

// Data layer - datasources
export 'data/datasources/bookings_remote_datasource.dart';
export 'data/datasources/trips_remote_datasource.dart';

// Data layer - models
export 'data/models/trip_api_model.dart';

// Data layer - repositories
export 'data/repositories/trips_repository.dart';

// Presentation layer - providers
export 'presentation/providers/trips_providers.dart';
export 'presentation/providers/active_trip_providers.dart';

// Presentation layer - screens
export 'presentation/screens/active_trip_screen.dart';

// Presentation layer - widgets
export 'presentation/widgets/trip_map_view.dart';
export 'presentation/widgets/trip_progress_bar.dart';
export 'presentation/widgets/trip_info_card.dart';
export 'presentation/widgets/trip_eta_display.dart';
export 'presentation/widgets/next_stop_indicator.dart';
