# Phase 1: Agent Instructions

## Overview

Phase 1 is divided into 5 sequential tasks. **Each agent MUST wait for the previous agent to complete before starting.**

```
Agent 1 ──► Agent 2 ──► Agent 3 ──► Agent 4 ──► Agent 5
   │           │           │           │           │
   ▼           ▼           ▼           ▼           ▼
 Driver     Passenger    Shared     Widgets     Imports
Structure   Structure   Structure   Extract      Fix
```

---

## AGENT 1: Driver Feature Structure
**Task: Delete duplicate driver folder and restructure driver features**

### Prerequisites
- Create branch: `git checkout -b refactor/phase-1-cleanup`

### Instructions

#### Step 1: Delete the old BLoC-based driver folder
```bash
rm -rf lib/driver/
```

This removes the entire `lib/driver/` folder which uses the inconsistent BLoC pattern.

#### Step 2: Create the new driver folder structure

Create these empty folders for clean architecture:

```bash
# Dashboard feature
mkdir -p lib/features/driver/dashboard/data/datasources
mkdir -p lib/features/driver/dashboard/data/models
mkdir -p lib/features/driver/dashboard/data/repositories
mkdir -p lib/features/driver/dashboard/domain/entities
mkdir -p lib/features/driver/dashboard/presentation/providers
mkdir -p lib/features/driver/dashboard/presentation/screens
mkdir -p lib/features/driver/dashboard/presentation/widgets

# Earnings feature
mkdir -p lib/features/driver/earnings/data/datasources
mkdir -p lib/features/driver/earnings/data/models
mkdir -p lib/features/driver/earnings/data/repositories
mkdir -p lib/features/driver/earnings/domain/entities
mkdir -p lib/features/driver/earnings/presentation/providers
mkdir -p lib/features/driver/earnings/presentation/screens
mkdir -p lib/features/driver/earnings/presentation/widgets

# Queue feature
mkdir -p lib/features/driver/queue/data/datasources
mkdir -p lib/features/driver/queue/data/models
mkdir -p lib/features/driver/queue/data/repositories
mkdir -p lib/features/driver/queue/domain/entities
mkdir -p lib/features/driver/queue/presentation/providers
mkdir -p lib/features/driver/queue/presentation/screens
mkdir -p lib/features/driver/queue/presentation/widgets

# Trips feature
mkdir -p lib/features/driver/trips/data/datasources
mkdir -p lib/features/driver/trips/data/models
mkdir -p lib/features/driver/trips/data/repositories
mkdir -p lib/features/driver/trips/domain/entities
mkdir -p lib/features/driver/trips/presentation/providers
mkdir -p lib/features/driver/trips/presentation/screens
mkdir -p lib/features/driver/trips/presentation/widgets
```

#### Step 3: Move Musa's screens to the correct locations

Move existing screens from Musa's structure to the new structure:

```bash
# Move home screen to dashboard
mv lib/features/driver/home/presentation/screens/driver_home_screen.dart \
   lib/features/driver/dashboard/presentation/screens/

# Move earnings screen
mv lib/features/driver/earnings/presentation/screens/earnings_screen.dart \
   lib/features/driver/earnings/presentation/screens/
# (This one might already be in the right place, verify first)

# Move queue screen
mv lib/features/driver/queue/presentation/screens/queue_screen.dart \
   lib/features/driver/queue/presentation/screens/
# (This one might already be in the right place, verify first)

# Move trips screen
mv lib/features/driver/trips/presentation/screens/driver_trips_screen.dart \
   lib/features/driver/trips/presentation/screens/
# (This one might already be in the right place, verify first)
```

#### Step 4: Clean up old empty folders

Remove the old `home` folder (now renamed to `dashboard`):
```bash
rm -rf lib/features/driver/home/
```

#### Step 5: Create placeholder files

Create `.gitkeep` files in empty folders to preserve structure:
```bash
touch lib/features/driver/dashboard/data/datasources/.gitkeep
touch lib/features/driver/dashboard/data/models/.gitkeep
touch lib/features/driver/dashboard/data/repositories/.gitkeep
touch lib/features/driver/dashboard/domain/entities/.gitkeep
touch lib/features/driver/dashboard/presentation/providers/.gitkeep
touch lib/features/driver/dashboard/presentation/widgets/.gitkeep
# Repeat for earnings, queue, trips...
```

#### Step 6: Create driver barrel file

Create `lib/features/driver/driver.dart`:
```dart
/// Driver feature barrel file.
///
/// Exports all driver-related features for the Komiut app.
/// This module contains driver-specific functionality including:
/// - Dashboard (home screen, stats)
/// - Earnings (income tracking, payouts)
/// - Queue (stage queue management)
/// - Trips (active and historical trips)
library;

// TODO: Add exports as features are implemented in Phase 2-4
// Dashboard
// export 'dashboard/domain/entities/driver_profile.dart';
// export 'dashboard/presentation/providers/dashboard_providers.dart';

// Earnings
// export 'earnings/domain/entities/earnings_summary.dart';
// export 'earnings/presentation/providers/earnings_providers.dart';

// Queue
// export 'queue/domain/entities/queue_position.dart';
// export 'queue/presentation/providers/queue_providers.dart';

// Trips
// export 'trips/domain/entities/driver_trip.dart';
// export 'trips/presentation/providers/trips_providers.dart';
```

### Deliverables Checklist
- [ ] `lib/driver/` folder deleted
- [ ] New folder structure created for dashboard, earnings, queue, trips
- [ ] Each feature has data/, domain/, presentation/ subfolders
- [ ] Musa's screens moved to correct locations
- [ ] `lib/features/driver/driver.dart` barrel file created
- [ ] Old `home/` folder removed

### Verification
```bash
# Check structure
find lib/features/driver -type d | head -30

# Verify screens exist
ls lib/features/driver/*/presentation/screens/
```

---

## AGENT 2: Passenger Feature Structure
**Task: Consolidate all passenger features under features/passenger/**

### Prerequisites
- Agent 1 must be complete

### Instructions

#### Step 1: Create passenger folder structure

```bash
# Booking feature (move from features/booking/)
mkdir -p lib/features/passenger/booking

# Tickets feature (move from features/tickets/)
mkdir -p lib/features/passenger/tickets

# Trips feature (move from features/trips/)
mkdir -p lib/features/passenger/trips

# Discovery already exists at passenger/discovery/ - keep it
```

#### Step 2: Move booking feature

```bash
# Move entire booking folder contents
mv lib/features/booking/* lib/features/passenger/booking/

# Remove old empty folder
rm -rf lib/features/booking/
```

#### Step 3: Move tickets feature

```bash
# Move entire tickets folder contents
mv lib/features/tickets/* lib/features/passenger/tickets/

# Remove old empty folder
rm -rf lib/features/tickets/
```

#### Step 4: Move trips feature

```bash
# Move entire trips folder contents
mv lib/features/trips/* lib/features/passenger/trips/

# Remove old empty folder
rm -rf lib/features/trips/
```

#### Step 5: Create passenger barrel file

Create `lib/features/passenger/passenger.dart`:
```dart
/// Passenger feature barrel file.
///
/// Exports all passenger-related features for the Komiut app.
/// This module contains passenger-specific functionality including:
/// - Discovery (find saccos, routes, vehicles)
/// - Booking (seat selection, fare calculation)
/// - Tickets (ticket management, QR codes)
/// - Trips (active trip tracking)
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

#### Step 6: Update existing barrel files (if they exist)

Check and update these files to use relative paths:
- `lib/features/passenger/booking/booking.dart`
- `lib/features/passenger/tickets/tickets.dart`
- `lib/features/passenger/trips/trips.dart`

### Deliverables Checklist
- [ ] `lib/features/booking/` moved to `lib/features/passenger/booking/`
- [ ] `lib/features/tickets/` moved to `lib/features/passenger/tickets/`
- [ ] `lib/features/trips/` moved to `lib/features/passenger/trips/`
- [ ] `lib/features/passenger/discovery/` unchanged (already correct)
- [ ] `lib/features/passenger/passenger.dart` barrel file created
- [ ] Old folders removed

### Verification
```bash
# Check structure
ls -la lib/features/passenger/

# Verify all subfolders exist
ls lib/features/passenger/booking/
ls lib/features/passenger/discovery/
ls lib/features/passenger/tickets/
ls lib/features/passenger/trips/
```

---

## AGENT 3: Shared Feature Structure
**Task: Move shared features to features/shared/**

### Prerequisites
- Agent 2 must be complete

### Instructions

#### Step 1: Create shared folder

```bash
mkdir -p lib/features/shared
```

#### Step 2: Move activity feature

```bash
mv lib/features/activity lib/features/shared/
```

#### Step 3: Move home feature

```bash
mv lib/features/home lib/features/shared/
```

#### Step 4: Move loyalty feature

```bash
mv lib/features/loyalty lib/features/shared/
```

#### Step 5: Move notifications feature

```bash
mv lib/features/notifications lib/features/shared/
```

#### Step 6: Move payment feature

```bash
mv lib/features/payment lib/features/shared/
```

#### Step 7: Move queue feature (shared queue, not driver queue)

```bash
mv lib/features/queue lib/features/shared/
```

#### Step 8: Move routes feature

```bash
mv lib/features/routes lib/features/shared/
```

#### Step 9: Move scan feature

```bash
mv lib/features/scan lib/features/shared/
```

#### Step 10: Move settings feature

```bash
mv lib/features/settings lib/features/shared/
```

#### Step 11: Handle auth feature

Auth stays at `lib/features/auth/` (top level) as it's a special shared feature:
```bash
# DO NOT MOVE - keep lib/features/auth/ where it is
```

#### Step 12: Create shared barrel file

Create `lib/features/shared/shared.dart`:
```dart
/// Shared features barrel file.
///
/// Exports features that are used by both drivers and passengers.
/// These are role-agnostic features that provide common functionality.
library;

// Activity tracking
export 'activity/activity.dart';

// Home/Dashboard base
export 'home/home.dart';

// Loyalty program
export 'loyalty/loyalty.dart';

// Push notifications
export 'notifications/notifications.dart';

// Payment processing
export 'payment/payment.dart';

// Queue management (shared logic)
export 'queue/queue.dart';

// Route information
export 'routes/routes.dart';

// QR/Barcode scanning
export 'scan/scan.dart';

// App settings
export 'settings/settings.dart';
```

#### Step 13: Create master features barrel file

Create `lib/features/features.dart`:
```dart
/// Master features barrel file.
///
/// Single entry point for all feature modules in the Komiut app.
library;

// Authentication (special - stays at top level)
export 'auth/auth.dart';

// Driver-specific features
export 'driver/driver.dart';

// Passenger-specific features
export 'passenger/passenger.dart';

// Shared features (both roles)
export 'shared/shared.dart';
```

### Deliverables Checklist
- [ ] `lib/features/shared/` folder created
- [ ] `activity/` moved to `shared/`
- [ ] `home/` moved to `shared/`
- [ ] `loyalty/` moved to `shared/`
- [ ] `notifications/` moved to `shared/`
- [ ] `payment/` moved to `shared/`
- [ ] `queue/` moved to `shared/`
- [ ] `routes/` moved to `shared/`
- [ ] `scan/` moved to `shared/`
- [ ] `settings/` moved to `shared/`
- [ ] `auth/` remains at `lib/features/auth/` (NOT moved)
- [ ] `lib/features/shared/shared.dart` barrel file created
- [ ] `lib/features/features.dart` master barrel file created

### Verification
```bash
# Check final features structure
ls -la lib/features/

# Expected output:
# auth/
# driver/
# passenger/
# shared/
# features.dart

# Check shared contents
ls lib/features/shared/
```

---

## AGENT 4: Extract Shared Navigation Widgets
**Task: Create reusable DriverBottomNav and PassengerBottomNav widgets**

### Prerequisites
- Agent 3 must be complete

### Instructions

#### Step 1: Create navigation widgets folder

```bash
mkdir -p lib/core/widgets/navigation
```

#### Step 2: Extract DriverBottomNav from Musa's screens

Read the bottom navigation code from any driver screen (they're all the same):
```bash
# Check one of Musa's screens for the bottom nav code
cat lib/features/driver/dashboard/presentation/screens/driver_home_screen.dart
```

Create `lib/core/widgets/navigation/driver_bottom_nav.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/route_constants.dart';
import '../../theme/app_colors.dart';

/// Bottom navigation bar for driver screens.
///
/// Provides navigation between the four main driver sections:
/// - Home (Dashboard)
/// - Queue
/// - Trips
/// - Earnings
class DriverBottomNav extends StatelessWidget {
  const DriverBottomNav({
    super.key,
    required this.currentIndex,
  });

  /// The index of the currently selected tab (0-3).
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.queue_outlined),
          activeIcon: Icon(Icons.queue),
          label: 'Queue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car_outlined),
          activeIcon: Icon(Icons.directions_car),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Earnings',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Already on this tab

    switch (index) {
      case 0:
        context.go(RouteConstants.driverHome);
        break;
      case 1:
        context.go(RouteConstants.driverQueue);
        break;
      case 2:
        context.go(RouteConstants.driverTrips);
        break;
      case 3:
        context.go(RouteConstants.driverEarnings);
        break;
    }
  }
}
```

#### Step 3: Create PassengerBottomNav

Create `lib/core/widgets/navigation/passenger_bottom_nav.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/route_constants.dart';
import '../../theme/app_colors.dart';

/// Bottom navigation bar for passenger screens.
///
/// Provides navigation between the four main passenger sections:
/// - Home (Discovery)
/// - Routes
/// - Tickets
/// - Profile
class PassengerBottomNav extends StatelessWidget {
  const PassengerBottomNav({
    super.key,
    required this.currentIndex,
  });

  /// The index of the currently selected tab (0-3).
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route_outlined),
          activeIcon: Icon(Icons.route),
          label: 'Routes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined),
          activeIcon: Icon(Icons.confirmation_number),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Already on this tab

    switch (index) {
      case 0:
        context.go(RouteConstants.passengerHome);
        break;
      case 1:
        context.go(RouteConstants.passengerRoutes);
        break;
      case 2:
        context.go(RouteConstants.passengerTickets);
        break;
      case 3:
        context.go(RouteConstants.sharedProfile);
        break;
    }
  }
}
```

#### Step 4: Create navigation barrel file

Create `lib/core/widgets/navigation/navigation.dart`:
```dart
/// Navigation widgets barrel file.
library;

export 'driver_bottom_nav.dart';
export 'passenger_bottom_nav.dart';
```

#### Step 5: Update core widgets barrel file

Update `lib/core/widgets/widgets.dart` to include navigation:
```dart
// Add this line to the existing exports
export 'navigation/navigation.dart';
```

#### Step 6: Update driver screens to use the new widget

For each driver screen, replace the duplicated `_buildBottomNav` method with the shared widget.

**Example for `driver_home_screen.dart`:**

FIND and REMOVE this code (approximately 40-50 lines of duplicated bottom nav):
```dart
Widget _buildBottomNav(BuildContext context) {
  return BottomNavigationBar(
    currentIndex: 0,
    // ... all the duplicated code
  );
}
```

REPLACE the `bottomNavigationBar` in Scaffold with:
```dart
import '../../../../../core/widgets/navigation/driver_bottom_nav.dart';

// In the Scaffold:
bottomNavigationBar: const DriverBottomNav(currentIndex: 0),
```

Repeat for:
- `queue_screen.dart` → `DriverBottomNav(currentIndex: 1)`
- `driver_trips_screen.dart` → `DriverBottomNav(currentIndex: 2)`
- `earnings_screen.dart` → `DriverBottomNav(currentIndex: 3)`

### Deliverables Checklist
- [ ] `lib/core/widgets/navigation/` folder created
- [ ] `driver_bottom_nav.dart` created with proper documentation
- [ ] `passenger_bottom_nav.dart` created with proper documentation
- [ ] `navigation.dart` barrel file created
- [ ] Core widgets barrel file updated
- [ ] All 4 driver screens updated to use `DriverBottomNav`
- [ ] Duplicated `_buildBottomNav` methods removed from driver screens

### Verification
```bash
# Check files exist
ls lib/core/widgets/navigation/

# Verify no duplicated bottom nav in driver screens
grep -r "_buildBottomNav" lib/features/driver/
# Should return nothing (no matches)

# Verify screens use new widget
grep -r "DriverBottomNav" lib/features/driver/
# Should show all 4 screens using it
```

---

## AGENT 5: Fix Imports & Final Verification
**Task: Update all import paths and verify the build passes**

### Prerequisites
- Agent 4 must be complete

### Instructions

#### Step 1: Run dart fix to auto-fix imports

```bash
dart fix --apply
```

#### Step 2: Update imports in moved files

For each moved feature, imports need to be updated. Key patterns:

**Old imports (WRONG after move):**
```dart
import 'package:komiut/features/booking/...';
import 'package:komiut/features/tickets/...';
import 'package:komiut/features/trips/...';
```

**New imports (CORRECT):**
```dart
import 'package:komiut/features/passenger/booking/...';
import 'package:komiut/features/passenger/tickets/...';
import 'package:komiut/features/passenger/trips/...';
```

**For shared features:**
```dart
// Old
import 'package:komiut/features/settings/...';
import 'package:komiut/features/notifications/...';

// New
import 'package:komiut/features/shared/settings/...';
import 'package:komiut/features/shared/notifications/...';
```

#### Step 3: Update router imports

Update `lib/core/navigation/app_router.dart` or `lib/core/routes/app_router.dart`:

Find all screen imports and update paths:
```dart
// Driver screens
import '../../features/driver/dashboard/presentation/screens/driver_home_screen.dart';
import '../../features/driver/earnings/presentation/screens/earnings_screen.dart';
import '../../features/driver/queue/presentation/screens/queue_screen.dart';
import '../../features/driver/trips/presentation/screens/driver_trips_screen.dart';

// Passenger screens
import '../../features/passenger/booking/presentation/screens/booking_screen.dart';
import '../../features/passenger/tickets/presentation/screens/my_tickets_screen.dart';
import '../../features/passenger/trips/presentation/screens/active_trip_screen.dart';

// Shared screens
import '../../features/shared/settings/presentation/screens/settings_screen.dart';
import '../../features/shared/notifications/presentation/screens/notifications_screen.dart';
```

#### Step 4: Update main.dart imports (if needed)

Check `lib/main.dart` for any feature imports and update them.

#### Step 5: Update any remaining hardcoded paths

Search for old paths and fix them:
```bash
# Find files still using old paths
grep -r "features/booking/" lib/ --include="*.dart"
grep -r "features/tickets/" lib/ --include="*.dart"
grep -r "features/trips/" lib/ --include="*.dart"
grep -r "features/settings/" lib/ --include="*.dart"
grep -r "features/notifications/" lib/ --include="*.dart"
grep -r "features/home/" lib/ --include="*.dart"
grep -r "features/activity/" lib/ --include="*.dart"
grep -r "features/loyalty/" lib/ --include="*.dart"
grep -r "features/payment/" lib/ --include="*.dart"
grep -r "features/queue/" lib/ --include="*.dart"
grep -r "features/routes/" lib/ --include="*.dart"
grep -r "features/scan/" lib/ --include="*.dart"
grep -r "lib/driver/" lib/ --include="*.dart"
```

Fix each file found.

#### Step 6: Run flutter analyze

```bash
flutter analyze
```

Fix any errors (warnings are OK for now).

#### Step 7: Run flutter pub get

```bash
flutter pub get
```

#### Step 8: Attempt to build

```bash
flutter build apk --debug
```

If build fails, fix the errors.

#### Step 9: Format code

```bash
dart format lib/
```

#### Step 10: Commit all changes

```bash
git add .
git commit -m "$(cat <<'EOF'
refactor: Phase 1 - Reorganize folder structure

- Delete lib/driver/ (BLoC-based, replaced with Riverpod structure)
- Restructure lib/features/driver/ with clean architecture folders
- Move passenger features under lib/features/passenger/
- Move shared features under lib/features/shared/
- Extract DriverBottomNav and PassengerBottomNav widgets
- Update all import paths
- Create barrel files for features

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Deliverables Checklist
- [ ] `dart fix --apply` completed
- [ ] All moved files have updated imports
- [ ] Router file imports updated
- [ ] main.dart imports updated (if needed)
- [ ] No grep results for old paths
- [ ] `flutter analyze` shows 0 errors (warnings OK)
- [ ] `flutter pub get` succeeds
- [ ] `flutter build apk --debug` succeeds
- [ ] Code formatted with `dart format`
- [ ] Changes committed to git

### Final Verification

Run this checklist to confirm Phase 1 is complete:

```bash
echo "=== Phase 1 Verification ==="

echo "\n1. Checking lib/driver/ is deleted..."
[ ! -d "lib/driver" ] && echo "✓ PASS" || echo "✗ FAIL"

echo "\n2. Checking driver structure..."
[ -d "lib/features/driver/dashboard/presentation/screens" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -d "lib/features/driver/earnings/presentation/screens" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -d "lib/features/driver/queue/presentation/screens" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -d "lib/features/driver/trips/presentation/screens" ] && echo "✓ PASS" || echo "✗ FAIL"

echo "\n3. Checking passenger structure..."
[ -d "lib/features/passenger/booking" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -d "lib/features/passenger/discovery" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -d "lib/features/passenger/tickets" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -d "lib/features/passenger/trips" ] && echo "✓ PASS" || echo "✗ FAIL"

echo "\n4. Checking shared structure..."
[ -d "lib/features/shared/settings" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -d "lib/features/shared/notifications" ] && echo "✓ PASS" || echo "✗ FAIL"

echo "\n5. Checking navigation widgets..."
[ -f "lib/core/widgets/navigation/driver_bottom_nav.dart" ] && echo "✓ PASS" || echo "✗ FAIL"
[ -f "lib/core/widgets/navigation/passenger_bottom_nav.dart" ] && echo "✓ PASS" || echo "✗ FAIL"

echo "\n6. Running flutter analyze..."
flutter analyze 2>&1 | grep -E "error|No issues found"

echo "\n=== Phase 1 Complete ==="
```

---

## Summary Table

| Agent | Task | Depends On | Key Deliverables |
|-------|------|------------|------------------|
| **1** | Driver Structure | None | Delete lib/driver/, create new folders, move screens |
| **2** | Passenger Structure | Agent 1 | Move booking/tickets/trips under passenger/ |
| **3** | Shared Structure | Agent 2 | Move 9 features to shared/, create barrel files |
| **4** | Navigation Widgets | Agent 3 | Create DriverBottomNav, PassengerBottomNav |
| **5** | Import Fixes | Agent 4 | Fix all imports, verify build passes |

**Estimated Total Time:** Each agent task can be done separately. Run sequentially.

**After Phase 1 Complete:** Create PR, review, merge, then proceed to Phase 2 (Domain Layer).
