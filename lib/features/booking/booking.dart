/// Booking feature exports.
///
/// This barrel file exports all public APIs from the booking feature.
/// Import this file to access booking entities, models, repositories,
/// datasources, and providers.
library;

// Domain layer
export 'domain/entities/booking.dart';
export 'domain/repositories/booking_repository.dart';

// Data layer
export 'data/models/booking_model.dart';
export 'data/models/create_booking_request.dart';
export 'data/datasources/booking_remote_datasource.dart';
export 'data/repositories/booking_repository_impl.dart';

// Presentation layer - Providers
export 'presentation/providers/booking_providers.dart';
export 'presentation/providers/booking_flow_provider.dart';

// Presentation layer - Widgets
export 'presentation/widgets/stop_selector.dart';
export 'presentation/widgets/vehicle_selector.dart';
export 'presentation/widgets/seat_selector.dart';
export 'presentation/widgets/booking_review.dart';
export 'presentation/widgets/fare_calculator.dart';

// Presentation layer - Screens
export 'presentation/screens/booking_flow_screen.dart';
