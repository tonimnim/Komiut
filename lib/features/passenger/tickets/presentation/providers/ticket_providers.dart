/// Ticket providers.
///
/// Provides state management for tickets feature using Riverpod.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/ticket_remote_datasource.dart';
import '../../data/models/ticket_model.dart';
import '../../domain/entities/ticket.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter Classes
// ─────────────────────────────────────────────────────────────────────────────

/// Filter for fetching tickets.
class TicketsFilter {
  const TicketsFilter({
    this.status,
    this.pageNumber,
    this.pageSize,
  });

  final String? status;
  final int? pageNumber;
  final int? pageSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketsFilter &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize;

  @override
  int get hashCode => Object.hash(status, pageNumber, pageSize);
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for a ticket by booking ID.
///
/// Usage:
/// ```dart
/// final ticket = ref.watch(ticketByBookingProvider('booking-id'));
/// ```
final ticketByBookingProvider =
    FutureProvider.autoDispose.family<Ticket?, String>(
  (ref, bookingId) async {
    final datasource = ref.watch(ticketRemoteDataSourceProvider);

    final result = await datasource.getTicket(bookingId);

    return result.fold(
      (failure) => null,
      (ticket) => ticket,
    );
  },
);

/// Provider for a ticket by ticket ID.
///
/// Usage:
/// ```dart
/// final ticket = ref.watch(ticketByIdProvider('ticket-id'));
/// ```
final ticketByIdProvider = FutureProvider.autoDispose.family<Ticket?, String>(
  (ref, ticketId) async {
    final datasource = ref.watch(ticketRemoteDataSourceProvider);

    final result = await datasource.getTicketById(ticketId);

    return result.fold(
      (failure) => null,
      (ticket) => ticket,
    );
  },
);

/// Provider for all user tickets with optional filtering.
///
/// Usage:
/// ```dart
/// final tickets = ref.watch(myTicketsProvider(TicketsFilter(status: 'valid')));
/// ```
final myTicketsProvider =
    FutureProvider.autoDispose.family<List<Ticket>, TicketsFilter>(
  (ref, filter) async {
    final datasource = ref.watch(ticketRemoteDataSourceProvider);
    final authState = ref.watch(authStateProvider);

    if (authState.user == null) return [];

    final result = await datasource.getMyTickets(
      status: filter.status,
      pageNumber: filter.pageNumber,
      pageSize: filter.pageSize,
    );

    return result.fold(
      (failure) => [],
      (tickets) => tickets,
    );
  },
);

/// Provider for all user tickets (no filter).
final allTicketsProvider = FutureProvider.autoDispose<List<Ticket>>(
  (ref) async {
    final datasource = ref.watch(ticketRemoteDataSourceProvider);
    final authState = ref.watch(authStateProvider);

    if (authState.user == null) return [];

    final result = await datasource.getMyTickets();

    return result.fold(
      (failure) => [],
      (tickets) => tickets,
    );
  },
);

/// Provider for active (valid) tickets only.
final activeTicketsProvider = FutureProvider.autoDispose<List<Ticket>>(
  (ref) async {
    final datasource = ref.watch(ticketRemoteDataSourceProvider);
    final authState = ref.watch(authStateProvider);

    if (authState.user == null) return [];

    final result = await datasource.getMyTickets(status: 'valid');

    return result.fold(
      (failure) => [],
      (tickets) =>
          tickets.where((t) => t.status == TicketStatus.valid).toList(),
    );
  },
);

/// Provider for past (used/expired) tickets.
final pastTicketsProvider = FutureProvider.autoDispose<List<Ticket>>(
  (ref) async {
    final allTickets = await ref.watch(allTicketsProvider.future);
    return allTickets
        .where((t) =>
            t.status == TicketStatus.used || t.status == TicketStatus.expired)
        .toList();
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Boarding Providers
// ─────────────────────────────────────────────────────────────────────────────

/// State notifier for boarding confirmation.
class BoardingNotifier extends StateNotifier<AsyncValue<BoardingResult?>> {
  BoardingNotifier(this._datasource) : super(const AsyncValue.data(null));

  final TicketRemoteDataSource _datasource;

  /// Confirms boarding for a ticket.
  Future<BoardingResult?> confirmBoarding(String ticketId) async {
    state = const AsyncValue.loading();

    final result = await _datasource.confirmBoarding(ticketId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return null;
      },
      (boardingResult) {
        state = AsyncValue.data(boardingResult);
        return boardingResult;
      },
    );
  }

  /// Resets the state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for boarding confirmation.
final boardingNotifierProvider = StateNotifierProvider.autoDispose<
    BoardingNotifier, AsyncValue<BoardingResult?>>(
  (ref) {
    final datasource = ref.watch(ticketRemoteDataSourceProvider);
    return BoardingNotifier(datasource);
  },
);

/// Provider for validating a ticket.
///
/// Usage:
/// ```dart
/// final validation = ref.watch(validateTicketProvider('ticket-id'));
/// ```
final validateTicketProvider =
    FutureProvider.autoDispose.family<TicketValidationResult?, String>(
  (ref, ticketId) async {
    final datasource = ref.watch(ticketRemoteDataSourceProvider);

    final result = await datasource.validateTicket(ticketId);

    return result.fold(
      (failure) => null,
      (validation) => validation,
    );
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// QR Code Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Generates QR code data for a ticket.
///
/// Encodes: ticketId, passengerId, tripId, validUntil
String generateTicketQRData(Ticket ticket) {
  final qrData = {
    'ticketId': ticket.id,
    'passengerId': ticket.passengerId,
    'tripId': ticket.tripInfo.id,
    'ticketNumber': ticket.ticketNumber,
    'validUntil': ticket.validUntil.toIso8601String(),
    'checksum': _generateChecksum(ticket),
  };
  return jsonEncode(qrData);
}

/// Generates a simple checksum for ticket validation.
String _generateChecksum(Ticket ticket) {
  final data = '${ticket.id}:${ticket.passengerId}:${ticket.tripInfo.id}';
  // Simple hash for demo - in production use proper HMAC
  return data.hashCode.toRadixString(16);
}

/// Provider for QR data of a ticket.
///
/// Usage:
/// ```dart
/// final qrData = ref.watch(ticketQRDataProvider(ticket));
/// ```
final ticketQRDataProvider = Provider.family<String, Ticket>(
  (ref, ticket) {
    // Use the server-provided QR code if available, otherwise generate
    if (ticket.qrCode.isNotEmpty) {
      return ticket.qrCode;
    }
    return generateTicketQRData(ticket);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// UI State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Selected ticket filter tab.
enum TicketFilterTab { active, past, all }

/// Provider for current ticket filter selection.
final ticketFilterTabProvider = StateProvider<TicketFilterTab>(
  (ref) => TicketFilterTab.active,
);

/// Provider for ticket search query.
final ticketSearchQueryProvider = StateProvider<String>(
  (ref) => '',
);

/// Provider for filtered tickets based on tab and search.
final filteredTicketsProvider = FutureProvider.autoDispose<List<Ticket>>(
  (ref) async {
    final tab = ref.watch(ticketFilterTabProvider);
    final searchQuery = ref.watch(ticketSearchQueryProvider).toLowerCase();

    List<Ticket> tickets;
    switch (tab) {
      case TicketFilterTab.active:
        tickets = await ref.watch(activeTicketsProvider.future);
        break;
      case TicketFilterTab.past:
        tickets = await ref.watch(pastTicketsProvider.future);
        break;
      case TicketFilterTab.all:
        tickets = await ref.watch(allTicketsProvider.future);
        break;
    }

    if (searchQuery.isEmpty) return tickets;

    return tickets.where((ticket) {
      final matchesRoute =
          ticket.routeInfo.name.toLowerCase().contains(searchQuery) ||
              ticket.routeInfo.summary.toLowerCase().contains(searchQuery);
      final matchesTicketNumber =
          ticket.ticketNumber.toLowerCase().contains(searchQuery);
      final matchesStops =
          ticket.pickupStop.toLowerCase().contains(searchQuery) ||
              ticket.dropoffStop.toLowerCase().contains(searchQuery);
      return matchesRoute || matchesTicketNumber || matchesStops;
    }).toList();
  },
);

/// Provider for screen brightness boost state.
final brightnessBoostProvider = StateProvider<bool>(
  (ref) => false,
);
