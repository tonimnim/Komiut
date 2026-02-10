/// State-based activity content for driver home.
///
/// Shows different content based on driver's current state:
/// - Idle: Wallet card with transactions
/// - On Trip: Trip progress with route visualization
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../providers/driver_state_provider.dart';
import 'idle_state_content.dart';

/// State-based content that changes based on driver's current activity.
class DriverActivityContent extends ConsumerWidget {
  const DriverActivityContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateData = ref.watch(driverStateProvider);

    return switch (stateData.state) {
      DriverState.loading => const _LoadingState(),
      DriverState.idle => IdleStateContent(isOnline: stateData.isOnline),
      DriverState.inQueue => IdleStateContent(isOnline: stateData.isOnline),
      // User request: "REMOVE THE ONTRIP SHOWING IN HOME SCREEN" and show transactions instead.
      // So we reuse IdleStateContent (which shows transactions) even when on trip.
      DriverState.onTrip => IdleStateContent(isOnline: stateData.isOnline),
    };
  }
}

/// Loading state.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            ShimmerBox(height: 100, width: 100, borderRadius: 50),
            SizedBox(height: 24),
            ShimmerBox(height: 24, width: 150),
            SizedBox(height: 8),
            ShimmerBox(height: 16, width: 200),
          ],
        ),
      ),
    );
  }
}
