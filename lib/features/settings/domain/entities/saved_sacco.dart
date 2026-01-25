/// Saved Sacco entity.
///
/// Represents a favorite Sacco (transport organization) saved by the passenger.
/// Used for quick access to preferred transport operators.
library;

import 'package:equatable/equatable.dart';

/// Saved Sacco entity representing a passenger's favorite transport operator.
///
/// Passengers can save Saccos they prefer to travel with for quick access.
/// This entity stores the essential Sacco information along with user-specific
/// metadata like custom names and usage statistics.
class SavedSacco extends Equatable {
  /// Creates a saved Sacco instance.
  const SavedSacco({
    required this.id,
    required this.saccoId,
    required this.saccoName,
    this.logoUrl,
    this.description,
    this.customName,
    required this.savedAt,
    this.lastUsedAt,
    this.useCount = 0,
    this.routeIds = const [],
  });

  /// Unique identifier for this saved Sacco entry.
  final String id;

  /// The ID of the actual Sacco in the system.
  final String saccoId;

  /// Display name of the Sacco.
  final String saccoName;

  /// URL to the Sacco's logo image.
  final String? logoUrl;

  /// Brief description of the Sacco.
  final String? description;

  /// Optional custom name given by the passenger.
  final String? customName;

  /// When the Sacco was saved.
  final DateTime savedAt;

  /// When the Sacco was last used by the passenger.
  final DateTime? lastUsedAt;

  /// Number of times this Sacco has been used.
  final int useCount;

  /// List of route IDs operated by this Sacco.
  final List<String> routeIds;

  /// Returns the display name (custom name if set, otherwise Sacco name).
  String get displayName => customName ?? saccoName;

  /// Returns true if the Sacco has been used at least once.
  bool get hasBeenUsed => useCount > 0;

  /// Returns true if the Sacco has a logo.
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Returns the number of routes this Sacco operates.
  int get routeCount => routeIds.length;

  /// Creates a copy with modified fields.
  SavedSacco copyWith({
    String? id,
    String? saccoId,
    String? saccoName,
    String? logoUrl,
    String? description,
    String? customName,
    DateTime? savedAt,
    DateTime? lastUsedAt,
    int? useCount,
    List<String>? routeIds,
  }) {
    return SavedSacco(
      id: id ?? this.id,
      saccoId: saccoId ?? this.saccoId,
      saccoName: saccoName ?? this.saccoName,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      customName: customName ?? this.customName,
      savedAt: savedAt ?? this.savedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
      routeIds: routeIds ?? this.routeIds,
    );
  }

  /// Marks the Sacco as used, updating lastUsedAt and incrementing useCount.
  SavedSacco markAsUsed() {
    return copyWith(
      lastUsedAt: DateTime.now(),
      useCount: useCount + 1,
    );
  }

  @override
  List<Object?> get props => [
        id,
        saccoId,
        saccoName,
        logoUrl,
        description,
        customName,
        savedAt,
        lastUsedAt,
        useCount,
        routeIds,
      ];
}
