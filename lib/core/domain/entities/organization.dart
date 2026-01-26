/// Organization entity.
///
/// Represents an organization (Sacco/Company) in the domain layer.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Organization entity representing a transport company or sacco.
class Organization extends Equatable {
  /// Creates a new Organization instance.
  const Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.description,
    this.logoUrl,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// Organization name.
  final String name;

  /// Type of organization.
  final OrganizationType type;

  /// Organization status.
  final OrganizationStatus status;

  /// Description of the organization.
  final String? description;

  /// URL to organization logo.
  final String? logoUrl;

  /// Contact email.
  final String? contactEmail;

  /// Contact phone number.
  final String? contactPhone;

  /// Physical address.
  final String? address;

  /// When the organization was created.
  final DateTime? createdAt;

  /// When the organization was last updated.
  final DateTime? updatedAt;

  /// Whether the organization is a sacco.
  bool get isSacco => type == OrganizationType.sacco;

  /// Whether the organization is a company.
  bool get isCompany => type == OrganizationType.company;

  /// Whether the organization is active.
  bool get isActive => status == OrganizationStatus.active;

  /// Creates a copy with modified fields.
  Organization copyWith({
    String? id,
    String? name,
    OrganizationType? type,
    OrganizationStatus? status,
    String? description,
    String? logoUrl,
    String? contactEmail,
    String? contactPhone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        status,
        description,
        logoUrl,
        contactEmail,
        contactPhone,
        address,
        createdAt,
        updatedAt,
      ];
}
