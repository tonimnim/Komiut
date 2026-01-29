import 'package:flutter_test/flutter_test.dart';
import 'package:komiut/features/home/domain/entities/trip_entity.dart';

void main() {
  group('TripEntity', () {
    late TripEntity completedTrip;
    late TripEntity failedTrip;

    setUp(() {
      completedTrip = TripEntity(
        id: 1,
        userId: 1,
        routeName: 'Route 101 - CBD to Westlands',
        fromLocation: 'CBD Terminal',
        toLocation: 'Westlands Terminal',
        fare: 50.0,
        status: 'completed',
        tripDate: DateTime(2025, 12, 20, 10, 30),
      );

      failedTrip = TripEntity(
        id: 2,
        userId: 1,
        routeName: 'Route 102 - CBD to Eastleigh',
        fromLocation: 'CBD Terminal',
        toLocation: 'Eastleigh Terminal',
        fare: 35.0,
        status: 'failed',
        tripDate: DateTime(2025, 12, 19, 14, 0),
      );
    });

    group('isCompleted', () {
      test('returns true for completed status', () {
        expect(completedTrip.isCompleted, true);
      });

      test('returns false for failed status', () {
        expect(failedTrip.isCompleted, false);
      });

      test('is case insensitive', () {
        final trip = TripEntity(
          id: 1,
          userId: 1,
          routeName: 'Test Route',
          fromLocation: 'A',
          toLocation: 'B',
          fare: 10.0,
          status: 'COMPLETED',
          tripDate: DateTime.now(),
        );
        expect(trip.isCompleted, true);
      });
    });

    group('isFailed', () {
      test('returns true for failed status', () {
        expect(failedTrip.isFailed, true);
      });

      test('returns false for completed status', () {
        expect(completedTrip.isFailed, false);
      });

      test('is case insensitive', () {
        final trip = TripEntity(
          id: 1,
          userId: 1,
          routeName: 'Test Route',
          fromLocation: 'A',
          toLocation: 'B',
          fare: 10.0,
          status: 'FAILED',
          tripDate: DateTime.now(),
        );
        expect(trip.isFailed, true);
      });
    });

    group('formattedFare', () {
      test('formats fare with KES currency', () {
        expect(completedTrip.formattedFare, 'KES 50');
      });

      test('formats fare without decimals', () {
        final trip = TripEntity(
          id: 1,
          userId: 1,
          routeName: 'Test Route',
          fromLocation: 'A',
          toLocation: 'B',
          fare: 75.99,
          status: 'completed',
          tripDate: DateTime.now(),
        );
        expect(trip.formattedFare, 'KES 76');
      });

      test('formats zero fare', () {
        final trip = TripEntity(
          id: 1,
          userId: 1,
          routeName: 'Test Route',
          fromLocation: 'A',
          toLocation: 'B',
          fare: 0.0,
          status: 'completed',
          tripDate: DateTime.now(),
        );
        expect(trip.formattedFare, 'KES 0');
      });
    });

    group('properties', () {
      test('stores all required properties', () {
        expect(completedTrip.id, 1);
        expect(completedTrip.userId, 1);
        expect(completedTrip.routeName, 'Route 101 - CBD to Westlands');
        expect(completedTrip.fromLocation, 'CBD Terminal');
        expect(completedTrip.toLocation, 'Westlands Terminal');
        expect(completedTrip.fare, 50.0);
        expect(completedTrip.status, 'completed');
        expect(completedTrip.tripDate, DateTime(2025, 12, 20, 10, 30));
      });
    });
  });
}
