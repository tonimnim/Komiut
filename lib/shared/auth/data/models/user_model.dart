import 'dart:convert';

import 'package:komiut_app/shared/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    required super.role,
    super.profileImage,
    super.rating,
    super.totalTrips,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      profileImage: json['profile_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalTrips: json['total_trips'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'rating': rating,
      'total_trips': totalTrips,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      role: user.role,
      profileImage: user.profileImage,
      rating: user.rating,
      totalTrips: user.totalTrips,
    );
  }
}
