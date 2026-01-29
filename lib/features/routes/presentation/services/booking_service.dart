import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/route_entity.dart';

class TicketData {
  final String ticketId;
  final String routeName;
  final String fromStop;
  final String toStop;
  final double fare;
  final String currency;
  final DateTime bookingTime;
  final DateTime expiryTime;

  const TicketData({
    required this.ticketId,
    required this.routeName,
    required this.fromStop,
    required this.toStop,
    required this.fare,
    required this.currency,
    required this.bookingTime,
    required this.expiryTime,
  });

  String get formattedFare => '$currency ${fare.toStringAsFixed(0)}';

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

class BookingService {
  final AppDatabase _database;
  final int _userId;

  BookingService(this._database, this._userId);

  Future<TicketData> bookTrip({
    required RouteEntity route,
    required int fromStopIndex,
    required int toStopIndex,
    required double fare,
  }) async {
    // Get wallet
    final wallet = await _database.getWalletByUserId(_userId);
    if (wallet == null) {
      throw Exception('Wallet not found');
    }

    if (wallet.balance < fare) {
      throw Exception('Insufficient balance');
    }

    // Generate ticket ID
    final ticketId = _generateTicketId();
    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 2)); // 2 hour validity

    // Create trip record
    await _database.createTrip(
      TripsCompanion.insert(
        userId: _userId,
        routeName: route.name,
        fromLocation: route.stops[fromStopIndex],
        toLocation: route.stops[toStopIndex],
        fare: fare,
        status: 'completed',
        tripDate: now,
      ),
    );

    // Create payment record
    await _database.createPayment(
      PaymentsCompanion.insert(
        userId: _userId,
        amount: fare,
        type: 'trip',
        status: 'completed',
        description: Value('${route.name}: ${route.stops[fromStopIndex]} → ${route.stops[toStopIndex]}'),
        referenceId: ticketId,
        transactionDate: now,
      ),
    );

    // Deduct from wallet
    final newBalance = wallet.balance - fare;
    await _database.updateWalletBalance(wallet.id, newBalance);

    return TicketData(
      ticketId: ticketId,
      routeName: route.name,
      fromStop: route.stops[fromStopIndex],
      toStop: route.stops[toStopIndex],
      fare: fare,
      currency: route.currency,
      bookingTime: now,
      expiryTime: expiry,
    );
  }

  String _generateTicketId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    final randomPart = random.nextInt(9999).toString().padLeft(4, '0');
    return 'TKT-$timestamp-$randomPart';
  }
}

final bookingServiceProvider = Provider<BookingService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.id ?? 0;
  return BookingService(database, userId);
});
