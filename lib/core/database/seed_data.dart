import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import 'app_database.dart';

class DatabaseSeeder {
  final AppDatabase _database;

  DatabaseSeeder(this._database);

  Future<bool> isSeeded() async {
    final users = await _database.select(_database.users).get();
    return users.isNotEmpty;
  }

  Future<void> seedAll() async {
    if (await isSeeded()) return;

    // Create test user
    final userId = await _createTestUser();

    // Create wallet
    await _createWallet(userId);

    // Create sample trips
    await _createTrips(userId);

    // Create sample payments
    await _createPayments(userId);

    // Create bus routes
    await _createBusRoutes();
  }

  Future<void> seedRoutes() async {
    if (await _database.hasRoutes()) return;
    await _createBusRoutes();
  }

  Future<int> _createTestUser() async {
    const password = 'Password123';
    final hash = sha256.convert(utf8.encode(password)).toString();

    return await _database.createUser(
      UsersCompanion.insert(
        email: 'eric@komiut.com',
        fullName: 'Eric Mwangi',
        passwordHash: hash,
      ),
    );
  }

  Future<void> _createWallet(int userId) async {
    await _database.createWallet(
      WalletsCompanion.insert(
        userId: userId,
        balance: const Value(2450.50),
        points: const Value(1250),
        currency: const Value('KES'),
      ),
    );
  }

  Future<void> _createTrips(int userId) async {
    final trips = [
      (
        'Nairobi CBD - Westlands',
        'Nairobi CBD',
        'Westlands',
        120.0,
        'completed',
        DateTime.now().subtract(const Duration(hours: 2))
      ),
      (
        'Westlands - Karen',
        'Westlands',
        'Karen',
        350.0,
        'completed',
        DateTime.now().subtract(const Duration(days: 1))
      ),
      (
        'Karen - Nairobi CBD',
        'Karen',
        'Nairobi CBD',
        280.0,
        'completed',
        DateTime.now().subtract(const Duration(days: 2))
      ),
      (
        'Nairobi CBD - Kilimani',
        'Nairobi CBD',
        'Kilimani',
        150.0,
        'failed',
        DateTime.now().subtract(const Duration(days: 3))
      ),
      (
        'Kilimani - Westlands',
        'Kilimani',
        'Westlands',
        200.0,
        'completed',
        DateTime.now().subtract(const Duration(days: 5))
      ),
    ];

    for (final trip in trips) {
      await _database.createTrip(
        TripsCompanion.insert(
          userId: userId,
          routeName: trip.$1,
          fromLocation: trip.$2,
          toLocation: trip.$3,
          fare: trip.$4,
          status: trip.$5,
          tripDate: trip.$6,
        ),
      );
    }
  }

  Future<void> _createPayments(int userId) async {
    final payments = [
      (
        500.0,
        'top-up',
        'completed',
        'Top-up via M-Pesa',
        'TXN-001',
        DateTime.now().subtract(const Duration(hours: 3))
      ),
      (
        120.0,
        'trip',
        'completed',
        'Nairobi CBD - Westlands',
        'TXN-002',
        DateTime.now().subtract(const Duration(hours: 2))
      ),
      (
        350.0,
        'trip',
        'completed',
        'Westlands - Karen',
        'TXN-003',
        DateTime.now().subtract(const Duration(days: 1))
      ),
      (
        1000.0,
        'top-up',
        'completed',
        'Top-up via Card',
        'TXN-004',
        DateTime.now().subtract(const Duration(days: 2))
      ),
      (
        280.0,
        'trip',
        'completed',
        'Karen - Nairobi CBD',
        'TXN-005',
        DateTime.now().subtract(const Duration(days: 2))
      ),
    ];

    for (final payment in payments) {
      await _database.createPayment(
        PaymentsCompanion.insert(
          userId: userId,
          amount: payment.$1,
          type: payment.$2,
          status: payment.$3,
          description: Value(payment.$4),
          referenceId: payment.$5,
          transactionDate: payment.$6,
        ),
      );
    }
  }

  Future<void> _createBusRoutes() async {
    final routes = [
      (
        'Route 101',
        'CBD',
        'Westlands',
        15,
        25,
        30.0,
        5.0,
        '["CBD Terminal","Kencom","University Way","Kenyatta Avenue","Uhuru Highway","Museum Hill","Parklands Road","Chiromo","Waiyaki Way","ABC Place","Sarit Centre","Westlands Roundabout","Mpaka Road","Woodvale Grove","Westlands Terminal"]'
      ),
      (
        'Route 102',
        'CBD',
        'Eastleigh',
        12,
        20,
        25.0,
        5.0,
        '["CBD Terminal","Moi Avenue","Tom Mboya Street","Ronald Ngala Street","Pumwani Road","Juja Road","Eastleigh 1st Avenue","Eastleigh 2nd Avenue","General Waruinge","Eastleigh Section II","Eastleigh Section III","Eastleigh Terminal"]'
      ),
      (
        'Route 103',
        'Westlands',
        'Karen',
        18,
        35,
        40.0,
        5.0,
        '["Westlands Terminal","Waiyaki Way","Kangemi","Mountain View","Uthiru","Kinoo","Kikuyu Road","Dagoretti Corner","Riruta","Kawangware","Ngong Road","Junction Mall","Prestige Plaza","Yaya Centre","Adams Arcade","Langata Road","Karen Shopping Centre","Karen Terminal"]'
      ),
      (
        'Route 104',
        'CBD',
        'Thika Road',
        22,
        40,
        50.0,
        5.0,
        '["CBD Terminal","Moi Avenue","Globe Roundabout","Pangani","Muthaiga Roundabout","Roasters","Kasarani","Safari Park","Roysambu","TRM","Garden City","Mirema","Kahawa West","Kahawa Sukari","Githurai 44","Githurai 45","Kimbo","Ruiru","Juja","Kenyatta University","Thika Town","Thika Terminal"]'
      ),
      (
        'Route 105',
        'Ngong',
        'CBD',
        14,
        30,
        35.0,
        5.0,
        '["Ngong Town","Ngong Road","Oloolua","Corner Baridi","Karen","Langata Road","T-Mall","Carnivore","Uhuru Gardens","Nyayo Stadium","Kenyatta Hospital","Community","Railways","CBD Terminal"]'
      ),
      (
        'Route 106',
        'CBD',
        'Rongai',
        16,
        45,
        45.0,
        5.0,
        '["CBD Terminal","Railways","Nyayo Stadium","Langata Road","T-Mall","Bomas","Galleria","Rimpa","Tuala","Kiserian","Corner Baridi","Ongata Rongai","Kware","Maasai Lodge","Nkoroi","Rongai Terminal"]'
      ),
    ];

    for (final route in routes) {
      await _database.createRoute(
        BusRoutesCompanion.insert(
          name: route.$1,
          startPoint: route.$2,
          endPoint: route.$3,
          stopsCount: route.$4,
          durationMinutes: route.$5,
          baseFare: route.$6,
          farePerStop: Value(route.$7),
          stops: route.$8,
        ),
      );
    }
  }
}
