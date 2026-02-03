/// Shared features barrel file.
///
/// Exports features that are used by both drivers and passengers.
/// These are role-agnostic features that provide common functionality.
library;

// Profile management
export 'profile/presentation/screens/profile_screen.dart';

// Queue management - export with 'show' to avoid conflicts with driver's QueueScreen
export 'queue/presentation/screens/queue_screen.dart' show PassengerQueueScreen;
