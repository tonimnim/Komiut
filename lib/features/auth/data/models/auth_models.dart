/// Auth API models.
///
/// Request and response models for authentication API endpoints.
library;

import '../../../../core/domain/enums/enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Login
// ─────────────────────────────────────────────────────────────────────────────

/// Login request model matching MobileLoginCommand.
class LoginRequestModel {
  /// Creates a login request.
  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  /// User's email.
  final String email;

  /// User's password.
  final String password;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Login response model matching MobileLoginDto.
class LoginResponseModel {
  /// Creates a login response.
  const LoginResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.userId,
    this.email,
    this.role,
    this.organizationId,
    this.fullName,
  });

  /// Creates from JSON.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String? ?? json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
      userId: json['userId'] as String? ?? json['id'] as String?,
      email: json['email'] as String?,
      role: json['role'] != null
          ? userRoleFromString(json['role'] as String)
          : null,
      organizationId: json['organizationId'] as String?,
      fullName: json['fullName'] as String? ?? json['userName'] as String?,
    );
  }

  /// Access token.
  final String accessToken;

  /// Refresh token.
  final String? refreshToken;

  /// Token expiration time in seconds.
  final int? expiresIn;

  /// User ID.
  final String? userId;

  /// User email.
  final String? email;

  /// User role.
  final UserRole? role;

  /// Organization ID.
  final String? organizationId;

  /// User's full name.
  final String? fullName;
}

// ─────────────────────────────────────────────────────────────────────────────
// Registration
// ─────────────────────────────────────────────────────────────────────────────

/// Registration request model matching MobileRegisrationCommand.
class RegisterRequestModel {
  /// Creates a registration request.
  const RegisterRequestModel({
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.userName,
  });

  /// User's email.
  final String email;

  /// User's phone number (matches API field: phoneNumber).
  final String phoneNumber;

  /// User's password.
  final String password;

  /// Password confirmation (required by API).
  final String confirmPassword;

  /// User's full name.
  final String userName;

  /// Converts to JSON matching MobileRegisrationCommand schema.
  Map<String, dynamic> toJson() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
        'userName': userName,
      };
}

/// Registration response model.
class RegisterResponseModel {
  /// Creates a registration response.
  const RegisterResponseModel({
    required this.success,
    this.message,
    this.userId,
  });

  /// Creates from JSON.
  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      userId: json['userId'] as String? ?? json['id'] as String?,
    );
  }

  /// Whether registration was successful.
  final bool success;

  /// Response message.
  final String? message;

  /// Created user ID.
  final String? userId;
}

// ─────────────────────────────────────────────────────────────────────────────
// Password Reset
// ─────────────────────────────────────────────────────────────────────────────

/// Password reset request model.
class ResetPasswordRequestModel {
  /// Creates a password reset request.
  const ResetPasswordRequestModel({
    required this.phoneNumber,
  });

  /// User's phone number.
  final String phoneNumber;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
      };
}

/// Password reset response model.
class ResetPasswordResponseModel {
  /// Creates a password reset response.
  const ResetPasswordResponseModel({
    required this.success,
    this.message,
  });

  /// Creates from JSON.
  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }

  /// Whether reset request was successful.
  final bool success;

  /// Response message.
  final String? message;
}
