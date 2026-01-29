import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final String? profileImage;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, email, fullName, phone, profileImage];
}
