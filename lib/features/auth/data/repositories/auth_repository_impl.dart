import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await localDataSource.login(email, password);
      return Right(user.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await localDataSource.signUp(email, password, fullName);
      return Right(user.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await localDataSource.forgotPassword(email);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> verify2FA({required String code}) async {
    try {
      final result = await localDataSource.verify2FA(code);
      return Right(result);
    } catch (e) {
      return Left(AuthenticationFailure('Verification failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return Right(user?.toEntity());
    } catch (e) {
      return Left(AuthenticationFailure('Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Logout failed'));
    }
  }
}
