/// Personnel entity.
///
/// Represents a driver or tout working for an organization.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Personnel entity representing drivers and touts.
class Personnel extends Equatable {
  /// Creates a new Personnel instance.
  const Personnel({
    required this.id,
    required this.organizationId,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    required this.status,
    this.userId,
    this.licenseNumber,
    this.licenseExpiry,
    this.currentVehicleId,
    this.profileImage,
    this.rating,
    this.totalTrips,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// ID of the organization.
  final String organizationId;

  /// Full name.
  final String name;

  /// Email address.
  final String? email;

  /// Phone number.
  final String? phone;

  /// Role (driver or tout).
  final PersonnelRole role;

  /// Employment status.
  final PersonnelStatus status;

  /// ID of linked user account.
  final String? userId;

  /// Driver's license number.
  final String? licenseNumber;

  /// When the license expires.
  final DateTime? licenseExpiry;

  /// ID of currently assigned vehicle.
  final String? currentVehicleId;

  /// URL to profile image.
  final String? profileImage;

  /// Average rating (1-5).
  final double? rating;

  /// Total completed trips.
  final int? totalTrips;

  /// When the record was created.
  final DateTime? createdAt;

  /// When the record was last updated.
  final DateTime? updatedAt;

  /// Whether this is a driver.
  bool get isDriver => role == PersonnelRole.driver;

  /// Whether this is a tout.
  bool get isTout => role == PersonnelRole.tout;

  /// Whether the personnel is active.
  bool get isActive => status == PersonnelStatus.active;

  /// Whether the personnel has a linked user account.
  bool get hasUserAccount => userId != null;

  /// Whether the personnel is assigned to a vehicle.
  bool get hasVehicle => currentVehicleId != null;

  /// Whether the license is expired.
  bool get isLicenseExpired {
    if (licenseExpiry == null) return false;
    return licenseExpiry!.isBefore(DateTime.now());
  }

  /// Whether the license will expire within 30 days.
  bool get isLicenseExpiringSoon {
    if (licenseExpiry == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return licenseExpiry!.isBefore(thirtyDaysFromNow) &&
        licenseExpiry!.isAfter(DateTime.now());
  }

  /// Creates a copy with modified fields.
  Personnel copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? email,
    String? phone,
    PersonnelRole? role,
    PersonnelStatus? status,
    String? userId,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? currentVehicleId,
    String? profileImage,
    double? rating,
    int? totalTrips,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Personnel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        organizationId,
        name,
        email,
        phone,
        role,
        status,
        userId,
        licenseNumber,
        licenseExpiry,
        currentVehicleId,
        profileImage,
        rating,
        totalTrips,
        createdAt,
        updatedAt,
      ];
}
