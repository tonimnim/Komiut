/// Personnel API model.
///
/// Data transfer object for Personnel entity matching API schema.
library;

import '../../domain/entities/personnel.dart';
import '../../domain/enums/enums.dart';

/// Personnel model for API communication.
class PersonnelModel {
  /// Creates a new PersonnelModel instance.
  const PersonnelModel({
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

  /// Creates from JSON map.
  factory PersonnelModel.fromJson(Map<String, dynamic> json) {
    return PersonnelModel(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] == 'tout' ? PersonnelRole.tout : PersonnelRole.driver,
      status: json['status'] == 'active'
          ? PersonnelStatus.active
          : PersonnelStatus.inactive,
      userId: json['userId'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.parse(json['licenseExpiry'] as String)
          : null,
      currentVehicleId: json['currentVehicleId'] as String?,
      profileImage: json['profileImage'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalTrips: json['totalTrips'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory PersonnelModel.fromEntity(Personnel entity) {
    return PersonnelModel(
      id: entity.id,
      organizationId: entity.organizationId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      status: entity.status,
      userId: entity.userId,
      licenseNumber: entity.licenseNumber,
      licenseExpiry: entity.licenseExpiry,
      currentVehicleId: entity.currentVehicleId,
      profileImage: entity.profileImage,
      rating: entity.rating,
      totalTrips: entity.totalTrips,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String organizationId;
  final String name;
  final String? email;
  final String? phone;
  final PersonnelRole role;
  final PersonnelStatus status;
  final String? userId;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? currentVehicleId;
  final String? profileImage;
  final double? rating;
  final int? totalTrips;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'organizationId': organizationId,
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'role': role.name,
        'status': status == PersonnelStatus.active ? 'active' : 'inactive',
        if (userId != null) 'userId': userId,
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (licenseExpiry != null)
          'licenseExpiry': licenseExpiry!.toIso8601String(),
        if (currentVehicleId != null) 'currentVehicleId': currentVehicleId,
        if (profileImage != null) 'profileImage': profileImage,
        if (rating != null) 'rating': rating,
        if (totalTrips != null) 'totalTrips': totalTrips,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Personnel toEntity() => Personnel(
        id: id,
        organizationId: organizationId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        status: status,
        userId: userId,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        currentVehicleId: currentVehicleId,
        profileImage: profileImage,
        rating: rating,
        totalTrips: totalTrips,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
