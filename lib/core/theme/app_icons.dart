import 'package:flutter/material.dart';

/// Centralized icon registry for the app.
///
/// Using a class for icons makes it easier to change icons app-wide
/// and provides better auto-completion.
class AppIcons {
  // Navigation Icons
  static const IconData home = Icons.home_rounded;
  static const IconData homeOutlined = Icons.home_outlined;

  static const IconData queue = Icons.queue_rounded;
  static const IconData queueOutlined =
      Icons.queue_rounded; // Usually has plus in both

  static const IconData trips = Icons.directions_bus_rounded;
  static const IconData tripsOutlined = Icons.directions_bus_outlined;

  static const IconData earnings = Icons.account_balance_wallet_rounded;
  static const IconData earningsOutlined =
      Icons.account_balance_wallet_outlined;

  // Action Icons
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData profile = Icons.person_rounded;
  static const IconData leave = Icons.exit_to_app_rounded;
}
