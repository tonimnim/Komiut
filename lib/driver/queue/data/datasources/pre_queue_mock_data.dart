class PreQueueMockData {
  static const String routeName = "Route 402 - Downtown";
  static const String serviceType = "Express Service";
  static const String queuePosition = "3rd in line";
  static const String waitTime = "8 mins";
  static const double progress = 0.6;
  
  static const List<Map<String, String>> stats = [
    {"label": "AVAILABLE", "value": "12 seats", "icon": "seats"},
    {"label": "FIXED FARE", "value": "KSH 2.50", "icon": "money"},
    {"label": "DEPARTURE", "value": "5 mins", "icon": "time"},
  ];

  static const List<Map<String, String>> activeVehicles = [
    {
      "id": "#BUS-4021",
      "status": "In 3 min",
      "location": "Approaching Kenyatta Avenue",
      "icon": "bus"
    }
  ];
}
