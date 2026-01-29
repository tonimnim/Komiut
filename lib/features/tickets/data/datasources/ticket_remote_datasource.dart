/// Ticket remote datasource.
///
/// Handles ticket API calls for passengers to view and manage boarding tickets.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/ticket.dart';
import '../models/ticket_model.dart';

/// Provider for ticket remote datasource.
final ticketRemoteDataSourceProvider = Provider<TicketRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TicketRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract ticket remote datasource.
abstract class TicketRemoteDataSource {
  /// Gets a ticket by booking ID.
  /// GET /api/Tickets/booking/{bookingId}
  Future<Either<Failure, Ticket>> getTicket(String bookingId);

  /// Gets a ticket by ticket ID.
  /// GET /api/Tickets/{id}
  Future<Either<Failure, Ticket>> getTicketById(String ticketId);

  /// Gets all tickets for the current user.
  /// GET /api/Tickets/my
  Future<Either<Failure, List<Ticket>>> getMyTickets({
    String? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Confirms boarding for a ticket.
  /// POST /api/Tickets/{id}/board
  Future<Either<Failure, BoardingResult>> confirmBoarding(String ticketId);

  /// Validates a ticket for boarding.
  /// GET /api/Tickets/{id}/validate
  Future<Either<Failure, TicketValidationResult>> validateTicket(String ticketId);
}

/// Implementation of ticket remote datasource.
class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  /// Creates a ticket remote datasource.
  TicketRemoteDataSourceImpl({required this.apiClient});

  /// API client for making requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, Ticket>> getTicket(String bookingId) async {
    return apiClient.get<Ticket>(
      '/api/Tickets/booking/$bookingId',
      fromJson: (data) =>
          TicketModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, Ticket>> getTicketById(String ticketId) async {
    return apiClient.get<Ticket>(
      '/api/Tickets/$ticketId',
      fromJson: (data) =>
          TicketModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Ticket>>> getMyTickets({
    String? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != null) 'status': status,
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
    };

    return apiClient.get<List<Ticket>>(
      '/api/Tickets/my',
      queryParameters: queryParams,
      fromJson: (data) => _parseTicketsList(data),
    );
  }

  @override
  Future<Either<Failure, BoardingResult>> confirmBoarding(String ticketId) async {
    return apiClient.post<BoardingResult>(
      '/api/Tickets/$ticketId/board',
      fromJson: (data) =>
          BoardingResult.fromJson(data as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  Future<Either<Failure, TicketValidationResult>> validateTicket(
    String ticketId,
  ) async {
    return apiClient.get<TicketValidationResult>(
      '/api/Tickets/$ticketId/validate',
      fromJson: (data) =>
          TicketValidationResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Parse tickets list from API response.
  List<Ticket> _parseTicketsList(dynamic data) {
    if (data is List) {
      return data
          .map((json) =>
              TicketModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    }
    // Handle paginated response
    if (data is Map<String, dynamic> && data['items'] != null) {
      final items = data['items'] as List;
      return items
          .map((json) =>
              TicketModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    }
    return <Ticket>[];
  }
}
