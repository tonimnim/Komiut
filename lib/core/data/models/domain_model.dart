/// Domain API model.
///
/// Data transfer object for Domain entity matching API schema.
library;

import '../../domain/entities/domain.dart';
import '../../domain/enums/enums.dart';

/// Domain model for API communication.
class DomainModel {
  /// Creates a new DomainModel instance.
  const DomainModel({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.code,
    this.parentDomainId,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates from JSON map.
  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] == 'active'
          ? DomainStatus.active
          : DomainStatus.inactive,
      description: json['description'] as String?,
      code: json['code'] as String?,
      parentDomainId: json['parentDomainId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory DomainModel.fromEntity(Domain entity) {
    return DomainModel(
      id: entity.id,
      name: entity.name,
      status: entity.status,
      description: entity.description,
      code: entity.code,
      parentDomainId: entity.parentDomainId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String name;
  final DomainStatus status;
  final String? description;
  final String? code;
  final String? parentDomainId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status == DomainStatus.active ? 'active' : 'inactive',
        if (description != null) 'description': description,
        if (code != null) 'code': code,
        if (parentDomainId != null) 'parentDomainId': parentDomainId,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Domain toEntity() => Domain(
        id: id,
        name: name,
        status: status,
        description: description,
        code: code,
        parentDomainId: parentDomainId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
