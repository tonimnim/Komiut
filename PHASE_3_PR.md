# Phase 3: Data Layer Implementation

## PR Description

### Summary

Phase 3 of the 6-phase refactoring plan. This phase implements the **Data Layer** for driver features, connecting Musa's UI screens to the actual backend API (`https://v2.komiut.com`).

### Why This Refactoring?

We are unifying Musa's driver UI work with the existing passenger feature patterns to create **one consistent, professional codebase** that:
- Uses **Riverpod** for state management (not BLoC)
- Follows **Clean Architecture** (domain → data → presentation)
- Connects to the **real backend API** (not hardcoded data)
- Uses **Either<Failure, T>** for error handling
- Has **consistent code patterns** across all features

### What This PR Does

Creates the complete data layer for driver features:
- **Models** - DTOs with `fromJson()`, `toJson()`, `toEntity()` methods
- **Datasources** - API calls returning `Either<Failure, T>`
- **Repositories** - Clean abstraction over datasources

### API Endpoints Used

| Feature | Endpoint | Method |
|---------|----------|--------|
| Driver Profile | `/api/Personnel` | GET |
| Driver Stats | `/api/DailyVehicleTotals` | GET |
| Earnings | `/api/Payments` | GET |
| Trips | `/api/Trips` | GET/POST/PUT |
| Queue | `/api/Vehicles` + SignalR | GET |

### Files Created

```
lib/features/driver/
├── dashboard/data/
│   ├── models/
│   │   ├── driver_profile_model.dart
│   │   └── driver_stats_model.dart
│   ├── datasources/
│   │   └── dashboard_remote_datasource.dart
│   └── repositories/
│       └── dashboard_repository.dart
├── earnings/data/
│   ├── models/
│   │   ├── earnings_summary_model.dart
│   │   └── earnings_transaction_model.dart
│   ├── datasources/
│   │   └── earnings_remote_datasource.dart
│   └── repositories/
│       └── earnings_repository.dart
├── queue/data/
│   ├── models/
│   │   └── queue_position_model.dart
│   ├── datasources/
│   │   └── queue_remote_datasource.dart
│   └── repositories/
│       └── queue_repository.dart
└── trips/data/
    ├── models/
    │   └── driver_trip_model.dart
    ├── datasources/
    │   └── trips_remote_datasource.dart
    └── repositories/
        └── trips_repository.dart
```

### Test Plan

- [x] All models have `fromJson()`, `toJson()`, `toEntity()` methods
- [x] All datasources return `Either<Failure, T>`
- [x] All repositories have Riverpod providers
- [x] `flutter analyze` passes (0 errors)
- [ ] API integration tests pass

---

# Agent Instructions

## Overview

Phase 3 is divided into 5 agents. Each agent works on a specific feature's data layer.

```
Agent 1: Dashboard (DriverProfile, DriverStats)
Agent 2: Earnings (EarningsSummary, EarningsTransaction)
Agent 3: Queue (QueuePosition)
Agent 4: Trips (DriverTrip)
Agent 5: API Endpoints + Verification
```

---

## AGENT 1: Dashboard Data Layer

### Task: Create models, datasource, and repository for driver dashboard

### Reference Pattern

Follow the passenger discovery pattern from:
- `lib/features/passenger/discovery/data/models/sacco_model.dart`
- `lib/features/passenger/discovery/data/datasources/sacco_remote_datasource.dart`
- `lib/features/passenger/discovery/data/repositories/sacco_repository.dart`

### Step 1: Create DriverProfileModel

Create `lib/features/driver/dashboard/data/models/driver_profile_model.dart`:

```dart
import '../../domain/entities/driver_profile.dart';

/// Data model for driver profile from API.
///
/// Maps to PersonnelDto from the backend API:
/// GET /api/Personnel
class DriverProfileModel {
  DriverProfileModel({
    required this.id,
    required this.organizationId,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.status,
    this.createdAt,
    this.vehicleId,
    this.photoUrl,
    this.rating,
    this.totalTrips,
  });

  final String id;
  final String organizationId;
  final String name;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? role;
  final int? status;
  final DateTime? createdAt;
  final String? vehicleId;
  final String? photoUrl;
  final double? rating;
  final int? totalTrips;

  /// Creates model from API JSON response.
  ///
  /// Handles PersonnelDto structure:
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "organizationId": "uuid",
  ///   "name": "string",
  ///   "email": "string",
  ///   "phone": "string",
  ///   "role": { "roleId": "uuid", "isActive": true },
  ///   "status": 0,
  ///   "createdAt": "2026-02-02T01:14:04.645Z"
  /// }
  /// ```
  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as Map<String, dynamic>?,
      status: json['status'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      vehicleId: json['vehicleId']?.toString(),
      photoUrl: json['photoUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalTrips: json['totalTrips'] as int?,
    );
  }

  /// Converts model to JSON for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'organizationId': organizationId,
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (vehicleId != null) 'vehicleId': vehicleId,
      };

  /// Converts to domain entity for use in presentation layer.
  DriverProfile toEntity() => DriverProfile(
        id: id,
        fullName: name,
        email: email ?? '',
        phoneNumber: phone,
        photoUrl: photoUrl,
        vehicleId: vehicleId,
        saccoId: organizationId,
        licenseNumber: null,
        isVerified: status == 1,
        isOnline: role?['isActive'] as bool? ?? false,
        rating: rating,
        totalTrips: totalTrips,
      );

  /// Creates model from domain entity.
  factory DriverProfileModel.fromEntity(DriverProfile entity) {
    return DriverProfileModel(
      id: entity.id,
      organizationId: entity.saccoId ?? '',
      name: entity.fullName,
      email: entity.email,
      phone: entity.phoneNumber,
      vehicleId: entity.vehicleId,
      photoUrl: entity.photoUrl,
      rating: entity.rating,
      totalTrips: entity.totalTrips,
    );
  }
}
```

### Step 2: Create DriverStatsModel

Create `lib/features/driver/dashboard/data/models/driver_stats_model.dart`:

```dart
import '../../domain/entities/driver_stats.dart';

/// Data model for driver statistics from API.
///
/// Aggregates data from multiple endpoints:
/// - GET /api/DailyVehicleTotals (earnings)
/// - GET /api/Trips (trip counts)
class DriverStatsModel {
  DriverStatsModel({
    required this.totalTrips,
    required this.totalEarnings,
    required this.totalPassengers,
    this.todayTrips = 0,
    this.todayEarnings = 0.0,
    this.weeklyTrips = 0,
    this.weeklyEarnings = 0.0,
    this.averageRating,
    this.completionRate,
    this.currency = 'KES',
  });

  final int totalTrips;
  final double totalEarnings;
  final int totalPassengers;
  final int todayTrips;
  final double todayEarnings;
  final int weeklyTrips;
  final double weeklyEarnings;
  final double? averageRating;
  final double? completionRate;
  final String currency;

  /// Creates model from aggregated API data.
  ///
  /// Combines DailyVehicleTotalDto[] and TripDto[] data.
  factory DriverStatsModel.fromJson(Map<String, dynamic> json) {
    return DriverStatsModel(
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalPassengers: json['totalPassengers'] as int? ?? 0,
      todayTrips: json['todayTrips'] as int? ?? 0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyTrips: json['weeklyTrips'] as int? ?? 0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      completionRate: (json['completionRate'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  /// Creates from DailyVehicleTotalDto list.
  factory DriverStatsModel.fromDailyTotals(List<dynamic> dailyTotals) {
    double totalEarnings = 0.0;
    double todayEarnings = 0.0;
    double weeklyEarnings = 0.0;
    String currency = 'KES';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    for (final total in dailyTotals) {
      final amount = (total['totalCollected'] as num?)?.toDouble() ?? 0.0;
      final dateStr = total['date'] as String?;
      currency = total['currency'] as String? ?? 'KES';

      totalEarnings += amount;

      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
            todayEarnings += amount;
          }
          if (date.isAfter(weekAgo)) {
            weeklyEarnings += amount;
          }
        }
      }
    }

    return DriverStatsModel(
      totalTrips: 0,
      totalEarnings: totalEarnings,
      totalPassengers: 0,
      todayEarnings: todayEarnings,
      weeklyEarnings: weeklyEarnings,
      currency: currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalTrips': totalTrips,
        'totalEarnings': totalEarnings,
        'totalPassengers': totalPassengers,
        'todayTrips': todayTrips,
        'todayEarnings': todayEarnings,
        'weeklyTrips': weeklyTrips,
        'weeklyEarnings': weeklyEarnings,
        if (averageRating != null) 'averageRating': averageRating,
        if (completionRate != null) 'completionRate': completionRate,
        'currency': currency,
      };

  DriverStats toEntity() => DriverStats(
        totalTrips: totalTrips,
        totalEarnings: totalEarnings,
        totalPassengers: totalPassengers,
        todayTrips: todayTrips,
        todayEarnings: todayEarnings,
        weeklyTrips: weeklyTrips,
        weeklyEarnings: weeklyEarnings,
        averageRating: averageRating,
        completionRate: completionRate,
      );
}
```

### Step 3: Create models barrel file

Create `lib/features/driver/dashboard/data/models/models.dart`:

```dart
/// Dashboard data models barrel file.
library;

export 'driver_profile_model.dart';
export 'driver_stats_model.dart';
```

### Step 4: Create DashboardRemoteDataSource

Create `lib/features/driver/dashboard/data/datasources/dashboard_remote_datasource.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/entities/driver_stats.dart';
import '../models/driver_profile_model.dart';
import '../models/driver_stats_model.dart';

/// Provider for dashboard remote data source.
final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for dashboard data operations.
abstract class DashboardRemoteDataSource {
  /// Fetches the current driver's profile.
  Future<Either<Failure, DriverProfile>> getDriverProfile(String personnelId);

  /// Fetches driver statistics.
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId);

  /// Updates driver online status.
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  });
}

/// Implementation of dashboard remote data source.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, DriverProfile>> getDriverProfile(String personnelId) async {
    return apiClient.get<DriverProfile>(
      ApiEndpoints.personnel,
      queryParameters: {'Id': personnelId},
      fromJson: (data) {
        if (data is List && data.isNotEmpty) {
          return DriverProfileModel.fromJson(
            data.first as Map<String, dynamic>,
          ).toEntity();
        }
        if (data is Map<String, dynamic>) {
          return DriverProfileModel.fromJson(data).toEntity();
        }
        throw Exception('Invalid response format');
      },
    );
  }

  @override
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId) async {
    return apiClient.get<DriverStats>(
      ApiEndpoints.dailyVehicleTotals,
      queryParameters: {'VehicleId': vehicleId},
      fromJson: (data) {
        if (data is List) {
          return DriverStatsModel.fromDailyTotals(data).toEntity();
        }
        return DriverStatsModel.fromJson(
          data as Map<String, dynamic>,
        ).toEntity();
      },
    );
  }

  @override
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  }) async {
    return apiClient.put<void>(
      ApiEndpoints.personnel,
      data: {
        'id': personnelId,
        'role': {'isActive': isOnline},
      },
    );
  }
}
```

### Step 5: Create datasources barrel file

Create `lib/features/driver/dashboard/data/datasources/datasources.dart`:

```dart
/// Dashboard datasources barrel file.
library;

export 'dashboard_remote_datasource.dart';
```

### Step 6: Create DashboardRepository

Create `lib/features/driver/dashboard/data/repositories/dashboard_repository.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/entities/driver_stats.dart';
import '../datasources/dashboard_remote_datasource.dart';

/// Provider for dashboard repository.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for dashboard repository.
abstract class DashboardRepository {
  /// Gets the driver's profile.
  Future<Either<Failure, DriverProfile>> getDriverProfile(String personnelId);

  /// Gets the driver's statistics.
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId);

  /// Updates driver online status.
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  });
}

/// Implementation of dashboard repository.
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required this.remoteDataSource});

  final DashboardRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, DriverProfile>> getDriverProfile(String personnelId) {
    return remoteDataSource.getDriverProfile(personnelId);
  }

  @override
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId) {
    return remoteDataSource.getDriverStats(vehicleId);
  }

  @override
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  }) {
    return remoteDataSource.updateOnlineStatus(
      personnelId: personnelId,
      isOnline: isOnline,
    );
  }
}
```

### Step 7: Create repositories barrel file

Create `lib/features/driver/dashboard/data/repositories/repositories.dart`:

```dart
/// Dashboard repositories barrel file.
library;

export 'dashboard_repository.dart';
```

### Verification

Run:
```bash
flutter analyze lib/features/driver/dashboard/data/
```

Should have 0 errors.

---

## AGENT 2: Earnings Data Layer

### Task: Create models, datasource, and repository for driver earnings

### Step 1: Create EarningsSummaryModel

Create `lib/features/driver/earnings/data/models/earnings_summary_model.dart`:

```dart
import '../../domain/entities/earnings_summary.dart';

/// Data model for earnings summary.
///
/// Aggregates data from:
/// - GET /api/DailyVehicleTotals
/// - GET /api/Payments
class EarningsSummaryModel {
  EarningsSummaryModel({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.allTime,
    this.pendingPayout = 0.0,
    this.lastPayoutAmount,
    this.lastPayoutDate,
    this.currency = 'KES',
  });

  final double today;
  final double thisWeek;
  final double thisMonth;
  final double allTime;
  final double pendingPayout;
  final double? lastPayoutAmount;
  final DateTime? lastPayoutDate;
  final String currency;

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsSummaryModel(
      today: (json['today'] as num?)?.toDouble() ?? 0.0,
      thisWeek: (json['thisWeek'] as num?)?.toDouble() ?? 0.0,
      thisMonth: (json['thisMonth'] as num?)?.toDouble() ?? 0.0,
      allTime: (json['allTime'] as num?)?.toDouble() ?? 0.0,
      pendingPayout: (json['pendingPayout'] as num?)?.toDouble() ?? 0.0,
      lastPayoutAmount: (json['lastPayoutAmount'] as num?)?.toDouble(),
      lastPayoutDate: json['lastPayoutDate'] != null
          ? DateTime.tryParse(json['lastPayoutDate'] as String)
          : null,
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  /// Creates from DailyVehicleTotalDto list.
  factory EarningsSummaryModel.fromDailyTotals(List<dynamic> dailyTotals) {
    double today = 0.0;
    double thisWeek = 0.0;
    double thisMonth = 0.0;
    double allTime = 0.0;
    String currency = 'KES';

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = todayStart.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    for (final total in dailyTotals) {
      final amount = (total['totalCollected'] as num?)?.toDouble() ?? 0.0;
      final dateStr = total['date'] as String?;
      currency = total['currency'] as String? ?? 'KES';

      allTime += amount;

      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          if (date.year == todayStart.year &&
              date.month == todayStart.month &&
              date.day == todayStart.day) {
            today += amount;
          }
          if (date.isAfter(weekAgo)) {
            thisWeek += amount;
          }
          if (date.isAfter(monthAgo)) {
            thisMonth += amount;
          }
        }
      }
    }

    return EarningsSummaryModel(
      today: today,
      thisWeek: thisWeek,
      thisMonth: thisMonth,
      allTime: allTime,
      currency: currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'today': today,
        'thisWeek': thisWeek,
        'thisMonth': thisMonth,
        'allTime': allTime,
        'pendingPayout': pendingPayout,
        if (lastPayoutAmount != null) 'lastPayoutAmount': lastPayoutAmount,
        if (lastPayoutDate != null)
          'lastPayoutDate': lastPayoutDate!.toIso8601String(),
        'currency': currency,
      };

  EarningsSummary toEntity() => EarningsSummary(
        today: today,
        thisWeek: thisWeek,
        thisMonth: thisMonth,
        allTime: allTime,
        pendingPayout: pendingPayout,
        lastPayoutAmount: lastPayoutAmount,
        lastPayoutDate: lastPayoutDate,
        currency: currency,
      );
}
```

### Step 2: Create EarningsTransactionModel

Create `lib/features/driver/earnings/data/models/earnings_transaction_model.dart`:

```dart
import '../../domain/entities/earnings_transaction.dart';

/// Data model for earnings transaction.
///
/// Maps to PaymentDto from the backend API:
/// GET /api/Payments
class EarningsTransactionModel {
  EarningsTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.tripId,
    this.bookingId,
    this.description,
    this.referenceId,
    this.status,
    this.currency = 'KES',
  });

  final String id;
  final double amount;
  final String type;
  final DateTime timestamp;
  final String? tripId;
  final String? bookingId;
  final String? description;
  final String? referenceId;
  final String? status;
  final String currency;

  /// Creates from PaymentDto JSON.
  ///
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "amount": 100.0,
  ///   "currency": "KES",
  ///   "status": "completed",
  ///   "bookingId": "uuid",
  ///   "referenceId": "string",
  ///   "transactionTime": "2026-02-02T01:14:04.639Z"
  /// }
  /// ```
  factory EarningsTransactionModel.fromJson(Map<String, dynamic> json) {
    return EarningsTransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: _inferType(json),
      timestamp: json['transactionTime'] != null
          ? DateTime.parse(json['transactionTime'] as String)
          : DateTime.now(),
      tripId: json['tripId']?.toString(),
      bookingId: json['bookingId']?.toString(),
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
      status: json['status'] as String?,
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  static String _inferType(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    if (status == 'payout') return 'payout';
    if (status == 'refund') return 'refund';
    if (json['bookingId'] != null) return 'trip';
    return 'trip';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'transactionTime': timestamp.toIso8601String(),
        if (tripId != null) 'tripId': tripId,
        if (bookingId != null) 'bookingId': bookingId,
        if (description != null) 'description': description,
        if (referenceId != null) 'referenceId': referenceId,
        if (status != null) 'status': status,
        'currency': currency,
      };

  EarningsTransaction toEntity() => EarningsTransaction(
        id: id,
        amount: amount,
        type: _mapType(type),
        timestamp: timestamp,
        tripId: tripId ?? bookingId,
        description: description ?? referenceId,
        currency: currency,
      );

  EarningsType _mapType(String type) {
    switch (type.toLowerCase()) {
      case 'bonus':
        return EarningsType.bonus;
      case 'tip':
        return EarningsType.tip;
      case 'deduction':
        return EarningsType.deduction;
      case 'payout':
        return EarningsType.payout;
      case 'refund':
        return EarningsType.refund;
      default:
        return EarningsType.trip;
    }
  }
}
```

### Step 3: Create models barrel file

Create `lib/features/driver/earnings/data/models/models.dart`:

```dart
/// Earnings data models barrel file.
library;

export 'earnings_summary_model.dart';
export 'earnings_transaction_model.dart';
```

### Step 4: Create EarningsRemoteDataSource

Create `lib/features/driver/earnings/data/datasources/earnings_remote_datasource.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/earnings_transaction.dart';
import '../models/earnings_summary_model.dart';
import '../models/earnings_transaction_model.dart';

/// Provider for earnings remote data source.
final earningsRemoteDataSourceProvider = Provider<EarningsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EarningsRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for earnings data operations.
abstract class EarningsRemoteDataSource {
  /// Fetches earnings summary for a vehicle.
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(String vehicleId);

  /// Fetches earnings transaction history.
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int? pageNumber,
    int? pageSize,
  });
}

/// Implementation of earnings remote data source.
class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  EarningsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(String vehicleId) async {
    return apiClient.get<EarningsSummary>(
      ApiEndpoints.dailyVehicleTotals,
      queryParameters: {'VehicleId': vehicleId},
      fromJson: (data) {
        if (data is List) {
          return EarningsSummaryModel.fromDailyTotals(data).toEntity();
        }
        return EarningsSummaryModel.fromJson(
          data as Map<String, dynamic>,
        ).toEntity();
      },
    );
  }

  @override
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int? pageNumber,
    int? pageSize,
  }) async {
    return apiClient.get<List<EarningsTransaction>>(
      ApiEndpoints.payments,
      queryParameters: {
        'VehicleId': vehicleId,
        if (pageNumber != null) 'PageNumber': pageNumber.toString(),
        if (pageSize != null) 'PageSize': pageSize.toString(),
      },
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) => EarningsTransactionModel.fromJson(
                    json as Map<String, dynamic>,
                  ).toEntity())
              .toList();
        }
        return <EarningsTransaction>[];
      },
    );
  }
}
```

### Step 5: Create datasources barrel file

Create `lib/features/driver/earnings/data/datasources/datasources.dart`:

```dart
/// Earnings datasources barrel file.
library;

export 'earnings_remote_datasource.dart';
```

### Step 6: Create EarningsRepository

Create `lib/features/driver/earnings/data/repositories/earnings_repository.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/earnings_transaction.dart';
import '../datasources/earnings_remote_datasource.dart';

/// Provider for earnings repository.
final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  final remoteDataSource = ref.watch(earningsRemoteDataSourceProvider);
  return EarningsRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for earnings repository.
abstract class EarningsRepository {
  /// Gets earnings summary.
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(String vehicleId);

  /// Gets earnings transaction history.
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int? pageNumber,
    int? pageSize,
  });
}

/// Implementation of earnings repository.
class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl({required this.remoteDataSource});

  final EarningsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(String vehicleId) {
    return remoteDataSource.getEarningsSummary(vehicleId);
  }

  @override
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int? pageNumber,
    int? pageSize,
  }) {
    return remoteDataSource.getEarningsHistory(
      vehicleId: vehicleId,
      fromDate: fromDate,
      toDate: toDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
```

### Step 7: Create repositories barrel file

Create `lib/features/driver/earnings/data/repositories/repositories.dart`:

```dart
/// Earnings repositories barrel file.
library;

export 'earnings_repository.dart';
```

### Verification

Run:
```bash
flutter analyze lib/features/driver/earnings/data/
```

---

## AGENT 3: Queue Data Layer

### Task: Create models, datasource, and repository for driver queue

### Step 1: Create QueuePositionModel

Create `lib/features/driver/queue/data/models/queue_position_model.dart`:

```dart
import '../../domain/entities/queue_position.dart';

/// Data model for queue position.
///
/// Note: The backend may not have a dedicated queue endpoint.
/// This model works with vehicle assignment data and SignalR updates.
class QueuePositionModel {
  QueuePositionModel({
    required this.id,
    required this.position,
    required this.routeId,
    required this.routeName,
    required this.joinedAt,
    this.stageId,
    this.stageName,
    this.status = 'waiting',
    this.estimatedWaitMinutes,
    this.vehiclesAhead,
    this.vehicleRegistration,
  });

  final String id;
  final int position;
  final String routeId;
  final String routeName;
  final DateTime joinedAt;
  final String? stageId;
  final String? stageName;
  final String status;
  final int? estimatedWaitMinutes;
  final int? vehiclesAhead;
  final String? vehicleRegistration;

  factory QueuePositionModel.fromJson(Map<String, dynamic> json) {
    return QueuePositionModel(
      id: json['id']?.toString() ?? '',
      position: json['position'] as int? ?? 0,
      routeId: json['routeId']?.toString() ?? '',
      routeName: json['routeName'] as String? ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
      stageId: json['stageId']?.toString(),
      stageName: json['stageName'] as String?,
      status: json['status'] as String? ?? 'waiting',
      estimatedWaitMinutes: json['estimatedWaitMinutes'] as int?,
      vehiclesAhead: json['vehiclesAhead'] as int?,
      vehicleRegistration: json['vehicleRegistration'] as String?,
    );
  }

  /// Creates from vehicle route assignment.
  factory QueuePositionModel.fromVehicleAssignment(
    Map<String, dynamic> vehicle,
    Map<String, dynamic> route,
    int position,
  ) {
    return QueuePositionModel(
      id: '${vehicle['id']}_${route['id']}',
      position: position,
      routeId: route['id']?.toString() ?? '',
      routeName: route['name'] as String? ?? '',
      joinedAt: DateTime.now(),
      vehicleRegistration: (vehicle['registrationNumber']
          as Map<String, dynamic>?)?['value'] as String?,
      vehiclesAhead: position - 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'routeId': routeId,
        'routeName': routeName,
        'joinedAt': joinedAt.toIso8601String(),
        if (stageId != null) 'stageId': stageId,
        if (stageName != null) 'stageName': stageName,
        'status': status,
        if (estimatedWaitMinutes != null)
          'estimatedWaitMinutes': estimatedWaitMinutes,
        if (vehiclesAhead != null) 'vehiclesAhead': vehiclesAhead,
        if (vehicleRegistration != null)
          'vehicleRegistration': vehicleRegistration,
      };

  QueuePosition toEntity() => QueuePosition(
        id: id,
        position: position,
        routeId: routeId,
        routeName: routeName,
        joinedAt: joinedAt,
        stageId: stageId,
        stageName: stageName,
        status: _mapStatus(status),
        estimatedWaitMinutes: estimatedWaitMinutes,
        vehiclesAhead: vehiclesAhead,
        vehicleRegistration: vehicleRegistration,
      );

  QueueStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'boarding':
        return QueueStatus.boarding;
      case 'departed':
        return QueueStatus.departed;
      case 'cancelled':
        return QueueStatus.cancelled;
      default:
        return QueueStatus.waiting;
    }
  }
}
```

### Step 2: Create models barrel file

Create `lib/features/driver/queue/data/models/models.dart`:

```dart
/// Queue data models barrel file.
library;

export 'queue_position_model.dart';
```

### Step 3: Create QueueRemoteDataSource

Create `lib/features/driver/queue/data/datasources/queue_remote_datasource.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/queue_position.dart';
import '../models/queue_position_model.dart';

/// Provider for queue remote data source.
final queueRemoteDataSourceProvider = Provider<QueueRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QueueRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for queue data operations.
abstract class QueueRemoteDataSource {
  /// Gets current queue position for a vehicle.
  Future<Either<Failure, QueuePosition?>> getQueuePosition(String vehicleId);

  /// Joins a queue for a route.
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  });

  /// Leaves the current queue.
  Future<Either<Failure, void>> leaveQueue(String vehicleId);

  /// Gets all vehicles in queue for a route.
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(String routeId);
}

/// Implementation of queue remote data source.
class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  QueueRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, QueuePosition?>> getQueuePosition(String vehicleId) async {
    // Get vehicle with current route
    final vehicleResult = await apiClient.get<Map<String, dynamic>?>(
      ApiEndpoints.vehicles,
      queryParameters: {'VehicleId': vehicleId},
      fromJson: (data) {
        if (data is List && data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
        return null;
      },
    );

    return vehicleResult.fold(
      (failure) => Left(failure),
      (vehicle) async {
        if (vehicle == null || vehicle['currentRouteId'] == null) {
          return const Right(null);
        }

        // Get route info
        final routeResult = await apiClient.get<Map<String, dynamic>?>(
          ApiEndpoints.routes,
          queryParameters: {'RouteId': vehicle['currentRouteId']},
          fromJson: (data) {
            if (data is List && data.isNotEmpty) {
              return data.first as Map<String, dynamic>;
            }
            return null;
          },
        );

        return routeResult.fold(
          (failure) => Left(failure),
          (route) {
            if (route == null) return const Right(null);

            // Create queue position from vehicle/route data
            final model = QueuePositionModel.fromVehicleAssignment(
              vehicle,
              route,
              1, // Position would come from real queue system
            );
            return Right(model.toEntity());
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  }) async {
    // Assign route to vehicle
    final result = await apiClient.post<void>(
      ApiEndpoints.vehicleAssignRoute,
      data: {
        'vehicleId': vehicleId,
        'routeId': routeId,
      },
    );

    return result.fold(
      (failure) => Left(failure),
      (_) async {
        // Fetch the new queue position
        final positionResult = await getQueuePosition(vehicleId);
        return positionResult.fold(
          (failure) => Left(failure),
          (position) {
            if (position == null) {
              return Left(ServerFailure('Failed to get queue position'));
            }
            return Right(position);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> leaveQueue(String vehicleId) async {
    // Remove route assignment
    return apiClient.put<void>(
      ApiEndpoints.vehicles,
      data: {
        'vehicleId': vehicleId,
        'currentRouteId': null,
      },
    );
  }

  @override
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(String routeId) async {
    return apiClient.get<List<QueuePosition>>(
      ApiEndpoints.vehicles,
      queryParameters: {'RouteId': routeId},
      fromJson: (data) {
        if (data is! List) return <QueuePosition>[];

        final positions = <QueuePosition>[];
        for (var i = 0; i < data.length; i++) {
          final vehicle = data[i] as Map<String, dynamic>;
          if (vehicle['currentRouteId']?.toString() == routeId) {
            final model = QueuePositionModel(
              id: vehicle['id']?.toString() ?? '',
              position: i + 1,
              routeId: routeId,
              routeName: '', // Would need to fetch
              joinedAt: DateTime.now(),
              vehicleRegistration: (vehicle['registrationNumber']
                  as Map<String, dynamic>?)?['value'] as String?,
            );
            positions.add(model.toEntity());
          }
        }
        return positions;
      },
    );
  }
}
```

### Step 4: Create datasources barrel file

Create `lib/features/driver/queue/data/datasources/datasources.dart`:

```dart
/// Queue datasources barrel file.
library;

export 'queue_remote_datasource.dart';
```

### Step 5: Create QueueRepository

Create `lib/features/driver/queue/data/repositories/queue_repository.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/queue_position.dart';
import '../datasources/queue_remote_datasource.dart';

/// Provider for queue repository.
final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  final remoteDataSource = ref.watch(queueRemoteDataSourceProvider);
  return QueueRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for queue repository.
abstract class QueueRepository {
  /// Gets current queue position.
  Future<Either<Failure, QueuePosition?>> getQueuePosition(String vehicleId);

  /// Joins a queue.
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  });

  /// Leaves the queue.
  Future<Either<Failure, void>> leaveQueue(String vehicleId);

  /// Gets all positions in a route queue.
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(String routeId);
}

/// Implementation of queue repository.
class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl({required this.remoteDataSource});

  final QueueRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, QueuePosition?>> getQueuePosition(String vehicleId) {
    return remoteDataSource.getQueuePosition(vehicleId);
  }

  @override
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  }) {
    return remoteDataSource.joinQueue(vehicleId: vehicleId, routeId: routeId);
  }

  @override
  Future<Either<Failure, void>> leaveQueue(String vehicleId) {
    return remoteDataSource.leaveQueue(vehicleId);
  }

  @override
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(String routeId) {
    return remoteDataSource.getRouteQueue(routeId);
  }
}
```

### Step 6: Create repositories barrel file

Create `lib/features/driver/queue/data/repositories/repositories.dart`:

```dart
/// Queue repositories barrel file.
library;

export 'queue_repository.dart';
```

---

## AGENT 4: Trips Data Layer

### Task: Create models, datasource, and repository for driver trips

### Step 1: Create DriverTripModel

Create `lib/features/driver/trips/data/models/driver_trip_model.dart`:

```dart
import '../../domain/entities/driver_trip.dart';

/// Data model for driver trip.
///
/// Maps to TripDto from the backend API:
/// GET /api/Trips
class DriverTripModel {
  DriverTripModel({
    required this.id,
    required this.vehicleId,
    required this.routeId,
    required this.routeName,
    required this.status,
    required this.startTime,
    this.vehicleRegistration,
    this.driverId,
    this.driverName,
    this.toutId,
    this.toutName,
    this.endTime,
    this.createdAt,
    this.passengerCount,
    this.maxCapacity,
    this.fare,
  });

  final String id;
  final String vehicleId;
  final String routeId;
  final String routeName;
  final int status;
  final DateTime startTime;
  final String? vehicleRegistration;
  final String? driverId;
  final String? driverName;
  final String? toutId;
  final String? toutName;
  final DateTime? endTime;
  final DateTime? createdAt;
  final int? passengerCount;
  final int? maxCapacity;
  final double? fare;

  /// Creates from TripDto JSON.
  ///
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "vehicleId": "uuid",
  ///   "vehicleRegistrationNumber": { "value": "KAA 123A" },
  ///   "routeId": "uuid",
  ///   "routeName": "CBD - Westlands",
  ///   "driverId": "uuid",
  ///   "driverName": "John Doe",
  ///   "startTime": "2026-02-02T01:14:04.775Z",
  ///   "endTime": null,
  ///   "status": 1,
  ///   "createdAt": "2026-02-02T01:14:04.775Z"
  /// }
  /// ```
  factory DriverTripModel.fromJson(Map<String, dynamic> json) {
    return DriverTripModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? '',
      routeName: json['routeName'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      vehicleRegistration: (json['vehicleRegistrationNumber']
          as Map<String, dynamic>?)?['value'] as String?,
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'] as String?,
      toutId: json['toutId']?.toString(),
      toutName: json['toutName'] as String?,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      passengerCount: json['passengerCount'] as int?,
      maxCapacity: json['maxCapacity'] as int?,
      fare: (json['fare'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'routeId': routeId,
        'routeName': routeName,
        'status': status,
        'startTime': startTime.toIso8601String(),
        if (vehicleRegistration != null)
          'vehicleRegistrationNumber': {'value': vehicleRegistration},
        if (driverId != null) 'driverId': driverId,
        if (driverName != null) 'driverName': driverName,
        if (toutId != null) 'toutId': toutId,
        if (toutName != null) 'toutName': toutName,
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  DriverTrip toEntity() => DriverTrip(
        id: id,
        routeId: routeId,
        routeName: routeName,
        status: _mapStatus(status),
        startTime: startTime,
        endTime: endTime,
        passengerCount: passengerCount ?? 0,
        maxCapacity: maxCapacity,
        fare: fare ?? 0.0,
        vehicleRegistration: vehicleRegistration,
      );

  DriverTripStatus _mapStatus(int status) {
    switch (status) {
      case 0:
        return DriverTripStatus.pending;
      case 1:
        return DriverTripStatus.active;
      case 2:
        return DriverTripStatus.completed;
      default:
        return DriverTripStatus.cancelled;
    }
  }

  static int statusToInt(DriverTripStatus status) {
    switch (status) {
      case DriverTripStatus.pending:
        return 0;
      case DriverTripStatus.active:
        return 1;
      case DriverTripStatus.completed:
        return 2;
      case DriverTripStatus.cancelled:
        return 3;
    }
  }
}
```

### Step 2: Create models barrel file

Create `lib/features/driver/trips/data/models/models.dart`:

```dart
/// Trips data models barrel file.
library;

export 'driver_trip_model.dart';
```

### Step 3: Create TripsRemoteDataSource

Create `lib/features/driver/trips/data/datasources/trips_remote_datasource.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/driver_trip.dart';
import '../models/driver_trip_model.dart';

/// Provider for trips remote data source.
final tripsRemoteDataSourceProvider = Provider<TripsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TripsRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for trips data operations.
abstract class TripsRemoteDataSource {
  /// Gets trips for a vehicle.
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Gets active trip for a vehicle.
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId);

  /// Starts a new trip.
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  });

  /// Ends a trip.
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  });

  /// Updates trip status.
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  });
}

/// Implementation of trips remote data source.
class TripsRemoteDataSourceImpl implements TripsRemoteDataSource {
  TripsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    return apiClient.get<List<DriverTrip>>(
      ApiEndpoints.trips,
      queryParameters: {
        if (vehicleId != null) 'VehicleId': vehicleId,
        if (routeId != null) 'RouteId': routeId,
        if (status != null) 'Status': DriverTripModel.statusToInt(status).toString(),
        if (pageNumber != null) 'PageNumber': pageNumber.toString(),
        if (pageSize != null) 'PageSize': pageSize.toString(),
      },
      fromJson: (data) {
        if (data is! List) return <DriverTrip>[];
        return data
            .map((json) => DriverTripModel.fromJson(
                  json as Map<String, dynamic>,
                ).toEntity())
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId) async {
    final result = await getTrips(
      vehicleId: vehicleId,
      status: DriverTripStatus.active,
      pageSize: 1,
    );

    return result.fold(
      (failure) => Left(failure),
      (trips) => Right(trips.isNotEmpty ? trips.first : null),
    );
  }

  @override
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  }) async {
    return apiClient.post<DriverTrip>(
      ApiEndpoints.trips,
      data: {
        'vehicleId': vehicleId,
        'routeId': routeId,
        'driverId': driverId,
        if (toutId != null) 'toutId': toutId,
        'startTime': DateTime.now().toIso8601String(),
      },
      fromJson: (data) => DriverTripModel.fromJson(
        data as Map<String, dynamic>,
      ).toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  }) async {
    return updateTripStatus(
      tripId: tripId,
      status: DriverTripStatus.completed,
      reason: reason,
    );
  }

  @override
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  }) async {
    return apiClient.put<void>(
      ApiEndpoints.trips,
      data: {
        'tripId': tripId,
        'status': DriverTripModel.statusToInt(status),
        if (reason != null) 'reason': reason,
      },
    );
  }
}
```

### Step 4: Create datasources barrel file

Create `lib/features/driver/trips/data/datasources/datasources.dart`:

```dart
/// Trips datasources barrel file.
library;

export 'trips_remote_datasource.dart';
```

### Step 5: Create TripsRepository

Create `lib/features/driver/trips/data/repositories/trips_repository.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/driver_trip.dart';
import '../datasources/trips_remote_datasource.dart';

/// Provider for trips repository.
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  final remoteDataSource = ref.watch(tripsRemoteDataSourceProvider);
  return TripsRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for trips repository.
abstract class TripsRepository {
  /// Gets trips.
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Gets active trip.
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId);

  /// Starts a trip.
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  });

  /// Ends a trip.
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  });

  /// Updates trip status.
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  });
}

/// Implementation of trips repository.
class TripsRepositoryImpl implements TripsRepository {
  TripsRepositoryImpl({required this.remoteDataSource});

  final TripsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  }) {
    return remoteDataSource.getTrips(
      vehicleId: vehicleId,
      routeId: routeId,
      status: status,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId) {
    return remoteDataSource.getActiveTrip(vehicleId);
  }

  @override
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  }) {
    return remoteDataSource.startTrip(
      vehicleId: vehicleId,
      routeId: routeId,
      driverId: driverId,
      toutId: toutId,
    );
  }

  @override
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  }) {
    return remoteDataSource.endTrip(tripId: tripId, reason: reason);
  }

  @override
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  }) {
    return remoteDataSource.updateTripStatus(
      tripId: tripId,
      status: status,
      reason: reason,
    );
  }
}
```

### Step 6: Create repositories barrel file

Create `lib/features/driver/trips/data/repositories/repositories.dart`:

```dart
/// Trips repositories barrel file.
library;

export 'trips_repository.dart';
```

---

## AGENT 5: API Endpoints & Verification

### Task: Add API endpoints and verify all data layer code

### Step 1: Check/Update API Endpoints

Verify `lib/core/network/api_endpoints.dart` has these endpoints. Add if missing:

```dart
// Driver endpoints
static const String personnel = '/api/Personnel';
static const String dailyVehicleTotals = '/api/DailyVehicleTotals';
static const String payments = '/api/Payments';
static const String trips = '/api/Trips';
static const String vehicles = '/api/Vehicles';
static const String vehicleAssignRoute = '/api/Vehicles/assign-route';
static const String routes = '/api/Routes';
```

### Step 2: Update driver.dart barrel file

Update `lib/features/driver/driver.dart` to export data layer:

```dart
/// Driver feature barrel file.
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
```

### Step 3: Run flutter analyze

```bash
cd C:/Users/antho/komiut && flutter analyze lib/features/driver/
```

Fix any errors.

### Step 4: Run full flutter analyze

```bash
cd C:/Users/antho/komiut && flutter analyze
```

Report results. Goal: 0 errors.

### Step 5: Format code

```bash
cd C:/Users/antho/komiut && dart format lib/features/driver/
```

### Step 6: Verify all files exist

Check all data layer files exist:
- 8 model files (2 per feature)
- 4 datasource files
- 4 repository files
- 12 barrel files

### Deliverables

- All API endpoints present
- driver.dart barrel exports all data layer
- 0 errors in flutter analyze
- All files formatted
