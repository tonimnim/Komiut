/// Organization API model.
///
/// Data transfer object for Organization entity matching API schema.
library;

import '../../domain/entities/organization.dart';
import '../../domain/enums/enums.dart';

/// Organization model for API communication.
class OrganizationModel {
  /// Creates a new OrganizationModel instance.
  const OrganizationModel({
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

  /// Creates from JSON map.
  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] == 'company'
          ? OrganizationType.company
          : OrganizationType.sacco,
      status: json['status'] == 'active'
          ? OrganizationStatus.active
          : OrganizationStatus.inactive,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory OrganizationModel.fromEntity(Organization entity) {
    return OrganizationModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      status: entity.status,
      description: entity.description,
      logoUrl: entity.logoUrl,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      address: entity.address,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String name;
  final OrganizationType type;
  final OrganizationStatus status;
  final String? description;
  final String? logoUrl;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toApiValue(),
        'status': status == OrganizationStatus.active ? 'active' : 'inactive',
        if (description != null) 'description': description,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (contactEmail != null) 'contactEmail': contactEmail,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (address != null) 'address': address,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Organization toEntity() => Organization(
        id: id,
        name: name,
        type: type,
        status: status,
        description: description,
        logoUrl: logoUrl,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        address: address,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
