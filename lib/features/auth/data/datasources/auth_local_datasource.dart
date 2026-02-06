import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String email, String password, String fullName);
  Future<void> forgotPassword(String email);
  Future<bool> verify2FA(String code);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase database;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({
    required this.database,
    required this.secureStorage,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Get user from database
      final user = await database.getUserByEmail(email);
      if (user == null) {
        throw const AuthenticationException('User not found');
      }

      // Verify password
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      if (user.passwordHash != passwordHash) {
        throw const AuthenticationException('Invalid password');
      }

      // Generate and save token
      final token = _generateToken();
      await database.saveAuthToken(
        AuthTokensCompanion.insert(
          userId: user.id,
          accessToken: token,
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      // Save user ID to secure storage
      await secureStorage.write(key: 'userId', value: user.id.toString());

      return UserModel.fromDatabase(user);
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException(e.toString());
    }
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already exists
      final existingUser = await database.getUserByEmail(email);
      if (existingUser != null) {
        throw const AuthenticationException('Email already registered');
      }

      // Hash password
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      // Create user
      final userId = await database.createUser(
        UsersCompanion.insert(
          email: email,
          passwordHash: passwordHash,
          fullName: fullName,
        ),
      );

      // Create wallet for new user
      await database.createWallet(
        WalletsCompanion.insert(
          userId: userId,
          balance: const Value(0.0),
        ),
      );

      // Get created user
      final user = await database.getUserById(userId);
      if (user == null) {
        throw const DatabaseException('Failed to create user');
      }

      return UserModel.fromDatabase(user);
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user exists
      final user = await database.getUserByEmail(email);
      if (user == null) {
        throw const AuthenticationException('Email not found');
      }

      // In a real app, send password reset email
      // For demo, we just simulate success
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException(e.toString());
    }
  }

  @override
  Future<bool> verify2FA(String code) async {
    // TODO: Integrate with real backend 2FA verification.
    // This should call the remote datasource or API endpoint
    // (e.g., /api/MobileAppAuth/send-2fa) to verify the code.
    // The local datasource is not the right place for 2FA verification
    // since it requires server-side validation.
    throw UnimplementedError(
      '2FA verification requires backend integration. '
      'Use the remote datasource with the appropriate API endpoint.',
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Get user ID from secure storage
      final userIdStr = await secureStorage.read(key: 'userId');
      if (userIdStr == null) return null;

      final userId = int.parse(userIdStr);

      // Check if token is valid
      final isValid = await database.isTokenValid(userId);
      if (!isValid) {
        await secureStorage.delete(key: 'userId');
        return null;
      }

      // Get user from database
      final user = await database.getUserById(userId);
      if (user == null) return null;

      return UserModel.fromDatabase(user);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Get user ID from secure storage
      final userIdStr = await secureStorage.read(key: 'userId');
      if (userIdStr != null) {
        final userId = int.parse(userIdStr);
        // Delete auth token from database
        await database.deleteAuthTokenByUserId(userId);
      }

      // Clear secure storage
      await secureStorage.delete(key: 'userId');
    } catch (e) {
      throw AuthenticationException(e.toString());
    }
  }

  String _generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return sha256.convert(utf8.encode('$timestamp-$random')).toString();
  }
}
