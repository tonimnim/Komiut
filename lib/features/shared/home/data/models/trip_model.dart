import '../../../../../core/database/app_database.dart';
import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.userId,
    required super.routeName,
    required super.fromLocation,
    required super.toLocation,
    required super.fare,
    required super.status,
    required super.tripDate,
  });

  factory TripModel.fromDatabase(Trip trip) {
    return TripModel(
      id: trip.id,
      userId: trip.userId,
      routeName: trip.routeName,
      fromLocation: trip.fromLocation,
      toLocation: trip.toLocation,
      fare: trip.fare,
      status: trip.status,
      tripDate: trip.tripDate,
    );
  }
}
