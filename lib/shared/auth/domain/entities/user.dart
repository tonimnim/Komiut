import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String? profileImage;
  final double? rating;
  final int? totalTrips;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.profileImage,
    this.rating,
    this.totalTrips,
  });

  bool get isDriver => role == 'driver';
  bool get isPassenger => role == 'passenger';

  @override
  List<Object?> get props => [id, name, phone, email, role, profileImage, rating, totalTrips];
}
