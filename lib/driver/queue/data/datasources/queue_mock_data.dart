// Removed QueueDriver references
class QueueMockData {
  static const List<Map<String, dynamic>> queueList = [
    {
      'id': '1',
      'name': 'Alice M.',
      'vehicle': 'Toyota Hiace',
      'plateNumber': 'KBD 123',
      'position': 'Ahead',
      'status': 'IN LOADING',
      'isMe': false,
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'id': '2',
      'name': 'You (Me)',
      'vehicle': 'Volkswagen Transporter',
      'plateNumber': 'KYZ 789',
      'position': 'POS #3',
      'status': '',
      'isMe': true,
      'avatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'id': '3',
      'name': 'Sarah L.',
      'vehicle': 'Mercedes Sprinter',
      'plateNumber': 'LMN 456',
      'position': 'Behind',
      'status': '10M WAIT',
      'isMe': false,
      'avatarUrl': 'https://i.pravatar.cc/150?img=9',
    },
  ];

  static const String currentRoute = "Route 402 - Downtown Express";
  static const String terminalInfo = "Terminal A • Station Gate 14";
  static const int currentPosition = 3;
  static const int estimatedWaitMinutes = 8;
  static const int driversWaiting = 6;
  static const int currentPassengers = 12;
  static const int maxPassengers = 15;
}
