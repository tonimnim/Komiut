/// Sacco entity for passenger discovery.
///
/// Represents a Sacco (transport organization) from the passenger's perspective.
/// This is a passenger-friendly wrapper around the core Organization entity,
/// focusing on fields relevant for passenger discovery and booking.
library;

import 'package:equatable/equatable.dart';

/// Sacco entity representing a transport organization for passengers.
///
/// This entity contains the information passengers need when discovering
/// and selecting transport operators (Saccos) for their journeys.
class Sacco extends Equatable {
  /// Creates a new Sacco instance.
  const Sacco({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.routeIds = const [],
    this.contactPhone,
    this.contactEmail,
    this.isActive = true,
  });

  /// Unique identifier for the Sacco.
  final String id;

  /// Display name of the Sacco.
  final String name;

  /// Optional description of the Sacco and its services.
  final String? description;

  /// URL to the Sacco's logo image.
  final String? logoUrl;

  /// List of route IDs that this Sacco operates.
  final List<String> routeIds;

  /// Contact phone number for passenger inquiries.
  final String? contactPhone;

  /// Contact email for passenger inquiries.
  final String? contactEmail;

  /// Whether the Sacco is currently active and accepting passengers.
  final bool isActive;

  /// Returns true if the Sacco has contact information available.
  bool get hasContactInfo => contactPhone != null || contactEmail != null;

  /// Returns true if the Sacco has a logo.
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Returns the number of routes this Sacco operates.
  int get routeCount => routeIds.length;

  /// Returns true if this Sacco operates on the given route.
  bool operatesOnRoute(String routeId) => routeIds.contains(routeId);

  /// Creates a copy with modified fields.
  Sacco copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    List<String>? routeIds,
    String? contactPhone,
    String? contactEmail,
    bool? isActive,
  }) {
    return Sacco(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      routeIds: routeIds ?? this.routeIds,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        routeIds,
        contactPhone,
        contactEmail,
        isActive,
      ];
}
