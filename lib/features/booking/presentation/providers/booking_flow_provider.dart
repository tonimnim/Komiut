/// Booking flow provider for managing the enhanced booking process.
///
/// Manages the multi-step booking flow from route selection through
/// to payment and confirmation.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../queue/domain/entities/queue_vehicle.dart';
import '../../../routes/domain/entities/route_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Booking Flow Step Enum
// ─────────────────────────────────────────────────────────────────────────────

/// Steps in the booking flow.
enum BookingFlowStep {
  /// Choose route (already done in routes screen).
  selectRoute,

  /// Choose pickup/dropoff stops.
  selectStops,

  /// Choose from queue vehicles.
  selectVehicle,

  /// Optional seat selection.
  selectSeats,

  /// Review booking details.
  reviewBooking,

  /// Payment step.
  payment,

  /// Booking confirmed.
  confirmation,
}

/// Extension methods for [BookingFlowStep].
extension BookingFlowStepX on BookingFlowStep {
  /// Display label for the step.
  String get label {
    switch (this) {
      case BookingFlowStep.selectRoute:
        return 'Select Route';
      case BookingFlowStep.selectStops:
        return 'Select Stops';
      case BookingFlowStep.selectVehicle:
        return 'Select Vehicle';
      case BookingFlowStep.selectSeats:
        return 'Select Seats';
      case BookingFlowStep.reviewBooking:
        return 'Review';
      case BookingFlowStep.payment:
        return 'Payment';
      case BookingFlowStep.confirmation:
        return 'Confirmed';
    }
  }

  /// Step number (1-indexed).
  int get stepNumber {
    switch (this) {
      case BookingFlowStep.selectRoute:
        return 1;
      case BookingFlowStep.selectStops:
        return 2;
      case BookingFlowStep.selectVehicle:
        return 3;
      case BookingFlowStep.selectSeats:
        return 4;
      case BookingFlowStep.reviewBooking:
        return 5;
      case BookingFlowStep.payment:
        return 6;
      case BookingFlowStep.confirmation:
        return 7;
    }
  }

  /// Whether this step can be skipped.
  bool get isOptional => this == BookingFlowStep.selectSeats;

  /// Whether this step has been completed.
  bool isCompletedIn(BookingFlowStep currentStep) {
    return stepNumber < currentStep.stepNumber;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seat Type Enum
// ─────────────────────────────────────────────────────────────────────────────

/// Types of seats in a vehicle.
enum SeatType {
  /// Regular seat.
  regular,

  /// Window seat.
  window,

  /// Aisle seat.
  aisle,

  /// Front row seat.
  front,

  /// Back row seat.
  back,

  /// Driver seat (not selectable).
  driver,

  /// Empty space (not a seat).
  empty,
}

/// Extension methods for [SeatType].
extension SeatTypeX on SeatType {
  /// Display label.
  String get label {
    switch (this) {
      case SeatType.regular:
        return 'Regular';
      case SeatType.window:
        return 'Window';
      case SeatType.aisle:
        return 'Aisle';
      case SeatType.front:
        return 'Front';
      case SeatType.back:
        return 'Back';
      case SeatType.driver:
        return 'Driver';
      case SeatType.empty:
        return '';
    }
  }

  /// Whether this seat can be selected by passengers.
  bool get isSelectable =>
      this != SeatType.driver && this != SeatType.empty;
}

// ─────────────────────────────────────────────────────────────────────────────
// Seat Entity
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a seat in a vehicle.
class Seat {
  /// Creates a new Seat.
  const Seat({
    required this.seatNumber,
    required this.row,
    required this.column,
    required this.type,
    this.isAvailable = true,
    this.isSelected = false,
    this.price,
  });

  /// Unique seat number.
  final int seatNumber;

  /// Row index (0-based).
  final int row;

  /// Column index (0-based).
  final int column;

  /// Type of seat.
  final SeatType type;

  /// Whether the seat is available for booking.
  final bool isAvailable;

  /// Whether the seat is currently selected.
  final bool isSelected;

  /// Optional price modifier for premium seats.
  final double? price;

  /// Whether this seat can be selected.
  bool get canSelect => type.isSelectable && isAvailable && !isSelected;

  /// Creates a copy with modified fields.
  Seat copyWith({
    int? seatNumber,
    int? row,
    int? column,
    SeatType? type,
    bool? isAvailable,
    bool? isSelected,
    double? price,
  }) {
    return Seat(
      seatNumber: seatNumber ?? this.seatNumber,
      row: row ?? this.row,
      column: column ?? this.column,
      type: type ?? this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      isSelected: isSelected ?? this.isSelected,
      price: price ?? this.price,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Flow State
// ─────────────────────────────────────────────────────────────────────────────

/// State class for the booking flow.
class BookingFlowState {
  /// Creates a new BookingFlowState.
  const BookingFlowState({
    this.currentStep = BookingFlowStep.selectStops,
    this.selectedRoute,
    this.pickupStopId,
    this.pickupStopIndex,
    this.dropoffStopId,
    this.dropoffStopIndex,
    this.selectedVehicle,
    this.selectedSeats,
    this.passengerCount = 1,
    this.calculatedFare = 0,
    this.bookingId,
    this.error,
    this.isLoading = false,
    this.seatMap,
  });

  /// Current step in the booking flow.
  final BookingFlowStep currentStep;

  /// Selected route for the booking.
  final RouteEntity? selectedRoute;

  /// ID of the pickup stop.
  final String? pickupStopId;

  /// Index of the pickup stop in the route's stops list.
  final int? pickupStopIndex;

  /// ID of the dropoff stop.
  final String? dropoffStopId;

  /// Index of the dropoff stop in the route's stops list.
  final int? dropoffStopIndex;

  /// Selected vehicle from the queue.
  final QueueVehicle? selectedVehicle;

  /// List of selected seat numbers.
  final List<int>? selectedSeats;

  /// Number of passengers.
  final int passengerCount;

  /// Calculated fare for the journey.
  final double calculatedFare;

  /// Booking ID after successful booking.
  final String? bookingId;

  /// Error message if any.
  final String? error;

  /// Whether loading is in progress.
  final bool isLoading;

  /// Seat map for the selected vehicle.
  final List<List<Seat>>? seatMap;

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether stops selection is valid.
  bool get hasValidStops =>
      pickupStopIndex != null &&
      dropoffStopIndex != null &&
      pickupStopIndex! < dropoffStopIndex!;

  /// Whether a vehicle is selected.
  bool get hasVehicle => selectedVehicle != null;

  /// Whether seats are selected (if required).
  bool get hasSeats =>
      selectedSeats != null && selectedSeats!.length == passengerCount;

  /// Whether the booking is ready for review.
  bool get isReadyForReview =>
      selectedRoute != null && hasValidStops && hasVehicle;

  /// Whether the booking is complete.
  bool get isComplete =>
      currentStep == BookingFlowStep.confirmation && bookingId != null;

  /// Number of stops to travel.
  int get stopsToTravel {
    if (pickupStopIndex == null || dropoffStopIndex == null) return 0;
    return dropoffStopIndex! - pickupStopIndex!;
  }

  /// Pickup stop name.
  String? get pickupStopName {
    if (selectedRoute == null || pickupStopIndex == null) return null;
    if (pickupStopIndex! >= selectedRoute!.stops.length) return null;
    return selectedRoute!.stops[pickupStopIndex!];
  }

  /// Dropoff stop name.
  String? get dropoffStopName {
    if (selectedRoute == null || dropoffStopIndex == null) return null;
    if (dropoffStopIndex! >= selectedRoute!.stops.length) return null;
    return selectedRoute!.stops[dropoffStopIndex!];
  }

  /// Total fare for all passengers.
  double get totalFare => calculatedFare * passengerCount;

  /// Formatted total fare.
  String get formattedTotalFare {
    if (selectedRoute == null) return '---';
    return selectedRoute!.formatFare(totalFare);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Copy With
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a copy with modified fields.
  BookingFlowState copyWith({
    BookingFlowStep? currentStep,
    RouteEntity? selectedRoute,
    String? pickupStopId,
    int? pickupStopIndex,
    String? dropoffStopId,
    int? dropoffStopIndex,
    QueueVehicle? selectedVehicle,
    List<int>? selectedSeats,
    int? passengerCount,
    double? calculatedFare,
    String? bookingId,
    String? error,
    bool? isLoading,
    List<List<Seat>>? seatMap,
    bool clearError = false,
    bool clearVehicle = false,
    bool clearSeats = false,
    bool clearBookingId = false,
  }) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      pickupStopId: pickupStopId ?? this.pickupStopId,
      pickupStopIndex: pickupStopIndex ?? this.pickupStopIndex,
      dropoffStopId: dropoffStopId ?? this.dropoffStopId,
      dropoffStopIndex: dropoffStopIndex ?? this.dropoffStopIndex,
      selectedVehicle:
          clearVehicle ? null : (selectedVehicle ?? this.selectedVehicle),
      selectedSeats: clearSeats ? null : (selectedSeats ?? this.selectedSeats),
      passengerCount: passengerCount ?? this.passengerCount,
      calculatedFare: calculatedFare ?? this.calculatedFare,
      bookingId: clearBookingId ? null : (bookingId ?? this.bookingId),
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      seatMap: seatMap ?? this.seatMap,
    );
  }

  /// Creates an initial state with the selected route.
  factory BookingFlowState.withRoute(RouteEntity route) {
    return BookingFlowState(
      currentStep: BookingFlowStep.selectStops,
      selectedRoute: route,
    );
  }

  /// Creates an empty/reset state.
  factory BookingFlowState.initial() {
    return const BookingFlowState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Flow Controller
// ─────────────────────────────────────────────────────────────────────────────

/// Controller for managing the booking flow state.
class BookingFlowController extends StateNotifier<BookingFlowState> {
  /// Creates a new BookingFlowController.
  BookingFlowController() : super(BookingFlowState.initial());

  // ─────────────────────────────────────────────────────────────────────────
  // Route Selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Sets the selected route and moves to stops selection.
  void selectRoute(RouteEntity route) {
    state = BookingFlowState.withRoute(route);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stops Selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Selects the pickup stop.
  void selectPickupStop(int index, {String? stopId}) {
    // Clear dropoff if it's before or equal to the new pickup
    int? newDropoffIndex = state.dropoffStopIndex;
    String? newDropoffId = state.dropoffStopId;
    if (newDropoffIndex != null && newDropoffIndex <= index) {
      newDropoffIndex = null;
      newDropoffId = null;
    }

    state = state.copyWith(
      pickupStopIndex: index,
      pickupStopId: stopId,
      dropoffStopIndex: newDropoffIndex,
      dropoffStopId: newDropoffId,
      clearError: true,
    );
    _calculateFare();
  }

  /// Selects the dropoff stop.
  void selectDropoffStop(int index, {String? stopId}) {
    if (state.pickupStopIndex != null && index <= state.pickupStopIndex!) {
      state = state.copyWith(
        error: 'Dropoff must be after pickup stop',
      );
      return;
    }

    state = state.copyWith(
      dropoffStopIndex: index,
      dropoffStopId: stopId,
      clearError: true,
    );
    _calculateFare();
  }

  /// Selects both pickup and dropoff stops.
  void selectStops({
    required int pickupIndex,
    required int dropoffIndex,
    String? pickupStopId,
    String? dropoffStopId,
  }) {
    if (dropoffIndex <= pickupIndex) {
      state = state.copyWith(
        error: 'Dropoff must be after pickup stop',
      );
      return;
    }

    state = state.copyWith(
      pickupStopIndex: pickupIndex,
      pickupStopId: pickupStopId,
      dropoffStopIndex: dropoffIndex,
      dropoffStopId: dropoffStopId,
      clearError: true,
    );
    _calculateFare();
  }

  /// Confirms stops selection and moves to vehicle selection.
  void confirmStops() {
    if (!state.hasValidStops) {
      state = state.copyWith(
        error: 'Please select valid pickup and dropoff stops',
      );
      return;
    }

    state = state.copyWith(
      currentStep: BookingFlowStep.selectVehicle,
      clearError: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Vehicle Selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Selects a vehicle from the queue.
  void selectVehicle(QueueVehicle vehicle) {
    if (!vehicle.hasSeats) {
      state = state.copyWith(
        error: 'This vehicle has no available seats',
      );
      return;
    }

    if (vehicle.availableSeats < state.passengerCount) {
      state = state.copyWith(
        error: 'Not enough seats for ${state.passengerCount} passengers',
      );
      return;
    }

    // Generate seat map for the vehicle
    final seatMap = _generateSeatMap(vehicle);

    state = state.copyWith(
      selectedVehicle: vehicle,
      seatMap: seatMap,
      clearSeats: true, // Clear previously selected seats
      clearError: true,
    );
  }

  /// Confirms vehicle selection and moves to seat selection or review.
  void confirmVehicle({bool skipSeatSelection = false}) {
    if (!state.hasVehicle) {
      state = state.copyWith(
        error: 'Please select a vehicle',
      );
      return;
    }

    if (skipSeatSelection) {
      state = state.copyWith(
        currentStep: BookingFlowStep.reviewBooking,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        currentStep: BookingFlowStep.selectSeats,
        clearError: true,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Seat Selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Toggles seat selection.
  void toggleSeat(int seatNumber) {
    if (state.seatMap == null) return;

    final currentSeats = List<int>.from(state.selectedSeats ?? []);

    if (currentSeats.contains(seatNumber)) {
      // Deselect
      currentSeats.remove(seatNumber);
    } else {
      // Check if we can select more
      if (currentSeats.length >= state.passengerCount) {
        state = state.copyWith(
          error: 'Maximum ${state.passengerCount} seats can be selected',
        );
        return;
      }

      // Check if seat is available
      bool isAvailable = false;
      for (final row in state.seatMap!) {
        for (final seat in row) {
          if (seat.seatNumber == seatNumber && seat.canSelect) {
            isAvailable = true;
            break;
          }
        }
      }

      if (!isAvailable) {
        state = state.copyWith(error: 'This seat is not available');
        return;
      }

      currentSeats.add(seatNumber);
    }

    // Update seat map with selection state
    final updatedSeatMap = state.seatMap!.map((row) {
      return row.map((seat) {
        return seat.copyWith(
          isSelected: currentSeats.contains(seat.seatNumber),
        );
      }).toList();
    }).toList();

    state = state.copyWith(
      selectedSeats: currentSeats,
      seatMap: updatedSeatMap,
      clearError: true,
    );
  }

  /// Selects multiple seats at once.
  void selectSeats(List<int> seatNumbers) {
    if (seatNumbers.length > state.passengerCount) {
      state = state.copyWith(
        error: 'Maximum ${state.passengerCount} seats can be selected',
      );
      return;
    }

    state = state.copyWith(
      selectedSeats: seatNumbers,
      clearError: true,
    );
  }

  /// Confirms seat selection and moves to review.
  void confirmSeats() {
    // Seats are optional, so we can proceed without them
    state = state.copyWith(
      currentStep: BookingFlowStep.reviewBooking,
      clearError: true,
    );
  }

  /// Skips seat selection and moves to review.
  void skipSeatSelection() {
    state = state.copyWith(
      currentStep: BookingFlowStep.reviewBooking,
      clearSeats: true,
      clearError: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Passenger Count
  // ─────────────────────────────────────────────────────────────────────────

  /// Updates the passenger count.
  void updatePassengerCount(int count) {
    if (count < 1) {
      state = state.copyWith(error: 'At least 1 passenger is required');
      return;
    }

    // Check if vehicle has enough seats
    if (state.selectedVehicle != null &&
        count > state.selectedVehicle!.availableSeats) {
      state = state.copyWith(
        error: 'Only ${state.selectedVehicle!.availableSeats} seats available',
      );
      return;
    }

    // Clear selected seats if count changes
    state = state.copyWith(
      passengerCount: count,
      clearSeats: true,
      clearError: true,
    );
    _calculateFare();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fare Calculation
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates the fare based on selected stops.
  void _calculateFare() {
    if (state.selectedRoute == null ||
        state.pickupStopIndex == null ||
        state.dropoffStopIndex == null) {
      return;
    }

    final fare = state.selectedRoute!.calculateFare(
      state.pickupStopIndex!,
      state.dropoffStopIndex!,
    );

    state = state.copyWith(calculatedFare: fare);
  }

  /// Gets the fare for specific stops (for preview).
  double calculateFareForStops(int pickupIndex, int dropoffIndex) {
    if (state.selectedRoute == null) return 0;
    return state.selectedRoute!.calculateFare(pickupIndex, dropoffIndex);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Review & Booking
  // ─────────────────────────────────────────────────────────────────────────

  /// Moves to payment step.
  void proceedToPayment() {
    if (!state.isReadyForReview) {
      state = state.copyWith(
        error: 'Please complete all required steps',
      );
      return;
    }

    state = state.copyWith(
      currentStep: BookingFlowStep.payment,
      clearError: true,
    );
  }

  /// Creates the booking (called after payment success).
  Future<void> createBooking() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Simulate booking creation
      // In real implementation, this would call an API
      await Future.delayed(const Duration(seconds: 1));

      final bookingId = 'BK-${DateTime.now().millisecondsSinceEpoch}';

      state = state.copyWith(
        currentStep: BookingFlowStep.confirmation,
        bookingId: bookingId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create booking: $e',
        isLoading: false,
      );
    }
  }

  /// Sets booking as confirmed with the given booking ID.
  void confirmBooking(String bookingId) {
    state = state.copyWith(
      currentStep: BookingFlowStep.confirmation,
      bookingId: bookingId,
      isLoading: false,
      clearError: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────────────────────

  /// Goes back to the previous step.
  void goBack() {
    final previousStep = _getPreviousStep(state.currentStep);
    if (previousStep != null) {
      state = state.copyWith(
        currentStep: previousStep,
        clearError: true,
      );
    }
  }

  /// Goes to a specific step.
  void goToStep(BookingFlowStep step) {
    // Only allow going to completed or current steps
    if (step.stepNumber > state.currentStep.stepNumber) {
      return;
    }

    state = state.copyWith(
      currentStep: step,
      clearError: true,
    );
  }

  /// Gets the previous step.
  BookingFlowStep? _getPreviousStep(BookingFlowStep step) {
    switch (step) {
      case BookingFlowStep.selectRoute:
        return null;
      case BookingFlowStep.selectStops:
        return BookingFlowStep.selectRoute;
      case BookingFlowStep.selectVehicle:
        return BookingFlowStep.selectStops;
      case BookingFlowStep.selectSeats:
        return BookingFlowStep.selectVehicle;
      case BookingFlowStep.reviewBooking:
        // Skip back to vehicle or seats depending on what was used
        if (state.selectedSeats != null && state.selectedSeats!.isNotEmpty) {
          return BookingFlowStep.selectSeats;
        }
        return BookingFlowStep.selectVehicle;
      case BookingFlowStep.payment:
        return BookingFlowStep.reviewBooking;
      case BookingFlowStep.confirmation:
        return null; // Can't go back from confirmation
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reset
  // ─────────────────────────────────────────────────────────────────────────

  /// Resets the entire booking flow.
  void reset() {
    state = BookingFlowState.initial();
  }

  /// Resets and starts with a new route.
  void resetWithRoute(RouteEntity route) {
    state = BookingFlowState.withRoute(route);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Error Handling
  // ─────────────────────────────────────────────────────────────────────────

  /// Clears the current error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Sets an error message.
  void setError(String message) {
    state = state.copyWith(error: message);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a seat map for a vehicle.
  List<List<Seat>> _generateSeatMap(QueueVehicle vehicle) {
    // Standard matatu layout: 4 columns (2 + aisle + 2)
    // Typical 14-seater: 4 rows of 3 seats + 2 front seats
    final totalSeats = vehicle.totalSeats;
    final availableSeats = vehicle.availableSeats;
    final occupiedCount = totalSeats - availableSeats;

    // Generate a typical matatu layout
    final seatMap = <List<Seat>>[];
    var seatNumber = 1;
    var occupiedSoFar = 0;

    // Calculate rows based on total seats (assuming 3 seats per row + driver row)
    final dataRows = (totalSeats / 3).ceil();

    // Driver row
    seatMap.add([
      const Seat(
        seatNumber: 0,
        row: 0,
        column: 0,
        type: SeatType.driver,
        isAvailable: false,
      ),
      const Seat(
        seatNumber: -1,
        row: 0,
        column: 1,
        type: SeatType.empty,
        isAvailable: false,
      ),
      Seat(
        seatNumber: seatNumber++,
        row: 0,
        column: 2,
        type: SeatType.front,
        isAvailable: occupiedSoFar++ < (totalSeats - availableSeats) ? false : true,
      ),
    ]);

    // Passenger rows
    for (var row = 1; row <= dataRows; row++) {
      final rowSeats = <Seat>[];
      final isLastRow = row == dataRows;

      for (var col = 0; col < 3; col++) {
        if (seatNumber > totalSeats) {
          // Add empty seat if we've exceeded total
          rowSeats.add(Seat(
            seatNumber: -1,
            row: row,
            column: col,
            type: SeatType.empty,
            isAvailable: false,
          ));
        } else {
          final type = col == 0
              ? SeatType.window
              : col == 2
                  ? SeatType.window
                  : (isLastRow ? SeatType.back : SeatType.aisle);

          // Randomly mark some seats as occupied
          final isOccupied = occupiedSoFar < occupiedCount;
          if (isOccupied) occupiedSoFar++;

          rowSeats.add(Seat(
            seatNumber: seatNumber++,
            row: row,
            column: col,
            type: type,
            isAvailable: !isOccupied,
          ));
        }
      }

      seatMap.add(rowSeats);
    }

    return seatMap;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the booking flow controller.
final bookingFlowProvider =
    StateNotifierProvider<BookingFlowController, BookingFlowState>((ref) {
  return BookingFlowController();
});

/// Provider for checking if stops selection is valid.
final hasValidStopsProvider = Provider<bool>((ref) {
  final state = ref.watch(bookingFlowProvider);
  return state.hasValidStops;
});

/// Provider for the calculated fare.
final bookingFareProvider = Provider<double>((ref) {
  final state = ref.watch(bookingFlowProvider);
  return state.totalFare;
});

/// Provider for the formatted fare.
final formattedBookingFareProvider = Provider<String>((ref) {
  final state = ref.watch(bookingFlowProvider);
  return state.formattedTotalFare;
});

/// Provider for the current booking step.
final currentBookingStepProvider = Provider<BookingFlowStep>((ref) {
  final state = ref.watch(bookingFlowProvider);
  return state.currentStep;
});

/// Provider for booking error messages.
final bookingErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(bookingFlowProvider);
  return state.error;
});

/// Provider for booking loading state.
final bookingLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(bookingFlowProvider);
  return state.isLoading;
});
