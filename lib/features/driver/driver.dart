/// Driver feature barrel file.
///
/// Exports all driver-related features for the Komiut app.
/// This module contains driver-specific functionality including:
/// - Dashboard (home screen, profile, stats)
/// - Earnings (income tracking, payouts, transactions)
/// - Queue (stage queue management)
/// - Trips (active and historical trips)
library;

// Dashboard entities
export 'dashboard/domain/entities/driver_profile.dart';
export 'dashboard/domain/entities/driver_stats.dart';
export 'dashboard/domain/entities/entities.dart';

// Earnings entities
export 'earnings/domain/entities/earnings_summary.dart';
export 'earnings/domain/entities/earnings_transaction.dart';
export 'earnings/domain/entities/entities.dart';

// Queue entities
export 'queue/domain/entities/queue_position.dart';
export 'queue/domain/entities/entities.dart';

// Trips entities
export 'trips/domain/entities/driver_trip.dart';
export 'trips/domain/entities/entities.dart';
