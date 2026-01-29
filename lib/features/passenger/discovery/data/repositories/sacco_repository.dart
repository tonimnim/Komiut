/// Sacco repository.
///
/// Provides Sacco data access for passenger discovery feature.
/// Implements repository pattern for clean separation of concerns.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/sacco.dart';
import '../datasources/sacco_remote_datasource.dart';

/// Provider for Sacco repository.
final saccoRepositoryProvider = Provider<SaccoRepository>((ref) {
  final remoteDataSource = ref.watch(saccoRemoteDataSourceProvider);
  return SaccoRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract Sacco repository interface.
///
/// Defines the contract for Sacco data access in the discovery feature.
/// All methods return `Either<Failure, T>` for consistent error handling.
abstract class SaccoRepository {
  /// Gets all Saccos (Organizations).
  ///
  /// Returns a list of [Sacco] entities on success,
  /// or a [Failure] on error.
  Future<Either<Failure, List<Sacco>>> getSaccos();

  /// Gets a single Sacco by its ID.
  ///
  /// [id] - The unique identifier of the Sacco.
  /// Returns the [Sacco] entity on success,
  /// or a [Failure] on error.
  Future<Either<Failure, Sacco>> getSaccoById(String id);

  /// Gets all Saccos that operate on a specific route.
  ///
  /// [routeId] - The unique identifier of the route.
  /// Returns a list of [Sacco] entities that operate on the route,
  /// or a [Failure] on error.
  Future<Either<Failure, List<Sacco>>> getSaccosByRoute(String routeId);

  /// Searches Saccos by name or description.
  ///
  /// [query] - The search query string.
  /// Returns a list of [Sacco] entities matching the query,
  /// or a [Failure] on error.
  Future<Either<Failure, List<Sacco>>> searchSaccos(String query);
}

/// Implementation of [SaccoRepository].
///
/// Uses [SaccoRemoteDataSource] to fetch data from the API.
/// This implementation uses a remote-only approach; local caching
/// can be added in the future if needed.
class SaccoRepositoryImpl implements SaccoRepository {
  /// Creates a Sacco repository with the given remote datasource.
  SaccoRepositoryImpl({required this.remoteDataSource});

  /// Remote data source for API calls.
  final SaccoRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Sacco>>> getSaccos() async {
    return remoteDataSource.getSaccos();
  }

  @override
  Future<Either<Failure, Sacco>> getSaccoById(String id) async {
    return remoteDataSource.getSaccoById(id);
  }

  @override
  Future<Either<Failure, List<Sacco>>> getSaccosByRoute(String routeId) async {
    return remoteDataSource.getSaccosByRoute(routeId);
  }

  @override
  Future<Either<Failure, List<Sacco>>> searchSaccos(String query) async {
    return remoteDataSource.searchSaccos(query);
  }
}
