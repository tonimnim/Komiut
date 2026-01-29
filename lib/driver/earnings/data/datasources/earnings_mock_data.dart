class EarningsMockData {
  static const String totalEarnings = "KSH 1,240.50";
  static const String earningsLabel = "Total Earnings";
  static const String period = "This Week";

  static const List<Map<String, dynamic>> weeklyChart = [
    {"day": "M", "amount": 120.0, "pct": 0.4},
    {"day": "T", "amount": 180.0, "pct": 0.6},
    {"day": "W", "amount": 150.0, "pct": 0.5},
    {"day": "T", "amount": 250.0, "pct": 0.8},
    {"day": "F", "amount": 300.0, "pct": 1.0},
    {"day": "S", "amount": 200.0, "pct": 0.7},
    {"day": "S", "amount": 40.0, "pct": 0.2},
  ];

  static const List<Map<String, String>> transactions = [
    {
      "id": "Trip #TR-8832",
      "date": "Today, 10:30 AM",
      "amount": "+KSH 25.50",
      "status": "Completed"
    },
    {
      "id": "Trip #TR-8831",
      "date": "Today, 09:15 AM",
      "amount": "+KSH 18.00",
      "status": "Completed"
    },
    {
      "id": "Trip #TR-8830",
      "date": "Yesterday, 06:45 PM",
      "amount": "+KSH 42.00",
      "status": "Completed"
    },
     {
      "id": "Trip #TR-8829",
      "date": "Yesterday, 04:20 PM",
      "amount": "+KSH 15.50",
      "status": "Completed"
    },
  ];
}
