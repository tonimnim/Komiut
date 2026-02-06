import '../../domain/entities/driver_profile.dart';

/// Data model for driver profile from API.
///
/// Maps to PersonnelDto from the backend API:
/// GET /api/Personnel
class DriverProfileModel {
  DriverProfileModel({
    required this.id,
    required this.organizationId,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.status,
    this.createdAt,
    this.vehicleId,
    this.photoUrl,
    this.rating,
    this.totalTrips,
  });

  final String id;
  final String organizationId;
  final String name;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? role;
  final int? status;
  final DateTime? createdAt;
  final String? vehicleId;
  final String? photoUrl;
  final double? rating;
  final int? totalTrips;

  /// Creates model from API JSON response.
  ///
  /// Handles PersonnelDto structure:
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "organizationId": "uuid",
  ///   "name": "string",
  ///   "email": "string",
  ///   "phone": "string",
  ///   "role": { "roleId": "uuid", "isActive": true },
  ///   "status": 0,
  ///   "createdAt": "2026-02-02T01:14:04.645Z"
  /// }
  /// ```
  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as Map<String, dynamic>?,
      status: json['status'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      vehicleId: json['vehicleId']?.toString(),
      photoUrl: json['photoUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalTrips: json['totalTrips'] as int?,
    );
  }

  /// Converts model to JSON for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'organizationId': organizationId,
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (vehicleId != null) 'vehicleId': vehicleId,
      };

  /// Converts to domain entity for use in presentation layer.
  DriverProfile toEntity() => DriverProfile(
        id: id,
        fullName: name,
        email: email ?? '',
        phoneNumber: phone,
        photoUrl: photoUrl,
        vehicleId: vehicleId,
        saccoId: organizationId,
        licenseNumber: null,
        isVerified: status == 1,
        isOnline: role?['isActive'] as bool? ?? false,
        rating: rating,
        totalTrips: totalTrips,
      );

  /// Creates model from domain entity.
  factory DriverProfileModel.fromEntity(DriverProfile entity) {
    return DriverProfileModel(
      id: entity.id,
      organizationId: entity.saccoId ?? '',
      name: entity.fullName,
      email: entity.email,
      phone: entity.phoneNumber,
      vehicleId: entity.vehicleId,
      photoUrl: entity.photoUrl,
      rating: entity.rating,
      totalTrips: entity.totalTrips,
    );
  }
}
