import 'package:equatable/equatable.dart';

/// Represents a driver's profile information.
class DriverProfile extends Equatable {
  const DriverProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.vehicleId,
    this.saccoId,
    this.licenseNumber,
    this.isVerified = false,
    this.isOnline = false,
    this.rating,
    this.totalTrips,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final String? vehicleId;
  final String? saccoId;
  final String? licenseNumber;
  final bool isVerified;
  final bool isOnline;
  final double? rating;
  final int? totalTrips;

  /// Whether the driver has a vehicle assigned.
  bool get hasVehicle => vehicleId != null;

  /// Whether the driver belongs to a sacco.
  bool get hasSacco => saccoId != null;

  /// Formatted rating for display.
  String get displayRating => rating?.toStringAsFixed(1) ?? 'N/A';

  /// Whether the driver can start accepting trips.
  bool get canAcceptTrips => isVerified && hasVehicle && hasSacco;

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phoneNumber,
        photoUrl,
        vehicleId,
        saccoId,
        licenseNumber,
        isVerified,
        isOnline,
        rating,
        totalTrips,
      ];

  DriverProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? vehicleId,
    String? saccoId,
    String? licenseNumber,
    bool? isVerified,
    bool? isOnline,
    double? rating,
    int? totalTrips,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicleId: vehicleId ?? this.vehicleId,
      saccoId: saccoId ?? this.saccoId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
    );
  }
}
