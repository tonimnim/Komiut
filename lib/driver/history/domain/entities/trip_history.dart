import 'package:equatable/equatable.dart';

class TripHistory extends Equatable {
  final String tripId;
  final String routeName;
  final DateTime date;
  final String time;
  final int passengers;
  final double earnings;
  final String status;

  const TripHistory({
    required this.tripId,
    required this.routeName,
    required this.date,
    required this.time,
    required this.passengers,
    required this.earnings,
    required this.status,
  });

  String get id => tripId;
  String get route => routeName;
  int get passengerCount => passengers;

  @override
  List<Object?> get props => [tripId, routeName, date, time, passengers, earnings, status];
}
