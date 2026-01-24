/// Sacco API model.
///
/// Data transfer object for Sacco entity matching the Organization API schema.
/// Handles JSON serialization/deserialization and conversion to domain entity.
library;

import '../../domain/entities/sacco.dart';

/// Sacco model for API communication.
///
/// Maps the API Organization schema to the Sacco domain entity.
/// The API returns Organizations, which are converted to Saccos for
/// the passenger-facing discovery feature.
class SaccoModel {
  /// Creates a new SaccoModel instance.
  const SaccoModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.routeIds = const [],
    this.contactPhone,
    this.contactEmail,
    this.status = 'active',
  });

  /// Creates a SaccoModel from JSON map (Organization API response).
  ///
  /// Maps the Organization API schema fields to SaccoModel:
  /// - `id` -> id
  /// - `name` -> name
  /// - `description` -> description
  /// - `logoUrl` -> logoUrl
  /// - `routeIds` -> routeIds (may be nested in response)
  /// - `contactPhone` -> contactPhone
  /// - `contactEmail` -> contactEmail
  /// - `status` -> status ('active' or 'inactive')
  factory SaccoModel.fromJson(Map<String, dynamic> json) {
    // Handle routeIds which may come in different formats
    List<String> parseRouteIds(dynamic routeIdsData) {
      if (routeIdsData == null) return [];
      if (routeIdsData is List) {
        return routeIdsData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return SaccoModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      routeIds: parseRouteIds(json['routeIds']),
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  /// Creates a SaccoModel from a Sacco entity.
  factory SaccoModel.fromEntity(Sacco entity) {
    return SaccoModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      logoUrl: entity.logoUrl,
      routeIds: entity.routeIds,
      contactPhone: entity.contactPhone,
      contactEmail: entity.contactEmail,
      status: entity.isActive ? 'active' : 'inactive',
    );
  }

  /// Unique identifier.
  final String id;

  /// Sacco name.
  final String name;

  /// Description of the Sacco.
  final String? description;

  /// URL to the Sacco's logo.
  final String? logoUrl;

  /// List of route IDs operated by this Sacco.
  final List<String> routeIds;

  /// Contact phone number.
  final String? contactPhone;

  /// Contact email.
  final String? contactEmail;

  /// Status string ('active' or 'inactive').
  final String status;

  /// Converts to JSON map for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (logoUrl != null) 'logoUrl': logoUrl,
        'routeIds': routeIds,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (contactEmail != null) 'contactEmail': contactEmail,
        'status': status,
      };

  /// Converts to domain Sacco entity.
  Sacco toEntity() => Sacco(
        id: id,
        name: name,
        description: description,
        logoUrl: logoUrl,
        routeIds: routeIds,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        isActive: status.toLowerCase() == 'active',
      );
}
