/// Domain entity.
///
/// Represents a domain/region for operations.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Domain entity representing an operational region.
class Domain extends Equatable {
  /// Creates a new Domain instance.
  const Domain({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.code,
    this.parentDomainId,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// Domain name.
  final String name;

  /// Domain status.
  final DomainStatus status;

  /// Description of the domain.
  final String? description;

  /// Domain code (e.g., "NRB" for Nairobi).
  final String? code;

  /// ID of parent domain (for hierarchical domains).
  final String? parentDomainId;

  /// When the domain was created.
  final DateTime? createdAt;

  /// When the domain was last updated.
  final DateTime? updatedAt;

  /// Whether the domain is active.
  bool get isActive => status == DomainStatus.active;

  /// Whether this is a sub-domain.
  bool get isSubDomain => parentDomainId != null;

  /// Display name with code if available.
  String get displayName {
    if (code != null) {
      return '$code - $name';
    }
    return name;
  }

  /// Creates a copy with modified fields.
  Domain copyWith({
    String? id,
    String? name,
    DomainStatus? status,
    String? description,
    String? code,
    String? parentDomainId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Domain(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
      code: code ?? this.code,
      parentDomainId: parentDomainId ?? this.parentDomainId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        description,
        code,
        parentDomainId,
        createdAt,
        updatedAt,
      ];
}
