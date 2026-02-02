/// Driver feature barrel file.
///
/// Exports all driver-related features for the Komiut app.
/// This module contains driver-specific functionality including:
/// - Dashboard (home screen, profile, stats)
/// - Earnings (income tracking, payouts, transactions)
/// - Queue (stage queue management)
/// - Trips (active and historical trips)
library;

// Dashboard
export 'dashboard/domain/entities/entities.dart';
export 'dashboard/data/models/models.dart';
export 'dashboard/data/datasources/datasources.dart';
export 'dashboard/data/repositories/repositories.dart';

// Earnings
export 'earnings/domain/entities/entities.dart';
export 'earnings/data/models/models.dart';
export 'earnings/data/datasources/datasources.dart';
export 'earnings/data/repositories/repositories.dart';

// Queue
export 'queue/domain/entities/entities.dart';
export 'queue/data/models/models.dart';
export 'queue/data/datasources/datasources.dart';
export 'queue/data/repositories/repositories.dart';

// Trips
export 'trips/domain/entities/entities.dart';
export 'trips/data/models/models.dart';
export 'trips/data/datasources/datasources.dart';
export 'trips/data/repositories/repositories.dart';
