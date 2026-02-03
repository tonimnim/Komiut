# Komiut Codebase Refactoring Plan

## Overview

This document outlines a 6-phase plan to unify the Komiut codebase into a professional, consistent architecture. The goal is to merge Musa's driver UI work with the existing codebase patterns, creating one unified system.

**Current State:**
- Passenger features: Riverpod pattern (GOOD - use as reference)
- Driver features: Mixed BLoC + incomplete UI (NEEDS REFACTORING)
- Two parallel driver implementations exist (`lib/driver/` and `lib/features/driver/`)

**Target State:**
- All features use Riverpod pattern
- Consistent folder structure across all features
- Unified widget library
- Single source of truth for each feature

---

## Target Folder Structure

```
lib/
├── core/                           # Shared infrastructure (KEEP)
│   ├── config/
│   ├── constants/
│   ├── data/models/
│   ├── database/
│   ├── domain/entities/
│   ├── errors/
│   ├── navigation/
│   ├── network/
│   ├── providers/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/                    # UNIFIED widget library
│       ├── animations/
│       ├── buttons/
│       ├── cards/
│       ├── feedback/
│       ├── inputs/
│       ├── layout/
│       ├── lists/
│       ├── loading/
│       └── navigation/             # NEW: Shared nav components
│           ├── driver_bottom_nav.dart
│           └── passenger_bottom_nav.dart
├── features/
│   ├── auth/                       # SHARED - Authentication
│   ├── driver/                     # DRIVER-ONLY features
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   ├── earnings/
│   │   ├── queue/
│   │   ├── trips/
│   │   └── driver.dart             # Barrel file
│   ├── passenger/                  # PASSENGER-ONLY features
│   │   ├── discovery/              # Sacco discovery
│   │   ├── booking/
│   │   ├── tickets/
│   │   ├── trips/
│   │   └── passenger.dart          # Barrel file
│   ├── shared/                     # SHARED across roles
│   │   ├── activity/
│   │   ├── home/
│   │   ├── loyalty/
│   │   ├── notifications/
│   │   ├── payment/
│   │   ├── profile/
│   │   ├── routes/
│   │   ├── scan/
│   │   └── settings/
│   └── features.dart               # Master barrel file
├── shared/                         # Global shared (KEEP minimal)
│   └── widgets/
└── main.dart
```

---

## Phase Dependencies

```
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 5 ──► Phase 6
   │           │           │           │           │           │
   ▼           ▼           ▼           ▼           ▼           ▼
Cleanup    Entities    Providers   Screens    Testing    Security
```

Each phase MUST be completed before the next begins.

---

## PHASE 1: Cleanup & Structure Organization
**Duration: Foundation work**
**Depends on: Nothing**

### 1.1 Remove Duplicate Driver Implementation

**Problem:** Two driver implementations exist:
- `lib/driver/` (BLoC-based, has data layer)
- `lib/features/driver/` (Musa's UI-only work)

**Actions:**

1. **Backup existing code:**
   ```bash
   git checkout -b refactor/phase-1-cleanup
   ```

2. **Delete `lib/driver/` folder entirely:**
   - This folder uses BLoC pattern (inconsistent with Riverpod)
   - We will rebuild using Musa's UI + proper Riverpod architecture

3. **Reorganize `lib/features/driver/` structure:**

   Current (Musa's):
   ```
   lib/features/driver/
   ├── earnings/presentation/screens/
   ├── home/presentation/screens/
   ├── queue/presentation/screens/
   └── trips/presentation/screens/
   ```

   Target:
   ```
   lib/features/driver/
   ├── dashboard/
   │   ├── data/
   │   │   ├── datasources/
   │   │   ├── models/
   │   │   └── repositories/
   │   ├── domain/
   │   │   └── entities/
   │   └── presentation/
   │       ├── providers/
   │       ├── screens/
   │       └── widgets/
   ├── earnings/
   │   ├── data/...
   │   ├── domain/...
   │   └── presentation/...
   ├── queue/
   │   ├── data/...
   │   ├── domain/...
   │   └── presentation/...
   ├── trips/
   │   ├── data/...
   │   ├── domain/...
   │   └── presentation/...
   └── driver.dart
   ```

4. **Move Musa's screens to correct locations:**
   - `driver_home_screen.dart` → `driver/dashboard/presentation/screens/`
   - `earnings_screen.dart` → `driver/earnings/presentation/screens/`
   - `queue_screen.dart` → `driver/queue/presentation/screens/`
   - `driver_trips_screen.dart` → `driver/trips/presentation/screens/`

### 1.2 Reorganize Passenger Features

**Current (scattered):**
```
lib/features/
├── booking/
├── passenger/discovery/
├── tickets/
└── trips/
```

**Target (unified under passenger/):**
```
lib/features/passenger/
├── booking/
├── discovery/
├── tickets/
├── trips/
└── passenger.dart
```

**Actions:**
1. Move `lib/features/booking/` → `lib/features/passenger/booking/`
2. Move `lib/features/tickets/` → `lib/features/passenger/tickets/`
3. Move `lib/features/trips/` → `lib/features/passenger/trips/`
4. Keep `lib/features/passenger/discovery/` (already correct)
5. Create `lib/features/passenger/passenger.dart` barrel file

### 1.3 Organize Shared Features

**Move to `lib/features/shared/`:**
- `lib/features/activity/` → `lib/features/shared/activity/`
- `lib/features/home/` → `lib/features/shared/home/`
- `lib/features/loyalty/` → `lib/features/shared/loyalty/`
- `lib/features/notifications/` → `lib/features/shared/notifications/`
- `lib/features/payment/` → `lib/features/shared/payment/`
- `lib/features/queue/` → `lib/features/shared/queue/`
- `lib/features/routes/` → `lib/features/shared/routes/`
- `lib/features/scan/` → `lib/features/shared/scan/`
- `lib/features/settings/` → `lib/features/shared/settings/`

### 1.4 Extract Shared Widgets

**Problem:** Bottom navigation bar duplicated 4 times in driver screens.

**Actions:**

1. Create `lib/core/widgets/navigation/driver_bottom_nav.dart`:
   ```dart
   class DriverBottomNav extends StatelessWidget {
     const DriverBottomNav({super.key, required this.currentIndex});
     final int currentIndex;
     // ... extracted from Musa's screens
   }
   ```

2. Create `lib/core/widgets/navigation/passenger_bottom_nav.dart`:
   ```dart
   class PassengerBottomNav extends StatelessWidget {
     const PassengerBottomNav({super.key, required this.currentIndex});
     final int currentIndex;
   }
   ```

3. Update all driver screens to use `DriverBottomNav`
4. Update all passenger screens to use `PassengerBottomNav`

### 1.5 Update Import Paths

After all moves, update all import statements:
- Use barrel files where possible
- Remove dead imports
- Run `dart fix --apply`

### 1.6 Deliverables Checklist

- [ ] `lib/driver/` deleted
- [ ] `lib/features/driver/` restructured with data/domain/presentation folders
- [ ] `lib/features/passenger/` contains all passenger features
- [ ] `lib/features/shared/` contains all shared features
- [ ] Shared navigation widgets extracted
- [ ] All imports updated
- [ ] `flutter analyze` passes (warnings OK, no errors)

---

## PHASE 2: Domain Layer Implementation
**Duration: Entity definitions**
**Depends on: Phase 1 complete**

### 2.1 Create Driver Domain Entities

Follow the Sacco entity pattern from `lib/features/passenger/discovery/domain/entities/sacco.dart`.

**Create these entities:**

1. **`lib/features/driver/dashboard/domain/entities/driver_profile.dart`:**
   ```dart
   import 'package:equatable/equatable.dart';

   /// Represents a driver's profile information.
   class DriverProfile extends Equatable {
     const DriverProfile({
       required this.id,
       required this.fullName,
       required this.email,
       this.phoneNumber,
       this.photoUrl,
       this.vehicleId,
       this.saccoId,
       this.isVerified = false,
       this.isOnline = false,
       this.rating,
     });

     final String id;
     final String fullName;
     final String email;
     final String? phoneNumber;
     final String? photoUrl;
     final String? vehicleId;
     final String? saccoId;
     final bool isVerified;
     final bool isOnline;
     final double? rating;

     bool get hasVehicle => vehicleId != null;
     bool get hasSacco => saccoId != null;
     String get displayRating => rating?.toStringAsFixed(1) ?? 'N/A';

     @override
     List<Object?> get props => [
           id, fullName, email, phoneNumber, photoUrl,
           vehicleId, saccoId, isVerified, isOnline, rating,
         ];

     DriverProfile copyWith({...}) => DriverProfile(...);
   }
   ```

2. **`lib/features/driver/dashboard/domain/entities/driver_stats.dart`:**
   ```dart
   class DriverStats extends Equatable {
     const DriverStats({
       required this.totalTrips,
       required this.totalEarnings,
       required this.totalPassengers,
       this.averageRating,
       this.completionRate,
     });

     final int totalTrips;
     final double totalEarnings;
     final int totalPassengers;
     final double? averageRating;
     final double? completionRate;

     // Computed properties
     double get averageEarningsPerTrip =>
         totalTrips > 0 ? totalEarnings / totalTrips : 0;

     @override
     List<Object?> get props => [...];
   }
   ```

3. **`lib/features/driver/earnings/domain/entities/earnings_summary.dart`:**
   ```dart
   class EarningsSummary extends Equatable {
     const EarningsSummary({
       required this.today,
       required this.thisWeek,
       required this.thisMonth,
       required this.allTime,
       this.pendingPayout,
       this.lastPayoutDate,
     });

     final double today;
     final double thisWeek;
     final double thisMonth;
     final double allTime;
     final double? pendingPayout;
     final DateTime? lastPayoutDate;

     @override
     List<Object?> get props => [...];
   }
   ```

4. **`lib/features/driver/earnings/domain/entities/earnings_transaction.dart`:**
   ```dart
   class EarningsTransaction extends Equatable {
     const EarningsTransaction({
       required this.id,
       required this.amount,
       required this.type,
       required this.timestamp,
       this.tripId,
       this.description,
     });

     final String id;
     final double amount;
     final EarningsType type; // enum: trip, bonus, deduction, payout
     final DateTime timestamp;
     final String? tripId;
     final String? description;

     @override
     List<Object?> get props => [...];
   }
   ```

5. **`lib/features/driver/queue/domain/entities/queue_position.dart`:**
   ```dart
   class QueuePosition extends Equatable {
     const QueuePosition({
       required this.id,
       required this.position,
       required this.routeId,
       required this.routeName,
       required this.joinedAt,
       this.estimatedWaitMinutes,
       this.vehiclesAhead,
     });

     final String id;
     final int position;
     final String routeId;
     final String routeName;
     final DateTime joinedAt;
     final int? estimatedWaitMinutes;
     final int? vehiclesAhead;

     bool get isFirst => position == 1;
     Duration get waitDuration => DateTime.now().difference(joinedAt);

     @override
     List<Object?> get props => [...];
   }
   ```

6. **`lib/features/driver/trips/domain/entities/driver_trip.dart`:**
   ```dart
   class DriverTrip extends Equatable {
     const DriverTrip({
       required this.id,
       required this.routeId,
       required this.routeName,
       required this.status,
       required this.startTime,
       this.endTime,
       this.passengerCount,
       this.fare,
       this.startStop,
       this.endStop,
     });

     final String id;
     final String routeId;
     final String routeName;
     final TripStatus status; // enum: pending, active, completed, cancelled
     final DateTime startTime;
     final DateTime? endTime;
     final int? passengerCount;
     final double? fare;
     final String? startStop;
     final String? endStop;

     bool get isActive => status == TripStatus.active;
     bool get isCompleted => status == TripStatus.completed;
     Duration? get duration => endTime?.difference(startTime);

     @override
     List<Object?> get props => [...];
   }
   ```

### 2.2 Create Shared Domain Entities (if not exist)

Verify these exist in `lib/core/domain/entities/` or create:
- `vehicle.dart` - Vehicle information
- `route.dart` - Route information
- `stop.dart` - Stop information

### 2.3 Create Enums

Add to `lib/core/domain/enums/enums.dart`:
```dart
enum TripStatus { pending, active, completed, cancelled }
enum EarningsType { trip, bonus, deduction, payout }
enum QueueStatus { waiting, boarding, departed }
```

### 2.4 Deliverables Checklist

- [ ] All driver entities created with Equatable
- [ ] All entities have copyWith methods
- [ ] All entities have computed properties where useful
- [ ] Enums added to core/domain/enums
- [ ] `flutter analyze` passes

---

## PHASE 3: Data Layer Implementation
**Duration: Models, Datasources, Repositories**
**Depends on: Phase 2 complete**

### 3.1 Create Data Models

Follow the SaccoModel pattern. Each model needs:
- `fromJson()` factory
- `fromEntity()` factory
- `toJson()` method
- `toEntity()` method

**Create these models:**

1. **`lib/features/driver/dashboard/data/models/driver_profile_model.dart`:**
   ```dart
   class DriverProfileModel {
     DriverProfileModel({
       required this.id,
       required this.fullName,
       required this.email,
       // ... all fields
     });

     final String id;
     final String fullName;
     // ... fields

     factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
       return DriverProfileModel(
         id: json['id']?.toString() ?? '',
         fullName: json['full_name'] as String? ?? '',
         email: json['email'] as String? ?? '',
         phoneNumber: json['phone_number'] as String?,
         photoUrl: json['photo_url'] as String?,
         vehicleId: json['vehicle_id']?.toString(),
         saccoId: json['sacco_id']?.toString(),
         isVerified: json['is_verified'] as bool? ?? false,
         isOnline: json['is_online'] as bool? ?? false,
         rating: (json['rating'] as num?)?.toDouble(),
       );
     }

     factory DriverProfileModel.fromEntity(DriverProfile entity) {
       return DriverProfileModel(
         id: entity.id,
         fullName: entity.fullName,
         // ... mapping
       );
     }

     Map<String, dynamic> toJson() => {
       'id': id,
       'full_name': fullName,
       'email': email,
       if (phoneNumber != null) 'phone_number': phoneNumber,
       // ... conditional fields
     };

     DriverProfile toEntity() => DriverProfile(
       id: id,
       fullName: fullName,
       email: email,
       phoneNumber: phoneNumber,
       photoUrl: photoUrl,
       vehicleId: vehicleId,
       saccoId: saccoId,
       isVerified: isVerified,
       isOnline: isOnline,
       rating: rating,
     );
   }
   ```

2. Create similar models for:
   - `driver_stats_model.dart`
   - `earnings_summary_model.dart`
   - `earnings_transaction_model.dart`
   - `queue_position_model.dart`
   - `driver_trip_model.dart`

### 3.2 Create Remote Datasources

Follow the SaccoRemoteDataSource pattern. Each datasource needs:
- Provider for DI
- Abstract interface
- Implementation with Either<Failure, T>

**Create these datasources:**

1. **`lib/features/driver/dashboard/data/datasources/dashboard_remote_datasource.dart`:**
   ```dart
   import 'package:dartz/dartz.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import '../../../../core/core.dart';

   final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
     final apiClient = ref.watch(apiClientProvider);
     return DashboardRemoteDataSourceImpl(apiClient: apiClient);
   });

   abstract class DashboardRemoteDataSource {
     Future<Either<Failure, DriverProfile>> getDriverProfile();
     Future<Either<Failure, DriverStats>> getDriverStats();
     Future<Either<Failure, void>> updateOnlineStatus(bool isOnline);
   }

   class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
     DashboardRemoteDataSourceImpl({required this.apiClient});

     final ApiClient apiClient;

     @override
     Future<Either<Failure, DriverProfile>> getDriverProfile() async {
       return apiClient.get<DriverProfile>(
         ApiEndpoints.driverProfile,
         fromJson: (data) => DriverProfileModel.fromJson(
           data as Map<String, dynamic>,
         ).toEntity(),
       );
     }

     @override
     Future<Either<Failure, DriverStats>> getDriverStats() async {
       return apiClient.get<DriverStats>(
         ApiEndpoints.driverStats,
         fromJson: (data) => DriverStatsModel.fromJson(
           data as Map<String, dynamic>,
         ).toEntity(),
       );
     }

     @override
     Future<Either<Failure, void>> updateOnlineStatus(bool isOnline) async {
       return apiClient.put(
         ApiEndpoints.driverOnlineStatus,
         data: {'is_online': isOnline},
       );
     }
   }
   ```

2. Create similar datasources for:
   - `earnings_remote_datasource.dart`
   - `queue_remote_datasource.dart`
   - `trips_remote_datasource.dart`

### 3.3 Create Repositories

**Create these repositories:**

1. **`lib/features/driver/dashboard/data/repositories/dashboard_repository.dart`:**
   ```dart
   final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
     final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
     return DashboardRepositoryImpl(remoteDataSource: remoteDataSource);
   });

   abstract class DashboardRepository {
     Future<Either<Failure, DriverProfile>> getDriverProfile();
     Future<Either<Failure, DriverStats>> getDriverStats();
     Future<Either<Failure, void>> updateOnlineStatus(bool isOnline);
   }

   class DashboardRepositoryImpl implements DashboardRepository {
     DashboardRepositoryImpl({required this.remoteDataSource});

     final DashboardRemoteDataSource remoteDataSource;

     @override
     Future<Either<Failure, DriverProfile>> getDriverProfile() {
       return remoteDataSource.getDriverProfile();
     }

     @override
     Future<Either<Failure, DriverStats>> getDriverStats() {
       return remoteDataSource.getDriverStats();
     }

     @override
     Future<Either<Failure, void>> updateOnlineStatus(bool isOnline) {
       return remoteDataSource.updateOnlineStatus(isOnline);
     }
   }
   ```

2. Create similar repositories for:
   - `earnings_repository.dart`
   - `queue_repository.dart`
   - `trips_repository.dart`

### 3.4 Add API Endpoints

Add to `lib/core/network/api_endpoints.dart`:
```dart
class ApiEndpoints {
  // ... existing endpoints

  // Driver endpoints
  static const String driverProfile = '/api/v1/driver/profile';
  static const String driverStats = '/api/v1/driver/stats';
  static const String driverOnlineStatus = '/api/v1/driver/status';
  static const String driverEarnings = '/api/v1/driver/earnings';
  static const String driverEarningsHistory = '/api/v1/driver/earnings/history';
  static const String driverQueue = '/api/v1/driver/queue';
  static const String driverQueueJoin = '/api/v1/driver/queue/join';
  static const String driverQueueLeave = '/api/v1/driver/queue/leave';
  static const String driverTrips = '/api/v1/driver/trips';
  static const String driverActiveTrip = '/api/v1/driver/trips/active';
  static const String driverTripStart = '/api/v1/driver/trips/start';
  static const String driverTripEnd = '/api/v1/driver/trips/end';
}
```

### 3.5 Deliverables Checklist

- [ ] All data models created with fromJson/toJson/toEntity
- [ ] All remote datasources created with Either pattern
- [ ] All repositories created
- [ ] API endpoints added
- [ ] `flutter analyze` passes

---

## PHASE 4: Presentation Layer Implementation
**Duration: Providers and Screen Updates**
**Depends on: Phase 3 complete**

### 4.1 Create Riverpod Providers

Follow the sacco_providers.dart pattern.

**Create these provider files:**

1. **`lib/features/driver/dashboard/presentation/providers/dashboard_providers.dart`:**
   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import '../../domain/entities/driver_profile.dart';
   import '../../domain/entities/driver_stats.dart';
   import '../../data/repositories/dashboard_repository.dart';

   // ─────────────────────────────────────────────────────────────────────────────
   // Data Providers
   // ─────────────────────────────────────────────────────────────────────────────

   final driverProfileProvider = FutureProvider<DriverProfile>((ref) async {
     final repository = ref.watch(dashboardRepositoryProvider);
     final result = await repository.getDriverProfile();
     return result.fold(
       (failure) => throw Exception(failure.message),
       (profile) => profile,
     );
   });

   final driverStatsProvider = FutureProvider<DriverStats>((ref) async {
     final repository = ref.watch(dashboardRepositoryProvider);
     final result = await repository.getDriverStats();
     return result.fold(
       (failure) => throw Exception(failure.message),
       (stats) => stats,
     );
   });

   // ─────────────────────────────────────────────────────────────────────────────
   // State Providers
   // ─────────────────────────────────────────────────────────────────────────────

   final isOnlineProvider = StateProvider<bool>((ref) => false);

   // ─────────────────────────────────────────────────────────────────────────────
   // Action Providers
   // ─────────────────────────────────────────────────────────────────────────────

   final toggleOnlineStatusProvider = FutureProvider.family<void, bool>((ref, isOnline) async {
     final repository = ref.watch(dashboardRepositoryProvider);
     final result = await repository.updateOnlineStatus(isOnline);
     result.fold(
       (failure) => throw Exception(failure.message),
       (_) {
         ref.read(isOnlineProvider.notifier).state = isOnline;
         ref.invalidate(driverProfileProvider);
       },
     );
   });
   ```

2. **`lib/features/driver/earnings/presentation/providers/earnings_providers.dart`:**
   ```dart
   // ─────────────────────────────────────────────────────────────────────────────
   // Data Providers
   // ─────────────────────────────────────────────────────────────────────────────

   final earningsSummaryProvider = FutureProvider<EarningsSummary>((ref) async {
     final repository = ref.watch(earningsRepositoryProvider);
     final result = await repository.getEarningsSummary();
     return result.fold(
       (failure) => throw Exception(failure.message),
       (summary) => summary,
     );
   });

   final earningsHistoryProvider = FutureProvider<List<EarningsTransaction>>((ref) async {
     final repository = ref.watch(earningsRepositoryProvider);
     final period = ref.watch(selectedEarningsPeriodProvider);
     final result = await repository.getEarningsHistory(period: period);
     return result.fold(
       (failure) => throw Exception(failure.message),
       (history) => history,
     );
   });

   // ─────────────────────────────────────────────────────────────────────────────
   // State Providers
   // ─────────────────────────────────────────────────────────────────────────────

   final selectedEarningsPeriodProvider = StateProvider<EarningsPeriod>(
     (ref) => EarningsPeriod.today,
   );

   // ─────────────────────────────────────────────────────────────────────────────
   // Computed Providers
   // ─────────────────────────────────────────────────────────────────────────────

   final totalEarningsForPeriodProvider = Provider<AsyncValue<double>>((ref) {
     final historyAsync = ref.watch(earningsHistoryProvider);
     return historyAsync.whenData((transactions) {
       return transactions
           .where((t) => t.type != EarningsType.deduction)
           .fold(0.0, (sum, t) => sum + t.amount);
     });
   });
   ```

3. Create similar providers for:
   - `queue_providers.dart`
   - `trips_providers.dart`

### 4.2 Update Musa's Screens

Convert screens from `StatefulWidget` + `setState()` to `ConsumerWidget` + Riverpod.

**Example conversion for `driver_home_screen.dart`:**

**BEFORE (Musa's code):**
```dart
class DriverHomeScreen extends StatefulWidget {
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? CircularProgressIndicator()
        : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Text('Hello, Driver'), // Hardcoded
        Text('KES 0.00'),      // Hardcoded
      ],
    );
  }
}
```

**AFTER (Refactored):**
```dart
class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);
    final statsAsync = ref.watch(driverStatsProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const ShimmerLoading(),
        error: (error, stack) => AppError(
          message: error.toString(),
          onRetry: () => ref.invalidate(driverProfileProvider),
        ),
        data: (profile) => _buildContent(context, ref, profile, statsAsync),
      ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 0),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DriverProfile profile,
    AsyncValue<DriverStats> statsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(driverProfileProvider);
        ref.invalidate(driverStatsProvider);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _DriverHeader(profile: profile),
            statsAsync.when(
              loading: () => const StatsShimmer(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) => _DriverStatsCard(stats: stats),
            ),
            // ... more content
          ],
        ),
      ),
    );
  }
}

// Private widgets
class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.profile});
  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Hello, ${profile.fullName}'),
        if (profile.hasVehicle) Text('Vehicle: ${profile.vehicleId}'),
      ],
    );
  }
}
```

### 4.3 Create Reusable Driver Widgets

Extract common patterns into widgets:

1. **`lib/features/driver/dashboard/presentation/widgets/driver_stats_card.dart`**
2. **`lib/features/driver/earnings/presentation/widgets/earnings_chart.dart`**
3. **`lib/features/driver/queue/presentation/widgets/queue_position_card.dart`**
4. **`lib/features/driver/trips/presentation/widgets/trip_card.dart`**

### 4.4 Update Navigation/Routing

Update `lib/core/navigation/app_router.dart` with new driver routes if needed.

### 4.5 Deliverables Checklist

- [ ] All provider files created
- [ ] All screens converted to ConsumerWidget
- [ ] All hardcoded data replaced with provider calls
- [ ] Error states handled with AppError widget
- [ ] Loading states handled with shimmer/skeleton
- [ ] Pull-to-refresh implemented
- [ ] Shared navigation widget used
- [ ] `flutter analyze` passes

---

## PHASE 5: Testing & Documentation
**Duration: Quality assurance**
**Depends on: Phase 4 complete**

### 5.1 Unit Tests

Create tests for:

1. **Entity Tests:**
   ```dart
   // test/features/driver/domain/entities/driver_profile_test.dart
   void main() {
     group('DriverProfile', () {
       test('hasVehicle returns true when vehicleId is not null', () {
         const profile = DriverProfile(
           id: '1',
           fullName: 'Test',
           email: 'test@test.com',
           vehicleId: 'V001',
         );
         expect(profile.hasVehicle, true);
       });

       test('copyWith creates new instance with updated values', () {
         const profile = DriverProfile(...);
         final updated = profile.copyWith(fullName: 'New Name');
         expect(updated.fullName, 'New Name');
         expect(updated.id, profile.id);
       });
     });
   }
   ```

2. **Model Tests:**
   ```dart
   // test/features/driver/data/models/driver_profile_model_test.dart
   void main() {
     group('DriverProfileModel', () {
       test('fromJson creates valid model', () {
         final json = {'id': '1', 'full_name': 'Test', 'email': 'test@test.com'};
         final model = DriverProfileModel.fromJson(json);
         expect(model.fullName, 'Test');
       });

       test('toEntity creates valid entity', () {
         final model = DriverProfileModel(...);
         final entity = model.toEntity();
         expect(entity, isA<DriverProfile>());
       });
     });
   }
   ```

3. **Provider Tests:**
   ```dart
   // test/features/driver/presentation/providers/dashboard_providers_test.dart
   void main() {
     group('driverProfileProvider', () {
       test('returns profile on success', () async {
         final container = ProviderContainer(
           overrides: [
             dashboardRepositoryProvider.overrideWithValue(MockDashboardRepository()),
           ],
         );
         final profile = await container.read(driverProfileProvider.future);
         expect(profile, isA<DriverProfile>());
       });
     });
   }
   ```

### 5.2 Widget Tests

Create widget tests for key screens:

```dart
// test/features/driver/presentation/screens/driver_home_screen_test.dart
void main() {
  testWidgets('shows loading state initially', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: DriverHomeScreen()),
      ),
    );
    expect(find.byType(ShimmerLoading), findsOneWidget);
  });

  testWidgets('shows profile name after loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverProfileProvider.overrideWith((_) async => mockProfile),
        ],
        child: MaterialApp(home: DriverHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello, Test Driver'), findsOneWidget);
  });
}
```

### 5.3 Create Barrel Files

Create proper barrel files for exports:

1. **`lib/features/driver/driver.dart`:**
   ```dart
   /// Driver feature barrel file.
   library;

   // Dashboard
   export 'dashboard/domain/entities/driver_profile.dart';
   export 'dashboard/domain/entities/driver_stats.dart';
   export 'dashboard/data/repositories/dashboard_repository.dart';
   export 'dashboard/presentation/providers/dashboard_providers.dart';

   // Earnings
   export 'earnings/domain/entities/earnings_summary.dart';
   export 'earnings/domain/entities/earnings_transaction.dart';
   export 'earnings/data/repositories/earnings_repository.dart';
   export 'earnings/presentation/providers/earnings_providers.dart';

   // Queue
   export 'queue/domain/entities/queue_position.dart';
   export 'queue/data/repositories/queue_repository.dart';
   export 'queue/presentation/providers/queue_providers.dart';

   // Trips
   export 'trips/domain/entities/driver_trip.dart';
   export 'trips/data/repositories/trips_repository.dart';
   export 'trips/presentation/providers/trips_providers.dart';
   ```

2. **`lib/features/passenger/passenger.dart`:**
   ```dart
   /// Passenger feature barrel file.
   library;

   // Discovery
   export 'discovery/discovery.dart';

   // Booking
   export 'booking/booking.dart';

   // Tickets
   export 'tickets/tickets.dart';

   // Trips
   export 'trips/trips.dart';
   ```

### 5.4 Documentation

Add documentation comments to key files:
- All public classes
- All public methods
- Complex logic explanations

### 5.5 Deliverables Checklist

- [ ] Unit tests for all entities
- [ ] Unit tests for all models
- [ ] Provider tests for all providers
- [ ] Widget tests for key screens
- [ ] All barrel files created
- [ ] Documentation comments added
- [ ] `flutter test` passes
- [ ] Code coverage > 70%

---

## PHASE 6: Security & Production Readiness
**Duration: Final polish**
**Depends on: Phase 5 complete**

### 6.1 Remove Security Issues

**CRITICAL - Must fix before production:**

1. **Remove auth bypass in `lib/core/config/app_config.dart`:**
   ```dart
   // BEFORE (DANGEROUS)
   static bool skipAuth = true;
   static bool enableMockData = true;

   // AFTER (SAFE)
   static bool skipAuth = kDebugMode; // Only in debug builds
   static bool enableMockData = kDebugMode;
   ```

2. **Remove hardcoded credentials in `lib/core/database/seed_data.dart`:**
   - Delete or protect test user data
   - Use environment variables for any test credentials

3. **Separate environment URLs in `lib/core/config/env_config.dart`:**
   ```dart
   // BEFORE (all same)
   static const String developmentUrl = 'https://v2.komiut.com';
   static const String stagingUrl = 'https://v2.komiut.com';
   static const String productionUrl = 'https://v2.komiut.com';

   // AFTER (separate)
   static const String developmentUrl = 'https://dev.komiut.com';
   static const String stagingUrl = 'https://staging.komiut.com';
   static const String productionUrl = 'https://api.komiut.com';
   ```

4. **Fix empty catch blocks in `lib/core/network/api_interceptor.dart`:**
   ```dart
   // BEFORE
   catch (e) {
     // Empty - dangerous!
   }

   // AFTER
   catch (e) {
     debugPrint('AuthInterceptor error: $e');
     return false;
   }
   ```

### 6.2 Remove GetIt Dependencies (if using Riverpod throughout)

If fully migrated to Riverpod:
1. Remove `get_it` package from `pubspec.yaml`
2. Delete `lib/di/injection_container.dart`
3. Update any remaining GetIt usages to Riverpod

### 6.3 Final Code Quality Checks

Run these commands and fix all issues:

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Check for unused dependencies
flutter pub deps --no-dev

# Run tests
flutter test

# Check for security issues
flutter pub outdated
```

### 6.4 Performance Optimization

1. Add `const` constructors where possible
2. Use `ListView.builder` for long lists
3. Implement pagination for earnings history, trip history
4. Add image caching for profile photos

### 6.5 Final Checklist

- [ ] `skipAuth` only true in debug mode
- [ ] `enableMockData` only true in debug mode
- [ ] No hardcoded credentials in code
- [ ] Separate URLs for each environment
- [ ] All empty catch blocks fixed
- [ ] `flutter analyze` shows 0 errors
- [ ] `flutter test` passes 100%
- [ ] App builds for release without warnings
- [ ] README updated with setup instructions

---

## Summary

| Phase | Focus | Key Deliverables |
|-------|-------|------------------|
| **1** | Cleanup | Folder structure, remove duplicates, extract widgets |
| **2** | Domain | Entities with Equatable, enums |
| **3** | Data | Models, datasources, repositories |
| **4** | Presentation | Riverpod providers, screen updates |
| **5** | Testing | Unit tests, widget tests, documentation |
| **6** | Security | Remove auth bypass, fix vulnerabilities |

**Total Estimated Files to Create/Modify:**
- ~20 new entity/model files
- ~12 new datasource/repository files
- ~8 new provider files
- ~4 screen updates
- ~10 new widget files
- ~30+ test files

**Branch Strategy:**
```
main
  └── refactor/phase-1-cleanup
        └── refactor/phase-2-domain
              └── refactor/phase-3-data
                    └── refactor/phase-4-presentation
                          └── refactor/phase-5-testing
                                └── refactor/phase-6-security
                                      └── Merge to main
```

Create a PR for each phase, review, then merge before starting the next phase.
