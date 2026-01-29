/// Saved route entity.
///
/// Represents a favorite route saved by the passenger.
/// Used for quick access to frequently traveled routes.
library;

import 'package:equatable/equatable.dart';

/// Saved route entity representing a passenger's favorite route.
///
/// Passengers can save routes they frequently travel for quick access
/// in the app. This entity stores the essential route information
/// along with user-specific metadata like custom names.
class SavedRoute extends Equatable {
  /// Creates a saved route instance.
  const SavedRoute({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    this.customName,
    required this.savedAt,
    this.lastUsedAt,
    this.useCount = 0,
  });

  /// Unique identifier for this saved route entry.
  final String id;

  /// The ID of the actual route in the system.
  final String routeId;

  /// Display name of the route.
  final String routeName;

  /// Starting point of the route.
  final String startPoint;

  /// Ending point of the route.
  final String endPoint;

  /// Optional custom name given by the passenger.
  final String? customName;

  /// When the route was saved.
  final DateTime savedAt;

  /// When the route was last used by the passenger.
  final DateTime? lastUsedAt;

  /// Number of times this route has been used.
  final int useCount;

  /// Returns the display name (custom name if set, otherwise route name).
  String get displayName => customName ?? routeName;

  /// Returns a summary of the route (start to end).
  String get summary => '$startPoint to $endPoint';

  /// Returns true if the route has been used at least once.
  bool get hasBeenUsed => useCount > 0;

  /// Creates a copy with modified fields.
  SavedRoute copyWith({
    String? id,
    String? routeId,
    String? routeName,
    String? startPoint,
    String? endPoint,
    String? customName,
    DateTime? savedAt,
    DateTime? lastUsedAt,
    int? useCount,
  }) {
    return SavedRoute(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      customName: customName ?? this.customName,
      savedAt: savedAt ?? this.savedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }

  /// Marks the route as used, updating lastUsedAt and incrementing useCount.
  SavedRoute markAsUsed() {
    return copyWith(
      lastUsedAt: DateTime.now(),
      useCount: useCount + 1,
    );
  }

  @override
  List<Object?> get props => [
        id,
        routeId,
        routeName,
        startPoint,
        endPoint,
        customName,
        savedAt,
        lastUsedAt,
        useCount,
      ];
}
