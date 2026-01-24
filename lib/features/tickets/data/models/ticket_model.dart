/// Ticket API model.
///
/// Data transfer object for Ticket entity matching API schema.
library;

import '../../domain/entities/ticket.dart';

/// Route info model for API communication.
class RouteInfoModel {
  /// Creates a new RouteInfoModel instance.
  const RouteInfoModel({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
  });

  /// Creates from JSON map.
  factory RouteInfoModel.fromJson(Map<String, dynamic> json) {
    return RouteInfoModel(
      id: json['routeId'] as String? ?? json['id'] as String,
      name: json['routeName'] as String? ?? json['name'] as String,
      startPoint: json['startPoint'] as String,
      endPoint: json['endPoint'] as String,
    );
  }

  /// Creates from entity.
  factory RouteInfoModel.fromEntity(RouteInfo entity) {
    return RouteInfoModel(
      id: entity.id,
      name: entity.name,
      startPoint: entity.startPoint,
      endPoint: entity.endPoint,
    );
  }

  final String id;
  final String name;
  final String startPoint;
  final String endPoint;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'routeId': id,
        'routeName': name,
        'startPoint': startPoint,
        'endPoint': endPoint,
      };

  /// Converts to domain entity.
  RouteInfo toEntity() => RouteInfo(
        id: id,
        name: name,
        startPoint: startPoint,
        endPoint: endPoint,
      );
}

/// Trip info model for API communication.
class TripInfoModel {
  /// Creates a new TripInfoModel instance.
  const TripInfoModel({
    required this.id,
    required this.vehicleRegistration,
    this.driverName,
    this.driverPhone,
    required this.departureTime,
    this.estimatedArrival,
  });

  /// Creates from JSON map.
  factory TripInfoModel.fromJson(Map<String, dynamic> json) {
    return TripInfoModel(
      id: json['tripId'] as String? ?? json['id'] as String,
      vehicleRegistration: json['vehicleRegistration'] as String,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      departureTime: DateTime.parse(json['departureTime'] as String),
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.parse(json['estimatedArrival'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory TripInfoModel.fromEntity(TripInfo entity) {
    return TripInfoModel(
      id: entity.id,
      vehicleRegistration: entity.vehicleRegistration,
      driverName: entity.driverName,
      driverPhone: entity.driverPhone,
      departureTime: entity.departureTime,
      estimatedArrival: entity.estimatedArrival,
    );
  }

  final String id;
  final String vehicleRegistration;
  final String? driverName;
  final String? driverPhone;
  final DateTime departureTime;
  final DateTime? estimatedArrival;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'tripId': id,
        'vehicleRegistration': vehicleRegistration,
        if (driverName != null) 'driverName': driverName,
        if (driverPhone != null) 'driverPhone': driverPhone,
        'departureTime': departureTime.toIso8601String(),
        if (estimatedArrival != null)
          'estimatedArrival': estimatedArrival!.toIso8601String(),
      };

  /// Converts to domain entity.
  TripInfo toEntity() => TripInfo(
        id: id,
        vehicleRegistration: vehicleRegistration,
        driverName: driverName,
        driverPhone: driverPhone,
        departureTime: departureTime,
        estimatedArrival: estimatedArrival,
      );
}

/// Ticket model for API communication.
class TicketModel {
  /// Creates a new TicketModel instance.
  const TicketModel({
    required this.id,
    required this.bookingId,
    required this.passengerId,
    required this.qrCode,
    required this.ticketNumber,
    required this.status,
    required this.routeInfo,
    required this.tripInfo,
    required this.pickupStop,
    required this.dropoffStop,
    this.seatNumber,
    required this.fare,
    required this.currency,
    required this.validFrom,
    required this.validUntil,
    this.usedAt,
    this.passengerName,
    this.passengerPhone,
    this.createdAt,
  });

  /// Creates from JSON map.
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['ticketId'] as String? ?? json['id'] as String,
      bookingId: json['bookingId'] as String,
      passengerId: json['passengerId'] as String,
      qrCode: json['qrCode'] as String,
      ticketNumber: json['ticketNumber'] as String,
      status: _parseTicketStatus(json['status']),
      routeInfo: RouteInfoModel.fromJson(
        json['routeInfo'] as Map<String, dynamic>? ??
            _extractRouteInfo(json),
      ),
      tripInfo: TripInfoModel.fromJson(
        json['tripInfo'] as Map<String, dynamic>? ??
            _extractTripInfo(json),
      ),
      pickupStop: json['pickupStop'] as String? ??
          json['pickupStopName'] as String,
      dropoffStop: json['dropoffStop'] as String? ??
          json['dropoffStopName'] as String,
      seatNumber: json['seatNumber'] as int?,
      fare: (json['fare'] as num? ?? json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      passengerName: json['passengerName'] as String?,
      passengerPhone: json['passengerPhone'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory TicketModel.fromEntity(Ticket entity) {
    return TicketModel(
      id: entity.id,
      bookingId: entity.bookingId,
      passengerId: entity.passengerId,
      qrCode: entity.qrCode,
      ticketNumber: entity.ticketNumber,
      status: entity.status,
      routeInfo: RouteInfoModel.fromEntity(entity.routeInfo),
      tripInfo: TripInfoModel.fromEntity(entity.tripInfo),
      pickupStop: entity.pickupStop,
      dropoffStop: entity.dropoffStop,
      seatNumber: entity.seatNumber,
      fare: entity.fare,
      currency: entity.currency,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
      usedAt: entity.usedAt,
      passengerName: entity.passengerName,
      passengerPhone: entity.passengerPhone,
      createdAt: entity.createdAt,
    );
  }

  final String id;
  final String bookingId;
  final String passengerId;
  final String qrCode;
  final String ticketNumber;
  final TicketStatus status;
  final RouteInfoModel routeInfo;
  final TripInfoModel tripInfo;
  final String pickupStop;
  final String dropoffStop;
  final int? seatNumber;
  final double fare;
  final String currency;
  final DateTime validFrom;
  final DateTime validUntil;
  final DateTime? usedAt;
  final String? passengerName;
  final String? passengerPhone;
  final DateTime? createdAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'ticketId': id,
        'bookingId': bookingId,
        'passengerId': passengerId,
        'qrCode': qrCode,
        'ticketNumber': ticketNumber,
        'status': status.toApiValue(),
        'routeInfo': routeInfo.toJson(),
        'tripInfo': tripInfo.toJson(),
        'pickupStop': pickupStop,
        'dropoffStop': dropoffStop,
        if (seatNumber != null) 'seatNumber': seatNumber,
        'fare': fare,
        'currency': currency,
        'validFrom': validFrom.toIso8601String(),
        'validUntil': validUntil.toIso8601String(),
        if (usedAt != null) 'usedAt': usedAt!.toIso8601String(),
        if (passengerName != null) 'passengerName': passengerName,
        if (passengerPhone != null) 'passengerPhone': passengerPhone,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Ticket toEntity() => Ticket(
        id: id,
        bookingId: bookingId,
        passengerId: passengerId,
        qrCode: qrCode,
        ticketNumber: ticketNumber,
        status: status,
        routeInfo: routeInfo.toEntity(),
        tripInfo: tripInfo.toEntity(),
        pickupStop: pickupStop,
        dropoffStop: dropoffStop,
        seatNumber: seatNumber,
        fare: fare,
        currency: currency,
        validFrom: validFrom,
        validUntil: validUntil,
        usedAt: usedAt,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        createdAt: createdAt,
      );
}

/// Helper to parse ticket status from int or string.
TicketStatus _parseTicketStatus(dynamic status) {
  if (status is int) {
    // API returns: 0=valid, 1=used, 2=expired, 3=cancelled
    return TicketStatus.values[status.clamp(0, TicketStatus.values.length - 1)];
  }
  return ticketStatusFromString(status as String? ?? 'valid');
}

/// Extract route info from flat JSON structure.
Map<String, dynamic> _extractRouteInfo(Map<String, dynamic> json) {
  return {
    'routeId': json['routeId'] ?? '',
    'routeName': json['routeName'] ?? '',
    'startPoint': json['startPoint'] ?? json['routeStartPoint'] ?? '',
    'endPoint': json['endPoint'] ?? json['routeEndPoint'] ?? '',
  };
}

/// Extract trip info from flat JSON structure.
Map<String, dynamic> _extractTripInfo(Map<String, dynamic> json) {
  return {
    'tripId': json['tripId'] ?? '',
    'vehicleRegistration': json['vehicleRegistration'] ?? '',
    'driverName': json['driverName'],
    'driverPhone': json['driverPhone'],
    'departureTime': json['departureTime'] ?? json['tripStartTime'] ?? DateTime.now().toIso8601String(),
    'estimatedArrival': json['estimatedArrival'],
  };
}

/// Boarding result model.
class BoardingResult {
  /// Creates a new BoardingResult instance.
  const BoardingResult({
    required this.success,
    required this.message,
    this.ticketId,
    this.boardedAt,
    this.tripId,
  });

  /// Creates from JSON map.
  factory BoardingResult.fromJson(Map<String, dynamic> json) {
    return BoardingResult(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Boarding confirmed',
      ticketId: json['ticketId'] as String?,
      boardedAt: json['boardedAt'] != null
          ? DateTime.parse(json['boardedAt'] as String)
          : DateTime.now(),
      tripId: json['tripId'] as String?,
    );
  }

  /// Whether boarding was successful.
  final bool success;

  /// Message from the API.
  final String message;

  /// Ticket ID that was boarded.
  final String? ticketId;

  /// When boarding was confirmed.
  final DateTime? boardedAt;

  /// Trip ID for navigation.
  final String? tripId;
}

/// Ticket validation result model.
class TicketValidationResult {
  /// Creates a new TicketValidationResult instance.
  const TicketValidationResult({
    required this.isValid,
    required this.message,
    this.ticket,
    this.validationCode,
  });

  /// Creates from JSON map.
  factory TicketValidationResult.fromJson(Map<String, dynamic> json) {
    return TicketValidationResult(
      isValid: json['isValid'] as bool? ?? false,
      message: json['message'] as String? ?? 'Validation complete',
      ticket: json['ticket'] != null
          ? TicketModel.fromJson(json['ticket'] as Map<String, dynamic>)
              .toEntity()
          : null,
      validationCode: json['validationCode'] as String?,
    );
  }

  /// Whether the ticket is valid.
  final bool isValid;

  /// Validation message.
  final String message;

  /// Full ticket data if valid.
  final Ticket? ticket;

  /// Validation code for reference.
  final String? validationCode;
}
