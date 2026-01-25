# Komiut

A public transport app for booking bus rides and managing payments. Built with Flutter.

## Getting Started

```bash
flutter pub get
flutter run
```

## Test Account

- **Email:** eric@komiut.com
- **Password:** Password123
- **OTP:** 123456 (only needed for signup)

## What's in the app

- Login / Signup with 2FA
- Browse bus routes and book trips
- Digital wallet with top-up
- QR scanner for payments
- Trip history
- Profile editing with photo upload
- Dark mode

## Tech

- Flutter + Riverpod for state
- Drift (SQLite) for local storage
- Go Router for navigation
- Clean architecture setup

## Project Structure

```
lib/
├── core/           # Shared stuff (theme, db, widgets, utils)
├── features/       # Feature modules
│   ├── auth/       # Login, signup, 2FA
│   ├── home/       # Dashboard
│   ├── routes/     # Bus routes & booking
│   ├── payment/    # Wallet & transactions
│   ├── activity/   # Trip history
│   ├── scan/       # QR scanner
│   ├── notifications/
│   └── settings/   # Profile & preferences
└── main.dart
```

## Tests

```bash
flutter test
```

71 tests covering validators, fare calculation, and trip entities.
