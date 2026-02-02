import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Wallets,
  Trips,
  Payments,
  AuthTokens,
  BusRoutes,
  FavoriteRoutes
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(wallets, wallets.points);
        }
        if (from < 3) {
          await m.createTable(busRoutes);
          await m.createTable(favoriteRoutes);
        }
        if (from < 4) {
          await m.addColumn(users, users.phone);
        }
        if (from < 5) {
          await m.addColumn(users, users.profileImage);
        }
      },
    );
  }

  // USER OPERATIONS

  Future<User?> getUserByEmail(String email) async {
    return (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  Future<User?> getUserById(int id) async {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<int> createUser(UsersCompanion user) async {
    return into(users).insert(user);
  }

  Future<bool> updateUser(User user) async {
    return update(users).replace(user);
  }

  Future<bool> updateUserProfile(int userId,
      {String? fullName, String? phone, String? profileImage}) async {
    final result =
        await (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        fullName: fullName != null ? Value(fullName) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        profileImage:
            profileImage != null ? Value(profileImage) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return result > 0;
  }

  // WALLET OPERATIONS

  Future<Wallet?> getWalletByUserId(int userId) async {
    return (select(wallets)..where((w) => w.userId.equals(userId)))
        .getSingleOrNull();
  }

  Stream<Wallet?> watchWalletByUserId(int userId) {
    return (select(wallets)..where((w) => w.userId.equals(userId)))
        .watchSingleOrNull();
  }

  Future<int> createWallet(WalletsCompanion wallet) async {
    return into(wallets).insert(wallet);
  }

  Future<bool> updateWalletBalance(int walletId, double newBalance) async {
    final result =
        await (update(wallets)..where((w) => w.id.equals(walletId))).write(
      WalletsCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return result > 0;
  }

  // TRIP OPERATIONS

  Future<List<Trip>> getTripsByUserId(int userId) async {
    return (select(trips)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.tripDate)]))
        .get();
  }

  Stream<List<Trip>> watchTripsByUserId(int userId) {
    return (select(trips)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.tripDate)]))
        .watch();
  }

  Future<List<Trip>> getRecentTrips(int userId, {int limit = 10}) async {
    return (select(trips)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.tripDate)])
          ..limit(limit))
        .get();
  }

  Future<int> createTrip(TripsCompanion trip) async {
    return into(trips).insert(trip);
  }

  // PAYMENT OPERATIONS

  Future<List<Payment>> getPaymentsByUserId(int userId) async {
    return (select(payments)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm.desc(p.transactionDate)]))
        .get();
  }

  Stream<List<Payment>> watchPaymentsByUserId(int userId) {
    return (select(payments)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm.desc(p.transactionDate)]))
        .watch();
  }

  Future<List<Payment>> getRecentPayments(int userId, {int limit = 10}) async {
    return (select(payments)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm.desc(p.transactionDate)])
          ..limit(limit))
        .get();
  }

  Future<int> createPayment(PaymentsCompanion payment) async {
    return into(payments).insert(payment);
  }

  // AUTH TOKEN OPERATIONS

  Future<AuthToken?> getAuthTokenByUserId(int userId) async {
    return (select(authTokens)..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> saveAuthToken(AuthTokensCompanion token) async {
    await into(authTokens).insertOnConflictUpdate(token);
  }

  Future<int> deleteAuthTokenByUserId(int userId) async {
    return (delete(authTokens)..where((t) => t.userId.equals(userId))).go();
  }

  Future<bool> isTokenValid(int userId) async {
    final token = await getAuthTokenByUserId(userId);
    if (token == null) return false;
    return token.expiresAt.isAfter(DateTime.now());
  }

  // BUS ROUTE OPERATIONS

  Future<List<BusRoute>> getAllRoutes() async {
    return (select(busRoutes)..where((r) => r.isActive.equals(true))).get();
  }

  Future<BusRoute?> getRouteById(int id) async {
    return (select(busRoutes)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Future<int> createRoute(BusRoutesCompanion route) async {
    return into(busRoutes).insert(route);
  }

  Future<bool> hasRoutes() async {
    final count = await (selectOnly(busRoutes)
          ..addColumns([busRoutes.id.count()]))
        .getSingle();
    return (count.read(busRoutes.id.count()) ?? 0) > 0;
  }

  // FAVORITE ROUTE OPERATIONS

  Future<List<BusRoute>> getFavoriteRoutes(int userId) async {
    final query = select(busRoutes).join([
      innerJoin(favoriteRoutes, favoriteRoutes.routeId.equalsExp(busRoutes.id)),
    ])
      ..where(favoriteRoutes.userId.equals(userId));

    final results = await query.get();
    return results.map((row) => row.readTable(busRoutes)).toList();
  }

  Future<bool> isRouteFavorite(int userId, int routeId) async {
    final result = await (select(favoriteRoutes)
          ..where((f) => f.userId.equals(userId) & f.routeId.equals(routeId)))
        .getSingleOrNull();
    return result != null;
  }

  Future<int> addFavoriteRoute(int userId, int routeId) async {
    return into(favoriteRoutes).insert(
      FavoriteRoutesCompanion(
        userId: Value(userId),
        routeId: Value(routeId),
      ),
    );
  }

  Future<int> removeFavoriteRoute(int userId, int routeId) async {
    return (delete(favoriteRoutes)
          ..where((f) => f.userId.equals(userId) & f.routeId.equals(routeId)))
        .go();
  }

  Stream<bool> watchRouteFavorite(int userId, int routeId) {
    return (select(favoriteRoutes)
          ..where((f) => f.userId.equals(userId) & f.routeId.equals(routeId)))
        .watchSingleOrNull()
        .map((result) => result != null);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase(file);
  });
}
