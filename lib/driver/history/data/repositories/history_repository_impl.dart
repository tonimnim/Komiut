import 'package:dartz/dartz.dart';

import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/core/network/api_exceptions.dart';
import 'package:komiut_app/driver/history/domain/entities/trip_history.dart';
import 'package:komiut_app/driver/history/domain/entities/trip_history_details.dart';
import 'package:komiut_app/driver/history/domain/repositories/history_repository.dart';
import 'package:komiut_app/driver/history/data/datasources/history_remote_datasource.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut_app/driver/earnings/data/models/earnings_model.dart';

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
      
      // Manual mapping since we didn't make a standalone model for the details response structure yet
      // This maps the complex nested response from API_REFERENCE.md
      
      final routeJson = json['route'];
      final earningsJson = json['earnings']; // Needs to match EarningsModel expectation

      // Construct RoutePoint dummies if not in response, or parse if they are
      // API ref says "route": { "name":..., "start":..., "end":... } which is partial CircleRoute
      // We might need to adapt CircleRoute to be nullable or create a simpler DTO.
      // For now, mapping best effort.
      
      final route = CircleRoute(
        id: 'unknown', // API ref doesn't return ID in details?
        number: '??', 
        name: routeJson['name'],
        circleId: 'unknown',
        startPoint: RoutePoint(name: routeJson['start'], lat: 0, lng: 0),
        endPoint: RoutePoint(name: routeJson['end'], lat: 0, lng: 0),
        stops: const [],
        fare: 0, // Not in this specific response snippet
        estimatedDurationMins: 0,
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
           date: DateTime.parse(json['started_at']), // approximate
           passengerCount: json['passenger_count'],
           farePerPassenger: 0, // Missing in this response
           grossFare: (earningsJson['gross_fare'] as num).toDouble(),
           platformFeePercent: 0, // Missing
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
