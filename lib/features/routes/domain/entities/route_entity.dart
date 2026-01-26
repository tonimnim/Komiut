import 'dart:convert';

class RouteEntity {
  final int id;
  final String name;
  final String startPoint;
  final String endPoint;
  final int stopsCount;
  final int durationMinutes;
  final double baseFare;
  final double farePerStop;
  final String currency;
  final List<String> stops;
  final bool isFavorite;

  /// The ID of the organization (sacco) that operates this route.
  final String? organizationId;

  /// Whether this route is marked as popular/featured.
  final bool isPopular;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.stopsCount,
    required this.durationMinutes,
    required this.baseFare,
    required this.farePerStop,
    required this.currency,
    required this.stops,
    this.isFavorite = false,
    this.organizationId,
    this.isPopular = false,
  });

  String get formattedDuration => '~$durationMinutes min';

  String get formattedBaseFare => '$currency ${baseFare.toStringAsFixed(0)}';

  /// Alias for formattedBaseFare for backwards compatibility.
  String get formattedFare => formattedBaseFare;

  String get routeSummary => '$startPoint → $endPoint';

  /// Calculate fare based on number of stops traveled
  double calculateFare(int fromStopIndex, int toStopIndex) {
    final stopsToTravel = (toStopIndex - fromStopIndex).abs();
    if (stopsToTravel == 0) return 0;
    return baseFare + (farePerStop * (stopsToTravel - 1));
  }

  /// Format fare for display
  String formatFare(double fare) => '$currency ${fare.toStringAsFixed(0)}';

  RouteEntity copyWith({
    int? id,
    String? name,
    String? startPoint,
    String? endPoint,
    int? stopsCount,
    int? durationMinutes,
    double? baseFare,
    double? farePerStop,
    String? currency,
    List<String>? stops,
    bool? isFavorite,
    String? organizationId,
    bool? isPopular,
  }) {
    return RouteEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      stopsCount: stopsCount ?? this.stopsCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      baseFare: baseFare ?? this.baseFare,
      farePerStop: farePerStop ?? this.farePerStop,
      currency: currency ?? this.currency,
      stops: stops ?? this.stops,
      isFavorite: isFavorite ?? this.isFavorite,
      organizationId: organizationId ?? this.organizationId,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  /// Create from database model
  factory RouteEntity.fromDatabase(
    dynamic dbRoute, {
    bool isFavorite = false,
    String? organizationId,
    bool isPopular = false,
  }) {
    List<String> stopsList;
    try {
      stopsList = List<String>.from(jsonDecode(dbRoute.stops as String));
    } catch (_) {
      stopsList = [];
    }

    return RouteEntity(
      id: dbRoute.id as int,
      name: dbRoute.name as String,
      startPoint: dbRoute.startPoint as String,
      endPoint: dbRoute.endPoint as String,
      stopsCount: dbRoute.stopsCount as int,
      durationMinutes: dbRoute.durationMinutes as int,
      baseFare: dbRoute.baseFare as double,
      farePerStop: dbRoute.farePerStop as double,
      currency: dbRoute.currency as String,
      stops: stopsList,
      isFavorite: isFavorite,
      organizationId: organizationId,
      isPopular: isPopular,
    );
  }
}
