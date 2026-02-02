/// User API model.
///
/// Data transfer object for User entity matching API schema.
library;

import '../../domain/entities/user.dart';
import '../../domain/enums/enums.dart';

/// User model for API communication.
class UserModel {
  /// Creates a new UserModel instance.
  const UserModel({
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

  /// Creates from JSON map.
  ///
  /// Handles all API response fields including nullable fields.
  /// Role can be either a string (e.g., 'passenger') or an int (API enum value).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseId(json['id']),
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String?,
      role: _parseRole(json['role']),
      organizationId: _parseStringOrNull(json['organizationId']),
      status: _parseStatus(json['status']),
      fullName: json['fullName'] as String? ??
          json['userName'] as String? ??
          json['name'] as String?,
      profileImage:
          json['profileImage'] as String? ?? json['avatar'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Parse ID from various formats (string, int).
  static String _parseId(dynamic id) {
    if (id == null) return '';
    if (id is String) return id;
    if (id is int) return id.toString();
    return id.toString();
  }

  /// Parse role from string or int.
  ///
  /// API might return role as:
  /// - String: 'passenger', 'driver', 'tout', 'admin'
  /// - Int: 0=passenger, 1=driver, 2=tout, 3=admin
  static UserRole _parseRole(dynamic role) {
    if (role == null) return UserRole.passenger;

    if (role is String) {
      return userRoleFromString(role);
    }

    if (role is int) {
      return switch (role) {
        0 => UserRole.passenger,
        1 => UserRole.driver,
        2 => UserRole.tout,
        3 => UserRole.admin,
        _ => UserRole.passenger,
      };
    }

    return UserRole.passenger;
  }

  /// Parse status from string or bool.
  static UserStatus _parseStatus(dynamic status) {
    if (status == null) return UserStatus.active;

    if (status is String) {
      return status.toLowerCase() == 'active'
          ? UserStatus.active
          : UserStatus.inactive;
    }

    if (status is bool) {
      return status ? UserStatus.active : UserStatus.inactive;
    }

    if (status is int) {
      return status == 1 ? UserStatus.active : UserStatus.inactive;
    }

    return UserStatus.active;
  }

  /// Parse nullable string from dynamic value.
  static String? _parseStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  /// Parse DateTime from string or null.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is DateTime) return value;
    return null;
  }

  /// Creates from entity.
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      organizationId: entity.organizationId,
      status: entity.status,
      fullName: entity.fullName,
      profileImage: entity.profileImage,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String email;
  final String? phone;
  final UserRole role;
  final String? organizationId;
  final UserStatus status;
  final String? fullName;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (phone != null) 'phone': phone,
        'role': role.toApiValue(),
        if (organizationId != null) 'organizationId': organizationId,
        'status': status.toApiValue(),
        if (fullName != null) 'fullName': fullName,
        if (profileImage != null) 'profileImage': profileImage,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  User toEntity() => User(
        id: id,
        email: email,
        phone: phone,
        role: role,
        organizationId: organizationId,
        status: status,
        fullName: fullName,
        profileImage: profileImage,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
