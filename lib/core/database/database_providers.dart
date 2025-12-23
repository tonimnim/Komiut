import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'seed_data.dart';

AppDatabase? _databaseInstance;

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  // Return singleton instance
  _databaseInstance ??= AppDatabase();

  // Seed database on first access
  _seedDatabaseOnce();

  ref.onDispose(() {
    _databaseInstance?.close();
    _databaseInstance = null;
  });

  return _databaseInstance!;
});

bool _isSeeded = false;

Future<void> _seedDatabaseOnce() async {
  if (_isSeeded || _databaseInstance == null) return;
  _isSeeded = true;

  final seeder = DatabaseSeeder(_databaseInstance!);
  await seeder.seedAll();
}
