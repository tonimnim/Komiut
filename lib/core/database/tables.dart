import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get fullName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get profileImage => text().nullable()();
  TextColumn get passwordHash => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  IntColumn get points => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('KES'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Trips extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get routeName => text()();
  TextColumn get fromLocation => text()();
  TextColumn get toLocation => text()();
  RealColumn get fare => real()();
  TextColumn get status => text()(); // 'completed', 'failed'
  DateTimeColumn get tripDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'top-up', 'trip', 'refund'
  TextColumn get status => text()(); // 'completed', 'failed', 'pending'
  TextColumn get description => text().nullable()();
  TextColumn get referenceId => text().unique()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AuthTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade).unique()();
  TextColumn get accessToken => text()();
  TextColumn get refreshToken => text().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class BusRoutes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get startPoint => text()();
  TextColumn get endPoint => text()();
  IntColumn get stopsCount => integer()();
  IntColumn get durationMinutes => integer()();
  RealColumn get baseFare => real()();
  RealColumn get farePerStop => real().withDefault(const Constant(5.0))();
  TextColumn get currency => text().withDefault(const Constant('KES'))();
  TextColumn get stops => text()(); // JSON array of stop names
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class FavoriteRoutes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get routeId =>
      integer().references(BusRoutes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, routeId}
      ];
}
