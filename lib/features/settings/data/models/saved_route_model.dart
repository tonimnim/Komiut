/// Saved route model for JSON serialization.
///
/// Data transfer object for saved routes with JSON support.
library;

import '../../domain/entities/saved_route.dart';

/// Model for saved routes with JSON serialization.
class SavedRouteModel {
  /// Creates a saved route model.
  const SavedRouteModel({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    this.customName,
    required this.savedAt,
    this.lastUsedAt,
    required this.useCount,
  });

  /// Creates a model from a domain entity.
  factory SavedRouteModel.fromEntity(SavedRoute entity) {
    return SavedRouteModel(
      id: entity.id,
      routeId: entity.routeId,
      routeName: entity.routeName,
      startPoint: entity.startPoint,
      endPoint: entity.endPoint,
      customName: entity.customName,
      savedAt: entity.savedAt.toIso8601String(),
      lastUsedAt: entity.lastUsedAt?.toIso8601String(),
      useCount: entity.useCount,
    );
  }

  /// Creates a model from JSON.
  factory SavedRouteModel.fromJson(Map<String, dynamic> json) {
    return SavedRouteModel(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      routeName: json['routeName'] as String,
      startPoint: json['startPoint'] as String,
      endPoint: json['endPoint'] as String,
      customName: json['customName'] as String?,
      savedAt: json['savedAt'] as String,
      lastUsedAt: json['lastUsedAt'] as String?,
      useCount: json['useCount'] as int? ?? 0,
    );
  }

  /// Unique identifier.
  final String id;

  /// Route ID in the system.
  final String routeId;

  /// Route display name.
  final String routeName;

  /// Starting point.
  final String startPoint;

  /// Ending point.
  final String endPoint;

  /// Custom name set by user.
  final String? customName;

  /// ISO 8601 timestamp when saved.
  final String savedAt;

  /// ISO 8601 timestamp when last used.
  final String? lastUsedAt;

  /// Number of times used.
  final int useCount;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'routeId': routeId,
        'routeName': routeName,
        'startPoint': startPoint,
        'endPoint': endPoint,
        if (customName != null) 'customName': customName,
        'savedAt': savedAt,
        if (lastUsedAt != null) 'lastUsedAt': lastUsedAt,
        'useCount': useCount,
      };

  /// Converts to domain entity.
  SavedRoute toEntity() {
    return SavedRoute(
      id: id,
      routeId: routeId,
      routeName: routeName,
      startPoint: startPoint,
      endPoint: endPoint,
      customName: customName,
      savedAt: DateTime.parse(savedAt),
      lastUsedAt: lastUsedAt != null ? DateTime.parse(lastUsedAt!) : null,
      useCount: useCount,
    );
  }
}
