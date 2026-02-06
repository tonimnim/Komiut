/// Vehicle State Controls - State toggle buttons for vehicle operation.
///
/// Provides a set of toggle buttons for changing vehicle state:
/// Loading, Full, or Depart.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/cards/app_card.dart';

/// Enum representing the vehicle's operational state.
enum VehicleState {
  /// Vehicle is loading passengers at a stop.
  loading,

  /// Vehicle is full and ready to depart.
  full,

  /// Vehicle is departing/in transit.
  depart;

  /// Display label for the state.
  String get label => switch (this) {
        VehicleState.loading => 'Loading',
        VehicleState.full => 'Full',
        VehicleState.depart => 'DEPART',
      };

  /// Icon for the state.
  IconData get icon => switch (this) {
        VehicleState.loading => Icons.hourglass_empty,
        VehicleState.full => Icons.people,
        VehicleState.depart => Icons.directions_bus,
      };
}

/// A widget that displays vehicle state control buttons.
///
/// Shows three toggle buttons:
/// - Loading: Vehicle is accepting passengers
/// - Full: Vehicle is at capacity
/// - Depart: Vehicle is departing
class VehicleStateControls extends StatelessWidget {
  /// Creates a VehicleStateControls widget.
  const VehicleStateControls({
    super.key,
    required this.currentState,
    required this.onStateChanged,
    this.isEnabled = true,
  });

  /// The currently active state.
  final VehicleState currentState;

  /// Callback when state is changed.
  final ValueChanged<VehicleState> onStateChanged;

  /// Whether the controls are enabled.
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: VehicleState.values.map((state) {
          final isActive = currentState == state;
          final isLast = state == VehicleState.values.last;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: isLast ? 0 : AppSpacing.sm,
              ),
              child: _StateButton(
                state: state,
                isActive: isActive,
                isEnabled: isEnabled,
                onTap: () {
                  if (isEnabled && !isActive) {
                    onStateChanged(state);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Individual state toggle button.
class _StateButton extends StatelessWidget {
  const _StateButton({
    required this.state,
    required this.isActive,
    required this.isEnabled,
    required this.onTap,
  });

  final VehicleState state;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDepart = state == VehicleState.depart;

    // Colors based on state
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isActive) {
      if (isDepart) {
        backgroundColor = AppColors.primaryGreen;
        textColor = AppColors.white;
        borderColor = AppColors.primaryGreen;
      } else {
        backgroundColor = AppColors.primaryBlue;
        textColor = AppColors.white;
        borderColor = AppColors.primaryBlue;
      }
    } else {
      backgroundColor = AppColors.white;
      textColor = isEnabled ? AppColors.textPrimary : AppColors.textMuted;
      borderColor = AppColors.border;
    }

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: borderColor,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDepart ? AppColors.primaryGreen : AppColors.primaryBlue)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radio indicator
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.white : AppColors.transparent,
                border: Border.all(
                  color: isActive
                      ? AppColors.white
                      : isEnabled
                          ? AppColors.grey400
                          : AppColors.grey300,
                  width: 2,
                ),
              ),
              child: isActive
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDepart
                              ? AppColors.primaryGreen
                              : AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            // Label
            Text(
              state.label,
              style: TextStyle(
                fontSize: isDepart ? 14 : 13,
                fontWeight: isActive || isDepart
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: textColor,
                letterSpacing: isDepart ? 0.5 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version of vehicle state controls.
///
/// Uses smaller buttons suitable for inline display.
class VehicleStateControlsCompact extends StatelessWidget {
  /// Creates a VehicleStateControlsCompact widget.
  const VehicleStateControlsCompact({
    super.key,
    required this.currentState,
    required this.onStateChanged,
    this.isEnabled = true,
  });

  /// The currently active state.
  final VehicleState currentState;

  /// Callback when state is changed.
  final ValueChanged<VehicleState> onStateChanged;

  /// Whether the controls are enabled.
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: VehicleState.values.map((state) {
          final isActive = currentState == state;

          return GestureDetector(
            onTap: isEnabled && !isActive
                ? () => onStateChanged(state)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.white : AppColors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                state.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Single action button for quick state change.
///
/// Use when only one action needs to be prominently displayed.
class VehicleDepartButton extends StatelessWidget {
  /// Creates a VehicleDepartButton.
  const VehicleDepartButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  /// Callback when the button is pressed.
  final VoidCallback onPressed;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// Whether to show loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isEnabled && !isLoading
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryGreen, Color(0xFF059669)],
                )
              : null,
          color: isEnabled && !isLoading ? null : AppColors.grey300,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          boxShadow: isEnabled && !isLoading
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ] else ...[
              const Icon(
                Icons.directions_bus,
                size: 20,
                color: AppColors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              isLoading ? 'DEPARTING...' : 'DEPART',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isEnabled ? AppColors.white : AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
