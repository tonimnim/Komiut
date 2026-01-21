import '../../domain/entities/trip_history.dart';

class TripHistoryModel extends TripHistory {
  const TripHistoryModel({
    required super.tripId,
    required super.routeName,
    required super.date,
    required super.time,
    required super.passengers,
    required super.earnings,
    required super.status,
  });

  factory TripHistoryModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryModel(
      tripId: json['trip_id'],
      routeName: json['route_name'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      passengers: json['passengers'],
      earnings: (json['earnings'] as num).toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'route_name': routeName,
      'date': date.toIso8601String(),
      'time': time,
      'passengers': passengers,
      'earnings': earnings,
      'status': status,
    };
  }
}
