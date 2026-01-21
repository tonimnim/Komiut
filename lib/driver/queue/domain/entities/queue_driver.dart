class QueueDriver {
  final String id;
  final String name;
  final String vehicle;
  final String position; // e.g., "POS #3" or "Ahead"
  final String status; // e.g., "IN LOADING", "10M WAIT"
  final bool isMe;
  final String? avatarUrl;
  final String plateNumber;

  const QueueDriver({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.position,
    required this.status,
    required this.plateNumber,
    this.isMe = false,
    this.avatarUrl,
  });
}
