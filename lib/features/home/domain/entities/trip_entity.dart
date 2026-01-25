class TripEntity {
  final int id;
  final int userId;
  final String routeName;
  final String fromLocation;
  final String toLocation;
  final double fare;
  final String status;
  final DateTime tripDate;

  const TripEntity({
    required this.id,
    required this.userId,
    required this.routeName,
    required this.fromLocation,
    required this.toLocation,
    required this.fare,
    required this.status,
    required this.tripDate,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';

  String get formattedFare => 'KES ${fare.toStringAsFixed(0)}';
}
