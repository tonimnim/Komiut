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
  /// Backend wraps responses in {"message": {...}}, so unwrap if needed.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['message'] is Map<String, dynamic>
        ? json['message'] as Map<String, dynamic>
        : json;
    return LoginResponseModel(
      accessToken: data['accessToken'] as String? ?? data['token'] as String,
      refreshToken: data['refreshToken'] as String?,
      expiresIn: data['expiresIn'] as int?,
      userId: data['userId'] as String? ?? data['id'] as String?,
      email: data['email'] as String?,
      role: data['role'] != null
          ? userRoleFromString(data['role'] as String)
          : null,
      organizationId: data['organizationId'] as String?,
      fullName: data['fullName'] as String? ?? data['userName'] as String?,
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
    required this.confirmedPassword,
    required this.firstName,
    required this.lastName,
  });

  /// User's email.
  final String email;

  /// User's phone number (matches API field: phoneNumber).
  final String phoneNumber;

  /// User's password.
  final String password;

  /// Password confirmation (required by API as "confirmedPassword").
  final String confirmedPassword;

  /// User's first name.
  final String firstName;

  /// User's last name.
  final String lastName;

  /// Converts to JSON matching MobileRegisrationCommand schema.
  /// The backend expects email and phoneNumber as objects with a "value" field.
  Map<String, dynamic> toJson() => {
        'email': {'value': email},
        'phoneNumber': {'value': phoneNumber},
        'password': password,
        'confirmedPassword': confirmedPassword,
        'firstName': firstName,
        'lastName': lastName,
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
  /// Backend wraps responses in {"message": {...}}, so unwrap if needed.
  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['message'] is Map<String, dynamic>
        ? json['message'] as Map<String, dynamic>
        : json;
    return RegisterResponseModel(
      success: data['success'] as bool? ?? true,
      message: data['message'] as String?,
      userId: data['userId'] as String? ?? data['id'] as String?,
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
  /// Backend wraps responses in {"message": {...}}, so unwrap if needed.
  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['message'] is Map<String, dynamic>
        ? json['message'] as Map<String, dynamic>
        : json;
    return ResetPasswordResponseModel(
      success: data['success'] as bool? ?? true,
      message: data['message'] as String?,
    );
  }

  /// Whether reset request was successful.
  final bool success;

  /// Response message.
  final String? message;
}
