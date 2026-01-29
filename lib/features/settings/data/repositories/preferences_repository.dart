/// Preferences repository for local storage.
///
/// Provides SharedPreferences-based storage for passenger settings.
/// Implements repository pattern for clean separation of concerns.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/passenger_preferences.dart';
import '../../domain/entities/saved_route.dart';
import '../../domain/entities/saved_sacco.dart';
import '../../domain/entities/saved_payment_method.dart';
import '../models/passenger_preferences_model.dart';
import '../models/saved_route_model.dart';
import '../models/saved_sacco_model.dart';
import '../models/saved_payment_method_model.dart';

/// SharedPreferences keys for passenger settings.
class _PreferencesKeys {
  static const String passengerPreferences = 'passenger_preferences';
  static const String savedRoutes = 'saved_routes';
  static const String savedSaccos = 'saved_saccos';
  static const String savedPaymentMethods = 'saved_payment_methods';
}

/// Provider for preferences repository.
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl();
});

/// Abstract preferences repository interface.
///
/// Defines the contract for passenger settings storage.
abstract class PreferencesRepository {
  // ─────────────────────────────────────────────────────────────────────────
  // Passenger Preferences
  // ─────────────────────────────────────────────────────────────────────────

  /// Gets the passenger preferences.
  Future<PassengerPreferences> getPreferences();

  /// Saves the passenger preferences.
  Future<void> savePreferences(PassengerPreferences preferences);

  /// Updates the default payment method.
  Future<void> setDefaultPaymentMethod(PaymentMethod method);

  /// Updates notification preferences.
  Future<void> updateNotificationPreferences(NotificationPreferences notifications);

  /// Updates accessibility options.
  Future<void> updateAccessibilityOptions(AccessibilityOptions options);

  // ─────────────────────────────────────────────────────────────────────────
  // Saved Routes
  // ─────────────────────────────────────────────────────────────────────────

  /// Gets all saved routes.
  Future<List<SavedRoute>> getSavedRoutes();

  /// Adds a route to favorites.
  Future<void> addSavedRoute(SavedRoute route);

  /// Removes a route from favorites.
  Future<void> removeSavedRoute(String routeId);

  /// Updates a saved route (e.g., custom name, use count).
  Future<void> updateSavedRoute(SavedRoute route);

  /// Checks if a route is saved.
  Future<bool> isRouteSaved(String routeId);

  // ─────────────────────────────────────────────────────────────────────────
  // Saved Saccos
  // ─────────────────────────────────────────────────────────────────────────

  /// Gets all saved Saccos.
  Future<List<SavedSacco>> getSavedSaccos();

  /// Adds a Sacco to favorites.
  Future<void> addSavedSacco(SavedSacco sacco);

  /// Removes a Sacco from favorites.
  Future<void> removeSavedSacco(String saccoId);

  /// Updates a saved Sacco (e.g., custom name, use count).
  Future<void> updateSavedSacco(SavedSacco sacco);

  /// Checks if a Sacco is saved.
  Future<bool> isSaccoSaved(String saccoId);

  // ─────────────────────────────────────────────────────────────────────────
  // Saved Payment Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Gets all saved payment methods.
  Future<List<SavedPaymentMethod>> getSavedPaymentMethods();

  /// Adds a payment method.
  Future<void> addPaymentMethod(SavedPaymentMethod method);

  /// Removes a payment method.
  Future<void> removePaymentMethod(String methodId);

  /// Sets a payment method as default.
  Future<void> setDefaultPaymentMethodById(String methodId);

  /// Gets the default payment method.
  Future<SavedPaymentMethod?> getDefaultPaymentMethod();

  // ─────────────────────────────────────────────────────────────────────────
  // Clear Data
  // ─────────────────────────────────────────────────────────────────────────

  /// Clears all passenger settings data.
  Future<void> clearAll();
}

/// Implementation of [PreferencesRepository].
///
/// Uses SharedPreferences for local storage with JSON serialization.
class PreferencesRepositoryImpl implements PreferencesRepository {
  SharedPreferences? _prefs;

  /// Gets the SharedPreferences instance, initializing if needed.
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Passenger Preferences
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<PassengerPreferences> getPreferences() async {
    final prefs = await _getPrefs();
    final json = prefs.getString(_PreferencesKeys.passengerPreferences);

    if (json == null) {
      return const PassengerPreferences();
    }

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return PassengerPreferencesModel.fromJson(map).toEntity();
    } catch (_) {
      return const PassengerPreferences();
    }
  }

  @override
  Future<void> savePreferences(PassengerPreferences preferences) async {
    final prefs = await _getPrefs();
    final model = PassengerPreferencesModel.fromEntity(preferences);
    await prefs.setString(
      _PreferencesKeys.passengerPreferences,
      jsonEncode(model.toJson()),
    );
  }

  @override
  Future<void> setDefaultPaymentMethod(PaymentMethod method) async {
    final current = await getPreferences();
    await savePreferences(current.copyWith(defaultPaymentMethod: method));
  }

  @override
  Future<void> updateNotificationPreferences(
    NotificationPreferences notifications,
  ) async {
    final current = await getPreferences();
    await savePreferences(current.copyWith(notifications: notifications));
  }

  @override
  Future<void> updateAccessibilityOptions(AccessibilityOptions options) async {
    final current = await getPreferences();
    await savePreferences(current.copyWith(accessibility: options));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Saved Routes
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<SavedRoute>> getSavedRoutes() async {
    final prefs = await _getPrefs();
    final json = prefs.getString(_PreferencesKeys.savedRoutes);

    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => SavedRouteModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addSavedRoute(SavedRoute route) async {
    final routes = await getSavedRoutes();

    // Check if already saved
    if (routes.any((r) => r.routeId == route.routeId)) return;

    routes.add(route);
    await _saveRoutes(routes);
  }

  @override
  Future<void> removeSavedRoute(String routeId) async {
    final routes = await getSavedRoutes();
    routes.removeWhere((r) => r.routeId == routeId);
    await _saveRoutes(routes);
  }

  @override
  Future<void> updateSavedRoute(SavedRoute route) async {
    final routes = await getSavedRoutes();
    final index = routes.indexWhere((r) => r.id == route.id);
    if (index != -1) {
      routes[index] = route;
      await _saveRoutes(routes);
    }
  }

  @override
  Future<bool> isRouteSaved(String routeId) async {
    final routes = await getSavedRoutes();
    return routes.any((r) => r.routeId == routeId);
  }

  Future<void> _saveRoutes(List<SavedRoute> routes) async {
    final prefs = await _getPrefs();
    final models = routes.map((r) => SavedRouteModel.fromEntity(r).toJson()).toList();
    await prefs.setString(_PreferencesKeys.savedRoutes, jsonEncode(models));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Saved Saccos
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<SavedSacco>> getSavedSaccos() async {
    final prefs = await _getPrefs();
    final json = prefs.getString(_PreferencesKeys.savedSaccos);

    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => SavedSaccoModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addSavedSacco(SavedSacco sacco) async {
    final saccos = await getSavedSaccos();

    // Check if already saved
    if (saccos.any((s) => s.saccoId == sacco.saccoId)) return;

    saccos.add(sacco);
    await _saveSaccos(saccos);
  }

  @override
  Future<void> removeSavedSacco(String saccoId) async {
    final saccos = await getSavedSaccos();
    saccos.removeWhere((s) => s.saccoId == saccoId);
    await _saveSaccos(saccos);
  }

  @override
  Future<void> updateSavedSacco(SavedSacco sacco) async {
    final saccos = await getSavedSaccos();
    final index = saccos.indexWhere((s) => s.id == sacco.id);
    if (index != -1) {
      saccos[index] = sacco;
      await _saveSaccos(saccos);
    }
  }

  @override
  Future<bool> isSaccoSaved(String saccoId) async {
    final saccos = await getSavedSaccos();
    return saccos.any((s) => s.saccoId == saccoId);
  }

  Future<void> _saveSaccos(List<SavedSacco> saccos) async {
    final prefs = await _getPrefs();
    final models = saccos.map((s) => SavedSaccoModel.fromEntity(s).toJson()).toList();
    await prefs.setString(_PreferencesKeys.savedSaccos, jsonEncode(models));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Saved Payment Methods
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<SavedPaymentMethod>> getSavedPaymentMethods() async {
    final prefs = await _getPrefs();
    final json = prefs.getString(_PreferencesKeys.savedPaymentMethods);

    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) =>
              SavedPaymentMethodModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addPaymentMethod(SavedPaymentMethod method) async {
    final methods = await getSavedPaymentMethods();

    // If this is the first method, make it default
    final isFirst = methods.isEmpty;
    final methodToAdd = isFirst ? method.setAsDefault() : method;

    methods.add(methodToAdd);
    await _savePaymentMethods(methods);
  }

  @override
  Future<void> removePaymentMethod(String methodId) async {
    final methods = await getSavedPaymentMethods();
    final removedMethod = methods.firstWhere(
      (m) => m.id == methodId,
      orElse: () => throw Exception('Method not found'),
    );

    methods.removeWhere((m) => m.id == methodId);

    // If removed method was default, set first remaining as default
    if (removedMethod.isDefault && methods.isNotEmpty) {
      methods[0] = methods[0].setAsDefault();
    }

    await _savePaymentMethods(methods);
  }

  @override
  Future<void> setDefaultPaymentMethodById(String methodId) async {
    final methods = await getSavedPaymentMethods();

    final updated = methods.map((m) {
      if (m.id == methodId) {
        return m.setAsDefault();
      } else if (m.isDefault) {
        return m.removeDefault();
      }
      return m;
    }).toList();

    await _savePaymentMethods(updated);
  }

  @override
  Future<SavedPaymentMethod?> getDefaultPaymentMethod() async {
    final methods = await getSavedPaymentMethods();
    try {
      return methods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return methods.isNotEmpty ? methods.first : null;
    }
  }

  Future<void> _savePaymentMethods(List<SavedPaymentMethod> methods) async {
    final prefs = await _getPrefs();
    final models =
        methods.map((m) => SavedPaymentMethodModel.fromEntity(m).toJson()).toList();
    await prefs.setString(_PreferencesKeys.savedPaymentMethods, jsonEncode(models));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear Data
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_PreferencesKeys.passengerPreferences);
    await prefs.remove(_PreferencesKeys.savedRoutes);
    await prefs.remove(_PreferencesKeys.savedSaccos);
    await prefs.remove(_PreferencesKeys.savedPaymentMethods);
  }
}
