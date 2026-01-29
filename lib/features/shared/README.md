# Shared Components Documentation

This document provides guidelines for using shared components in the Komiut app.
Both passenger and driver features should use these shared components for consistency.

## Table of Contents

1. [Directory Structure](#directory-structure)
2. [Shared Widgets](#shared-widgets)
3. [Core Widgets](#core-widgets)
4. [Theme and Styling](#theme-and-styling)
5. [Navigation Patterns](#navigation-patterns)
6. [State Management](#state-management)
7. [API Integration](#api-integration)

---

## Directory Structure

```
lib/
├── core/                          # Core utilities and shared code
│   ├── config/                    # App configuration
│   ├── constants/                 # Constants (routes, app constants)
│   ├── data/                      # Shared data models
│   ├── domain/                    # Shared domain entities and enums
│   ├── navigation/                # Router and navigation guards
│   ├── network/                   # API client and endpoints
│   ├── providers/                 # Shared Riverpod providers
│   ├── theme/                     # Theme, colors, text styles
│   ├── utils/                     # Utility functions
│   └── widgets/                   # Shared widget library
│       ├── buttons/               # Button components
│       ├── cards/                 # Card components
│       ├── feedback/              # Loading, error, snackbar
│       ├── inputs/                # Text fields, dropdowns
│       ├── layout/                # Scaffolds, responsive builders
│       ├── lists/                 # List tiles, sections
│       └── loading/               # Shimmer, overlays
├── features/
│   ├── auth/                      # Authentication (shared)
│   ├── driver/                    # Driver-specific features
│   ├── passenger/                 # Passenger-specific features
│   └── shared/                    # Shared feature screens
│       └── profile/               # Profile screen (role-agnostic)
```

---

## Shared Widgets

### Import Statement

```dart
import 'package:komiut/core/widgets/widgets.dart';
```

### Available Widgets

#### Buttons

| Widget | Usage |
|--------|-------|
| `AppButton` | Primary action button with variants (primary, outlined, text) |
| `AppButton.primary()` | Filled primary button |
| `AppButton.outlined()` | Outlined button |
| `AppButton.text()` | Text-only button |
| `AppIconButton` | Icon-only button |

```dart
// Primary button with loading state
AppButton.primary(
  label: 'Start Trip',
  onPressed: () => startTrip(),
  isLoading: isStarting,
  icon: Icons.play_arrow,
)

// Outlined button
AppButton.outlined(
  label: 'Cancel',
  onPressed: () => cancel(),
  foregroundColor: Colors.red,
)

// Full width button
AppButton.primary(
  label: 'Confirm Booking',
  onPressed: () => confirm(),
  isFullWidth: true,
  size: ButtonSize.large,
)
```

#### Cards

| Widget | Usage |
|--------|-------|
| `AppCard` | Base card with consistent styling |
| `InfoCard` | Information display card |
| `StatCard` | Statistics display with trend indicators |

```dart
// Stat card for earnings
StatCard(
  label: "Today's Earnings",
  value: 'KSh 3,500',
  icon: Icons.account_balance_wallet,
  trend: StatTrend.up,
  trendValue: '+12%',
)

// Compact stat card
StatCard(
  label: 'Trips',
  value: '8',
  compact: true,
)
```

#### Inputs

| Widget | Usage |
|--------|-------|
| `AppTextField` | Styled text input |
| `AppDropdown` | Dropdown selector |
| `AppSearchField` | Search input with icon |

```dart
AppTextField(
  label: 'Registration Number',
  controller: regController,
  prefixIcon: Icons.directions_car,
)

AppSearchField(
  hint: 'Search routes...',
  onChanged: (value) => search(value),
)
```

#### Feedback

| Widget | Usage |
|--------|-------|
| `AppLoading` | Loading indicator |
| `AppError` | Error state display |
| `AppEmptyState` | Empty state with icon and message |
| `AppSnackbar` | Toast notifications |
| `AppDialog` | Confirmation dialogs |
| `ShimmerLoading` | Skeleton loading animation |
| `LoadingOverlay` | Full-screen loading overlay |

```dart
// Empty state
AppEmptyState(
  icon: Icons.history,
  title: 'No trips yet',
  message: 'Your completed trips will appear here.',
)

// Show snackbar
AppSnackbar.show(
  context,
  message: 'Trip started successfully',
  type: SnackbarType.success,
)

// Confirmation dialog
final confirmed = await AppDialog.confirm(
  context,
  title: 'End Trip?',
  message: 'Are you sure you want to end this trip?',
  confirmLabel: 'End Trip',
  confirmColor: Colors.red,
);
```

#### Lists

| Widget | Usage |
|--------|-------|
| `AppListTile` | Styled list tile |
| `AppSectionHeader` | Section header with optional action |
| `AppDivider` | Consistent divider |

```dart
AppSectionHeader(
  title: 'Recent Trips',
  actionLabel: 'View All',
  onAction: () => viewAll(),
)
```

#### Layout

| Widget | Usage |
|--------|-------|
| `AppScaffold` | Base scaffold with consistent styling |
| `ResponsiveBuilder` | Responsive layout builder |

---

## Core Widgets

### Legacy Widgets (Still Available)

For backward compatibility, these widgets remain available:

- `CustomButton` - Use `AppButton` instead
- `CustomTextField` - Use `AppTextField` instead
- `LoadingWidget` - Use `AppLoading` instead
- `EmptyStateWidget` - Use `AppEmptyState` instead
- `CustomErrorWidget` - Use `AppError` instead

---

## Theme and Styling

### Colors

```dart
import 'package:komiut/core/theme/app_colors.dart';

// Primary colors
AppColors.primaryBlue      // #0066CC
AppColors.primaryGreen     // #00B894
AppColors.primaryDark      // #004C99
AppColors.primaryLight     // #3399FF

// Semantic colors
AppColors.success          // #00B894 (green)
AppColors.error            // #D63031 (red)
AppColors.warning          // #FFBE0B (yellow)
AppColors.info             // #0984E3 (blue)

// Status colors
AppColors.completed        // Green
AppColors.failed           // Red
AppColors.pending          // Yellow
```

### Text Styles

```dart
import 'package:komiut/core/theme/app_text_styles.dart';

// Use theme text styles
Theme.of(context).textTheme.headlineLarge
Theme.of(context).textTheme.titleMedium
Theme.of(context).textTheme.bodyMedium
```

### Theme Provider

```dart
import 'package:komiut/core/theme/theme_provider.dart';

// Watch theme mode
final themeMode = ref.watch(themeModeProvider);

// Toggle theme
ref.read(themeModeProvider.notifier).toggle();
```

---

## Navigation Patterns

### Route Constants

```dart
import 'package:komiut/core/constants/route_constants.dart';

// Driver routes
RouteConstants.driverHome       // /driver/home
RouteConstants.driverQueue      // /driver/queue
RouteConstants.driverTrips      // /driver/trips
RouteConstants.driverEarnings   // /driver/earnings

// Passenger routes
RouteConstants.passengerHome    // /passenger/home
RouteConstants.passengerSaccos  // /passenger/saccos

// Shared routes
RouteConstants.sharedProfile    // /shared/profile
RouteConstants.sharedSettings   // /shared/settings
```

### Navigation with GoRouter

```dart
import 'package:go_router/go_router.dart';

// Navigate to a route
context.go(RouteConstants.driverTrips);

// Navigate with parameters
context.go(RouteConstants.driverTripDetailPath('trip-123'));

// Push a route (add to stack)
context.push(RouteConstants.sharedProfile);

// Go back
context.pop();
```

### Role-Based Navigation

The router automatically handles role-based access:
- Passengers cannot access `/driver/*` routes
- Drivers cannot access `/passenger/*` routes
- Both can access `/shared/*` routes

---

## State Management

### Riverpod Patterns

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Read provider once
final value = ref.read(someProvider);

// Watch provider (rebuilds on change)
final value = ref.watch(someProvider);

// Listen for changes
ref.listen(someProvider, (previous, next) {
  // Handle change
});
```

### Role Providers

```dart
import 'package:komiut/core/providers/exports.dart';

// Check current role
final role = ref.watch(currentRoleProvider);
final isDriver = ref.watch(isDriverOrToutProvider);
final isPassenger = ref.watch(isPassengerProvider);

// Get current user
final user = ref.watch(currentUserProvider);
```

### Async Value Handling

```dart
// Handle AsyncValue states
someAsyncValue.when(
  data: (data) => DataWidget(data: data),
  loading: () => const AppLoading(),
  error: (error, stack) => AppError(message: error.toString()),
);
```

---

## API Integration

### API Endpoints

```dart
import 'package:komiut/core/network/api_endpoints.dart';

// Driver endpoints
ApiEndpoints.personnelMy           // GET /api/Personnel/my
ApiEndpoints.tripsMyDriver         // GET /api/Trips/driver/my
ApiEndpoints.vehicleMyDriver       // GET /api/Vehicles/driver/my
ApiEndpoints.driverEarnings        // GET /api/Personnel/earnings

// Queue endpoints
ApiEndpoints.queueJoin             // POST /api/Queues/join
ApiEndpoints.queueLeave            // POST /api/Queues/leave
ApiEndpoints.queueMyPosition       // GET /api/Queues/my-position

// Dynamic endpoints
ApiEndpoints.tripsByDriver(id)     // GET /api/Trips/driver/{id}
ApiEndpoints.vehicleByDriver(id)   // GET /api/Vehicles/driver/{id}
```

### API Client Usage

```dart
import 'package:komiut/core/network/api_client.dart';

// Inject via Riverpod
final apiClient = ref.read(apiClientProvider);

// Make requests
final response = await apiClient.get(ApiEndpoints.tripsMyDriver);
final trips = response.map((json) => Trip.fromJson(json)).toList();
```

---

## Shared Domain Entities

All role-agnostic entities are in `lib/core/domain/entities/`:

| Entity | Description |
|--------|-------------|
| `User` | User with role, status, organization |
| `Organization` | Sacco/company information |
| `Vehicle` | Vehicle with registration, capacity, status |
| `TransportRoute` | Route with stops, fares, duration |
| `Trip` | Trip with driver, vehicle, passengers |
| `Booking` | Passenger booking with payment |
| `Payment` | Payment transaction |
| `Personnel` | Driver/tout profile |

### Importing Entities

```dart
import 'package:komiut/core/domain/exports.dart';

// Now you can use:
// User, Organization, Vehicle, TransportRoute, Trip, Booking, Payment, Personnel
```

---

## Best Practices

### 1. Use Shared Widgets

Always prefer shared widgets over custom implementations for consistency.

### 2. Follow Clean Architecture

```
feature/
├── data/
│   ├── datasources/    # Remote/local data sources
│   ├── models/         # API models (fromJson/toJson)
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic
└── presentation/
    ├── providers/      # Riverpod providers
    ├── screens/        # Screen widgets
    └── widgets/        # Feature-specific widgets
```

### 3. Error Handling

Use `Either<Failure, T>` for error handling:

```dart
import 'package:fpdart/fpdart.dart';
import 'package:komiut/core/errors/failures.dart';

Future<Either<Failure, Trip>> startTrip() async {
  try {
    final trip = await apiClient.post(...);
    return right(trip);
  } catch (e) {
    return left(ServerFailure(message: e.toString()));
  }
}
```

### 4. Screen Structure

```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final someState = ref.watch(someProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: someState.when(
        data: (data) => _buildContent(data),
        loading: () => const AppLoading(),
        error: (e, _) => AppError(message: e.toString()),
      ),
    );
  }

  Widget _buildContent(Data data) {
    // Build UI
  }
}
```

---

## For Musa - Driver Features Quick Start

1. **Start with entities**: Use shared entities from `lib/core/domain/entities/`
2. **Check endpoints**: All driver endpoints are in `lib/core/network/api_endpoints.dart`
3. **Use shared widgets**: Import from `lib/core/widgets/widgets.dart`
4. **Follow patterns**: Look at `lib/features/passenger/` for reference implementations
5. **Navigation**: Driver routes are already configured in `app_router.dart`

### Key Files to Reference

- `lib/core/widgets/widgets.dart` - All shared widgets
- `lib/core/network/api_endpoints.dart` - API endpoints
- `lib/core/domain/exports.dart` - Domain entities
- `lib/features/passenger/` - Example implementations
- `lib/features/driver/driver.dart` - Driver module exports

Happy coding!
