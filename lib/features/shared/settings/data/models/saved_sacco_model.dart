/// Saved Sacco model for JSON serialization.
///
/// Data transfer object for saved Saccos with JSON support.
library;

import '../../domain/entities/saved_sacco.dart';

/// Model for saved Saccos with JSON serialization.
class SavedSaccoModel {
  /// Creates a saved Sacco model.
  const SavedSaccoModel({
    required this.id,
    required this.saccoId,
    required this.saccoName,
    this.logoUrl,
    this.description,
    this.customName,
    required this.savedAt,
    this.lastUsedAt,
    required this.useCount,
    required this.routeIds,
  });

  /// Creates a model from a domain entity.
  factory SavedSaccoModel.fromEntity(SavedSacco entity) {
    return SavedSaccoModel(
      id: entity.id,
      saccoId: entity.saccoId,
      saccoName: entity.saccoName,
      logoUrl: entity.logoUrl,
      description: entity.description,
      customName: entity.customName,
      savedAt: entity.savedAt.toIso8601String(),
      lastUsedAt: entity.lastUsedAt?.toIso8601String(),
      useCount: entity.useCount,
      routeIds: entity.routeIds,
    );
  }

  /// Creates a model from JSON.
  factory SavedSaccoModel.fromJson(Map<String, dynamic> json) {
    return SavedSaccoModel(
      id: json['id'] as String,
      saccoId: json['saccoId'] as String,
      saccoName: json['saccoName'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      customName: json['customName'] as String?,
      savedAt: json['savedAt'] as String,
      lastUsedAt: json['lastUsedAt'] as String?,
      useCount: json['useCount'] as int? ?? 0,
      routeIds: (json['routeIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Unique identifier.
  final String id;

  /// Sacco ID in the system.
  final String saccoId;

  /// Sacco display name.
  final String saccoName;

  /// Logo URL.
  final String? logoUrl;

  /// Description.
  final String? description;

  /// Custom name set by user.
  final String? customName;

  /// ISO 8601 timestamp when saved.
  final String savedAt;

  /// ISO 8601 timestamp when last used.
  final String? lastUsedAt;

  /// Number of times used.
  final int useCount;

  /// Route IDs operated by this Sacco.
  final List<String> routeIds;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'saccoId': saccoId,
        'saccoName': saccoName,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (description != null) 'description': description,
        if (customName != null) 'customName': customName,
        'savedAt': savedAt,
        if (lastUsedAt != null) 'lastUsedAt': lastUsedAt,
        'useCount': useCount,
        'routeIds': routeIds,
      };

  /// Converts to domain entity.
  SavedSacco toEntity() {
    return SavedSacco(
      id: id,
      saccoId: saccoId,
      saccoName: saccoName,
      logoUrl: logoUrl,
      description: description,
      customName: customName,
      savedAt: DateTime.parse(savedAt),
      lastUsedAt: lastUsedAt != null ? DateTime.parse(lastUsedAt!) : null,
      useCount: useCount,
      routeIds: routeIds,
    );
  }
}
