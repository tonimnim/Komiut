import 'package:flutter_test/flutter_test.dart';
import 'package:komiut/features/routes/domain/entities/route_entity.dart';

void main() {
  group('RouteEntity', () {
    late RouteEntity route;

    setUp(() {
      route = const RouteEntity(
        id: 1,
        name: 'Route 101',
        startPoint: 'CBD',
        endPoint: 'Westlands',
        stopsCount: 10,
        durationMinutes: 25,
        baseFare: 30.0,
        farePerStop: 5.0,
        currency: 'KES',
        stops: [
          'CBD Terminal',
          'Kencom',
          'University Way',
          'Museum Hill',
          'Parklands',
          'Chiromo',
          'Waiyaki Way',
          'ABC Place',
          'Sarit Centre',
          'Westlands Terminal',
        ],
        isFavorite: false,
      );
    });

    group('calculateFare', () {
      test('returns 0 when from and to stop are the same', () {
        expect(route.calculateFare(0, 0), 0);
        expect(route.calculateFare(5, 5), 0);
      });

      test('returns base fare for 1 stop travel', () {
        // Traveling 1 stop: baseFare + (farePerStop * 0) = 30
        expect(route.calculateFare(0, 1), 30.0);
        expect(route.calculateFare(4, 5), 30.0);
      });

      test('calculates fare correctly for 2 stops', () {
        // Traveling 2 stops: baseFare + (farePerStop * 1) = 30 + 5 = 35
        expect(route.calculateFare(0, 2), 35.0);
      });

      test('calculates fare correctly for 5 stops', () {
        // Traveling 5 stops: baseFare + (farePerStop * 4) = 30 + 20 = 50
        expect(route.calculateFare(0, 5), 50.0);
      });

      test('calculates fare correctly for full route', () {
        // Traveling 9 stops (0 to 9): baseFare + (farePerStop * 8) = 30 + 40 = 70
        expect(route.calculateFare(0, 9), 70.0);
      });

      test('calculates fare correctly for reverse direction', () {
        // Should work the same regardless of direction
        expect(route.calculateFare(9, 0), 70.0);
        expect(route.calculateFare(5, 2), 40.0); // 3 stops: 30 + (5 * 2) = 40
      });

      test('handles middle route segments', () {
        // From stop 3 to stop 7 (4 stops): 30 + (5 * 3) = 45
        expect(route.calculateFare(3, 7), 45.0);
      });
    });

    group('formatFare', () {
      test('formats fare with currency', () {
        expect(route.formatFare(100.0), 'KES 100');
      });

      test('formats fare without decimals', () {
        expect(route.formatFare(150.75), 'KES 151');
      });

      test('formats zero fare', () {
        expect(route.formatFare(0), 'KES 0');
      });
    });

    group('formattedDuration', () {
      test('returns formatted duration string', () {
        expect(route.formattedDuration, '~25 min');
      });
    });

    group('formattedBaseFare', () {
      test('returns formatted base fare string', () {
        expect(route.formattedBaseFare, 'KES 30');
      });
    });

    group('routeSummary', () {
      test('returns route summary string', () {
        expect(route.routeSummary, 'CBD → Westlands');
      });
    });

    group('copyWith', () {
      test('creates copy with updated values', () {
        final updatedRoute = route.copyWith(
          name: 'Route 102',
          baseFare: 40.0,
          isFavorite: true,
        );

        expect(updatedRoute.name, 'Route 102');
        expect(updatedRoute.baseFare, 40.0);
        expect(updatedRoute.isFavorite, true);
        // Original values should remain
        expect(updatedRoute.id, 1);
        expect(updatedRoute.startPoint, 'CBD');
      });

      test('creates exact copy when no values provided', () {
        final copy = route.copyWith();

        expect(copy.id, route.id);
        expect(copy.name, route.name);
        expect(copy.baseFare, route.baseFare);
        expect(copy.isFavorite, route.isFavorite);
      });
    });

    group('fare calculation edge cases', () {
      test('works with different fare structures', () {
        final expensiveRoute = route.copyWith(
          baseFare: 50.0,
          farePerStop: 10.0,
        );

        // 3 stops: 50 + (10 * 2) = 70
        expect(expensiveRoute.calculateFare(0, 3), 70.0);
      });

      test('works with zero fare per stop', () {
        final flatFareRoute = route.copyWith(
          baseFare: 100.0,
          farePerStop: 0.0,
        );

        // All trips cost base fare
        expect(flatFareRoute.calculateFare(0, 1), 100.0);
        expect(flatFareRoute.calculateFare(0, 9), 100.0);
      });
    });
  });
}
