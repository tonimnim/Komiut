import 'package:dartz/dartz.dart';

import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/core/network/api_exceptions.dart';
import 'package:komiut/driver/history/domain/entities/trip_history.dart';
import 'package:komiut/driver/history/domain/entities/trip_history_details.dart';
import 'package:komiut/driver/history/domain/repositories/history_repository.dart';
import 'package:komiut/driver/history/data/datasources/history_remote_datasource.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/driver/earnings/data/models/earnings_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<TripHistory>>> getTripHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? routeId,
  }) async {
    try {
      final history = await remoteDataSource.getTripHistory(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
        routeId: routeId,
      );
      return Right(history);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripHistoryDetails>> getTripHistoryDetails(String tripId) async {
    try {
      final json = await remoteDataSource.getTripHistoryDetails(tripId);
      
      final routeJson = json['route'];
      final earningsJson = json['earnings'];

      final route = CircleRoute(
        id: 'unknown',
        name: routeJson['name'],
        code: '??',
        status: 'completed',
        organizationId: 'unknown',
        createdAt: DateTime.now(),
       );

      final details = TripHistoryDetails(
        tripId: json['trip_id'],
        status: json['status'],
        route: route,
        startedAt: DateTime.parse(json['started_at']),
        endedAt: DateTime.parse(json['ended_at']),
        durationMins: json['duration_mins'],
        distanceKm: (json['distance_km'] as num).toDouble(),
        passengerCount: json['passenger_count'],
        earnings: EarningsModel(
           tripId: json['trip_id'],
           routeName: routeJson['name'],
           date: DateTime.parse(json['started_at']),
           passengerCount: json['passenger_count'],
           farePerPassenger: 0,
           grossFare: (earningsJson['gross_fare'] as num).toDouble(),
           platformFeePercent: 0,
           platformFee: (earningsJson['platform_fee'] as num).toDouble(),
           netEarnings: (earningsJson['net_earnings'] as num).toDouble(),
        ),
      );
      
      return Right(details);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
