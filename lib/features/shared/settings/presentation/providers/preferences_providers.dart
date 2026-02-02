/// Preferences providers for passenger settings.
///
/// Provides Riverpod providers for managing passenger preferences,
/// saved routes, saved Saccos, and saved payment methods.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/preferences_repository.dart';
import '../../domain/entities/passenger_preferences.dart';
import '../../domain/entities/saved_route.dart';
import '../../domain/entities/saved_sacco.dart';
import '../../domain/entities/saved_payment_method.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Preferences Providers
// ─────────────────────────────────────────────────────────────────────────────

/// State for passenger preferences.
class PassengerPreferencesState {
  const PassengerPreferencesState({
    required this.preferences,
    this.isLoading = false,
    this.error,
  });

  final PassengerPreferences preferences;
  final bool isLoading;
  final String? error;

  PassengerPreferencesState copyWith({
    PassengerPreferences? preferences,
    bool? isLoading,
    String? error,
  }) {
    return PassengerPreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing passenger preferences.
class PassengerPreferencesNotifier
    extends StateNotifier<PassengerPreferencesState> {
  PassengerPreferencesNotifier(this._repository)
      : super(const PassengerPreferencesState(
          preferences: PassengerPreferences(),
          isLoading: true,
        )) {
    _loadPreferences();
  }

  final PreferencesRepository _repository;

  /// Loads preferences from storage.
  Future<void> _loadPreferences() async {
    try {
      final preferences = await _repository.getPreferences();
      state = state.copyWith(preferences: preferences, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load preferences: $e',
      );
    }
  }

  /// Sets the default payment method.
  Future<void> setDefaultPaymentMethod(PaymentMethod method) async {
    try {
      await _repository.setDefaultPaymentMethod(method);
      state = state.copyWith(
        preferences: state.preferences.copyWith(defaultPaymentMethod: method),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update payment method: $e');
    }
  }

  /// Updates a specific notification setting.
  Future<void> updateNotificationSetting({
    bool? tripUpdates,
    bool? promotions,
    bool? queueAlerts,
    bool? paymentReceipts,
    bool? destinationAlerts,
  }) async {
    try {
      final updated = state.preferences.notifications.copyWith(
        tripUpdates: tripUpdates,
        promotions: promotions,
        queueAlerts: queueAlerts,
        paymentReceipts: paymentReceipts,
        destinationAlerts: destinationAlerts,
      );
      await _repository.updateNotificationPreferences(updated);
      state = state.copyWith(
        preferences: state.preferences.copyWith(notifications: updated),
      );
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to update notification settings: $e');
    }
  }

  /// Updates a specific accessibility option.
  Future<void> updateAccessibilityOption({
    bool? largeText,
    bool? highContrast,
    bool? screenReaderOptimized,
    bool? reducedMotion,
  }) async {
    try {
      final updated = state.preferences.accessibility.copyWith(
        largeText: largeText,
        highContrast: highContrast,
        screenReaderOptimized: screenReaderOptimized,
        reducedMotion: reducedMotion,
      );
      await _repository.updateAccessibilityOptions(updated);
      state = state.copyWith(
        preferences: state.preferences.copyWith(accessibility: updated),
      );
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to update accessibility options: $e');
    }
  }

  /// Clears any error state.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for passenger preferences.
final passengerPreferencesProvider = StateNotifierProvider<
    PassengerPreferencesNotifier, PassengerPreferencesState>(
  (ref) {
    final repository = ref.watch(preferencesRepositoryProvider);
    return PassengerPreferencesNotifier(repository);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Saved Routes Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier for managing saved routes.
class SavedRoutesNotifier extends StateNotifier<AsyncValue<List<SavedRoute>>> {
  SavedRoutesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadRoutes();
  }

  final PreferencesRepository _repository;

  /// Loads saved routes from storage.
  Future<void> _loadRoutes() async {
    try {
      final routes = await _repository.getSavedRoutes();
      state = AsyncValue.data(routes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refreshes the saved routes list.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadRoutes();
  }

  /// Adds a route to favorites.
  Future<void> addRoute(SavedRoute route) async {
    try {
      await _repository.addSavedRoute(route);
      final routes = state.valueOrNull ?? [];
      if (!routes.any((r) => r.routeId == route.routeId)) {
        state = AsyncValue.data([...routes, route]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Removes a route from favorites.
  Future<void> removeRoute(String routeId) async {
    try {
      await _repository.removeSavedRoute(routeId);
      final routes = state.valueOrNull ?? [];
      state = AsyncValue.data(
        routes.where((r) => r.routeId != routeId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates a saved route.
  Future<void> updateRoute(SavedRoute route) async {
    try {
      await _repository.updateSavedRoute(route);
      final routes = state.valueOrNull ?? [];
      final index = routes.indexWhere((r) => r.id == route.id);
      if (index != -1) {
        final updated = [...routes];
        updated[index] = route;
        state = AsyncValue.data(updated);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Marks a route as used.
  Future<void> markRouteAsUsed(String routeId) async {
    final routes = state.valueOrNull ?? [];
    final route = routes.firstWhere(
      (r) => r.routeId == routeId,
      orElse: () => throw Exception('Route not found'),
    );
    await updateRoute(route.markAsUsed());
  }
}

/// Provider for saved routes.
final savedRoutesProvider =
    StateNotifierProvider<SavedRoutesNotifier, AsyncValue<List<SavedRoute>>>(
  (ref) {
    final repository = ref.watch(preferencesRepositoryProvider);
    return SavedRoutesNotifier(repository);
  },
);

/// Provider to check if a specific route is saved.
final isRouteSavedProvider = Provider.family<bool, String>((ref, routeId) {
  final routes = ref.watch(savedRoutesProvider);
  return routes.valueOrNull?.any((r) => r.routeId == routeId) ?? false;
});

// ─────────────────────────────────────────────────────────────────────────────
// Saved Saccos Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier for managing saved Saccos.
class SavedSaccosNotifier extends StateNotifier<AsyncValue<List<SavedSacco>>> {
  SavedSaccosNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadSaccos();
  }

  final PreferencesRepository _repository;

  /// Loads saved Saccos from storage.
  Future<void> _loadSaccos() async {
    try {
      final saccos = await _repository.getSavedSaccos();
      state = AsyncValue.data(saccos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refreshes the saved Saccos list.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadSaccos();
  }

  /// Adds a Sacco to favorites.
  Future<void> addSacco(SavedSacco sacco) async {
    try {
      await _repository.addSavedSacco(sacco);
      final saccos = state.valueOrNull ?? [];
      if (!saccos.any((s) => s.saccoId == sacco.saccoId)) {
        state = AsyncValue.data([...saccos, sacco]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Removes a Sacco from favorites.
  Future<void> removeSacco(String saccoId) async {
    try {
      await _repository.removeSavedSacco(saccoId);
      final saccos = state.valueOrNull ?? [];
      state = AsyncValue.data(
        saccos.where((s) => s.saccoId != saccoId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates a saved Sacco.
  Future<void> updateSacco(SavedSacco sacco) async {
    try {
      await _repository.updateSavedSacco(sacco);
      final saccos = state.valueOrNull ?? [];
      final index = saccos.indexWhere((s) => s.id == sacco.id);
      if (index != -1) {
        final updated = [...saccos];
        updated[index] = sacco;
        state = AsyncValue.data(updated);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Marks a Sacco as used.
  Future<void> markSaccoAsUsed(String saccoId) async {
    final saccos = state.valueOrNull ?? [];
    final sacco = saccos.firstWhere(
      (s) => s.saccoId == saccoId,
      orElse: () => throw Exception('Sacco not found'),
    );
    await updateSacco(sacco.markAsUsed());
  }
}

/// Provider for saved Saccos.
final savedSaccosProvider =
    StateNotifierProvider<SavedSaccosNotifier, AsyncValue<List<SavedSacco>>>(
  (ref) {
    final repository = ref.watch(preferencesRepositoryProvider);
    return SavedSaccosNotifier(repository);
  },
);

/// Provider to check if a specific Sacco is saved.
final isSaccoSavedProvider = Provider.family<bool, String>((ref, saccoId) {
  final saccos = ref.watch(savedSaccosProvider);
  return saccos.valueOrNull?.any((s) => s.saccoId == saccoId) ?? false;
});

// ─────────────────────────────────────────────────────────────────────────────
// Saved Payment Methods Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier for managing saved payment methods.
class SavedPaymentMethodsNotifier
    extends StateNotifier<AsyncValue<List<SavedPaymentMethod>>> {
  SavedPaymentMethodsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadMethods();
  }

  final PreferencesRepository _repository;

  /// Loads saved payment methods from storage.
  Future<void> _loadMethods() async {
    try {
      final methods = await _repository.getSavedPaymentMethods();
      state = AsyncValue.data(methods);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refreshes the saved payment methods list.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadMethods();
  }

  /// Adds a payment method.
  Future<void> addPaymentMethod(SavedPaymentMethod method) async {
    try {
      await _repository.addPaymentMethod(method);
      await _loadMethods(); // Reload to get updated default status
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Adds an M-Pesa payment method.
  Future<void> addMpesa({
    required String phoneNumber,
    String? name,
  }) async {
    final method = SavedPaymentMethod.mpesa(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phoneNumber: phoneNumber,
      name: name,
    );
    await addPaymentMethod(method);
  }

  /// Adds a card payment method.
  Future<void> addCard({
    required String lastFourDigits,
    required String cardBrand,
    String? name,
    String? expiryDate,
  }) async {
    final method = SavedPaymentMethod.card(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastFourDigits: lastFourDigits,
      cardBrand: cardBrand,
      name: name,
      expiryDate: expiryDate,
    );
    await addPaymentMethod(method);
  }

  /// Removes a payment method.
  Future<void> removePaymentMethod(String methodId) async {
    try {
      await _repository.removePaymentMethod(methodId);
      await _loadMethods(); // Reload to get updated default status
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sets a payment method as default.
  Future<void> setDefault(String methodId) async {
    try {
      await _repository.setDefaultPaymentMethodById(methodId);
      await _loadMethods();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for saved payment methods.
final savedPaymentMethodsProvider = StateNotifierProvider<
    SavedPaymentMethodsNotifier, AsyncValue<List<SavedPaymentMethod>>>(
  (ref) {
    final repository = ref.watch(preferencesRepositoryProvider);
    return SavedPaymentMethodsNotifier(repository);
  },
);

/// Provider for the default payment method.
final defaultPaymentMethodProvider = Provider<SavedPaymentMethod?>((ref) {
  final methods = ref.watch(savedPaymentMethodsProvider);
  final list = methods.valueOrNull ?? [];
  try {
    return list.firstWhere((m) => m.isDefault);
  } catch (_) {
    return list.isNotEmpty ? list.first : null;
  }
});
