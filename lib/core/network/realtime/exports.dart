/// Real-time communication barrel file.
///
/// Exports all real-time related files for easy importing.
library;

export 'realtime_connection_state.dart';
export 'realtime_providers.dart';
// Hide TripStatus to avoid conflict with domain/enums/enums.dart
export 'realtime_service.dart' hide TripStatus;
export 'signalr_service.dart';
