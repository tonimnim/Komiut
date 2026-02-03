/// Auth providers tests.
///
/// Tests for authentication state management including:
/// - Initial state
/// - Login flow
/// - Signup flow
/// - Logout
/// - Error handling
library;
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/features/auth/domain/entities/user_entity.dart';
import 'package:komiut/features/auth/domain/repositories/auth_repository.dart';
import 'package:komiut/features/auth/presentation/providers/auth_state_notifier.dart';

// Mock implementation of AuthRepository for testing
class MockAuthRepository implements AuthRepository {
  UserEntity? _currentUser;
  bool shouldFail = false;
  String failureMessage = 'Test failure';

  void setCurrentUser(UserEntity? user) {
    _currentUser = user;
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      return Left(ServerFailure(failureMessage));
    }
    _currentUser = UserEntity(
      id: 1,
      email: email,
      fullName: 'Test User',
      phone: '+254712345678',
    );
    return Right(_currentUser!);
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    if (shouldFail) {
      return Left(ServerFailure(failureMessage));
    }
    _currentUser = UserEntity(
      id: 1,
      email: email,
      fullName: fullName,
      phone: phoneNumber ?? '+254712345678',
    );
    return Right(_currentUser!);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (_currentUser != null) {
      return Right(_currentUser);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    _currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    if (shouldFail) {
      return Left(ServerFailure(failureMessage));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> verify2FA({required String code}) async {
    if (shouldFail) {
      return Left(ServerFailure(failureMessage));
    }
    return const Right(true);
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    return const Right('new_token');
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    return Right(_currentUser != null);
  }
}

void main() {
  group('AuthState', () {
    test('initial state has correct defaults', () {
      const state = AuthState();

      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isInitialized, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith creates new state with updated values', () {
      const state = AuthState();
      const user = UserEntity(
        id: 1,
        email: 'test@test.com',
        fullName: 'Test User',
        phone: '+254712345678',
      );

      final newState = state.copyWith(
        user: user,
        isLoading: true,
        isInitialized: true,
        error: 'Some error',
      );

      expect(newState.user, user);
      expect(newState.isLoading, isTrue);
      expect(newState.isInitialized, isTrue);
      expect(newState.error, 'Some error');
    });

    test('copyWith preserves existing values when not specified', () {
      const user = UserEntity(
        id: 1,
        email: 'test@test.com',
        fullName: 'Test User',
        phone: '+254712345678',
      );
      const state = AuthState(user: user, isInitialized: true);

      final newState = state.copyWith(isLoading: true);

      expect(newState.user, user);
      expect(newState.isInitialized, isTrue);
      expect(newState.isLoading, isTrue);
    });
  });

  group('AuthStateNotifier', () {
    late MockAuthRepository mockRepository;
    late AuthStateNotifier notifier;

    setUp(() {
      mockRepository = MockAuthRepository();
      notifier = AuthStateNotifier(mockRepository);
    });

    test('initial state is initialized after checking auth status', () async {
      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.isInitialized, isTrue);
      expect(notifier.state.user, isNull);
    });

    test('login updates state with user on success', () async {
      final success = await notifier.login('test@test.com', 'password123');

      expect(success, isTrue);
      expect(notifier.state.user, isNotNull);
      expect(notifier.state.user?.email, 'test@test.com');
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('login sets error state on failure', () async {
      mockRepository.shouldFail = true;
      mockRepository.failureMessage = 'Invalid credentials';

      final success = await notifier.login('test@test.com', 'wrong_password');

      expect(success, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, 'Invalid credentials');
    });

    test('signUp updates state with user on success', () async {
      final success = await notifier.signUp(
        'new@test.com',
        'password123',
        'New User',
      );

      expect(success, isTrue);
      expect(notifier.state.user, isNotNull);
      expect(notifier.state.user?.email, 'new@test.com');
      expect(notifier.state.user?.fullName, 'New User');
    });

    test('signUp sets error state on failure', () async {
      mockRepository.shouldFail = true;
      mockRepository.failureMessage = 'Email already exists';

      final success = await notifier.signUp(
        'existing@test.com',
        'password123',
        'User',
      );

      expect(success, isFalse);
      expect(notifier.state.error, 'Email already exists');
    });

    test('logout clears user state', () async {
      // First login
      await notifier.login('test@test.com', 'password123');
      expect(notifier.state.user, isNotNull);

      // Then logout
      await notifier.logout();

      expect(notifier.state.user, isNull);
      expect(notifier.state.isInitialized, isTrue);
    });

    test('forgotPassword returns true on success', () async {
      final success = await notifier.forgotPassword('test@test.com');

      expect(success, isTrue);
      expect(notifier.state.isLoading, isFalse);
    });

    test('forgotPassword sets error on failure', () async {
      mockRepository.shouldFail = true;
      mockRepository.failureMessage = 'Email not found';

      final success = await notifier.forgotPassword('unknown@test.com');

      expect(success, isFalse);
      expect(notifier.state.error, 'Email not found');
    });

    test('verify2FA returns true on success', () async {
      final success = await notifier.verify2FA('123456');

      expect(success, isTrue);
      expect(notifier.state.isLoading, isFalse);
    });

    test('refreshUser updates user state', () async {
      // Set a user in the repository
      mockRepository.setCurrentUser(
        const UserEntity(
          id: 1,
          email: 'updated@test.com',
          fullName: 'Updated User',
          phone: '+254712345678',
        ),
      );

      await notifier.refreshUser();

      expect(notifier.state.user?.email, 'updated@test.com');
    });
  });

  group('AuthStateNotifier with initialized user', () {
    test('initializes with existing user', () async {
      final mockRepository = MockAuthRepository();
      mockRepository.setCurrentUser(
        const UserEntity(
          id: 1,
          email: 'existing@test.com',
          fullName: 'Existing User',
          phone: '+254712345678',
        ),
      );

      final notifier = AuthStateNotifier(mockRepository);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.isInitialized, isTrue);
      expect(notifier.state.user, isNotNull);
      expect(notifier.state.user?.email, 'existing@test.com');
    });
  });
}
