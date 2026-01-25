class QueueDriver {
  final String id;
  final String name;
  final String vehicle;
  final String position;
  final String status;
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
