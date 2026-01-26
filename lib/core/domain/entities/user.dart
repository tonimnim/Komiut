/// User entity.
///
/// Represents a user in the domain layer.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// User entity representing a registered user.
class User extends Equatable {
  /// Creates a new User instance.
  const User({
    required this.id,
    required this.email,
    this.phone,
    required this.role,
    this.organizationId,
    required this.status,
    this.fullName,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// User's email address.
  final String email;

  /// User's phone number.
  final String? phone;

  /// User's role in the system.
  final UserRole role;

  /// ID of the organization the user belongs to (for drivers/touts).
  final String? organizationId;

  /// User's account status.
  final UserStatus status;

  /// User's full name.
  final String? fullName;

  /// URL to user's profile image.
  final String? profileImage;

  /// When the user was created.
  final DateTime? createdAt;

  /// When the user was last updated.
  final DateTime? updatedAt;

  /// Whether the user is a passenger.
  bool get isPassenger => role == UserRole.passenger;

  /// Whether the user is a driver.
  bool get isDriver => role == UserRole.driver;

  /// Whether the user is a tout.
  bool get isTout => role == UserRole.tout;

  /// Whether the user is an admin.
  bool get isAdmin => role == UserRole.admin;

  /// Whether the user is active.
  bool get isActive => status == UserStatus.active;

  /// Whether the user belongs to an organization.
  bool get hasOrganization => organizationId != null;

  /// Creates a copy with modified fields.
  User copyWith({
    String? id,
    String? email,
    String? phone,
    UserRole? role,
    String? organizationId,
    UserStatus? status,
    String? fullName,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        role,
        organizationId,
        status,
        fullName,
        profileImage,
        createdAt,
        updatedAt,
      ];
}
