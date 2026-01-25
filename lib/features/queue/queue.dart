/// Queue feature exports.
///
/// Provides access to vehicle queue functionality including:
/// - Domain entities for queue and queued vehicles
/// - Data models for API communication
/// - Remote datasource for fetching queue data
/// - Providers for state management
/// - Real-time queue updates via WebSocket
library;

// Domain entities
export 'domain/entities/queued_vehicle.dart';
export 'domain/entities/vehicle_queue.dart';
export 'domain/entities/queue_vehicle.dart';
export 'domain/entities/queue_event.dart';
export 'domain/entities/queue_state.dart';

// Data models
export 'data/models/queued_vehicle_model.dart';
export 'data/models/vehicle_queue_model.dart';

// Datasources
export 'data/datasources/queue_remote_datasource.dart';

// Notification types
export 'domain/queue_notification_types.dart';

// Providers
export 'presentation/providers/queue_providers.dart';
export 'presentation/providers/realtime_queue_providers.dart';
export 'presentation/providers/queue_update_handler.dart';
export 'presentation/providers/notification_providers.dart';

// Screens
export 'presentation/screens/queue_screen.dart';

// Widgets
export 'presentation/widgets/connection_status_indicator.dart';
export 'presentation/widgets/queue_vehicle_card.dart';
