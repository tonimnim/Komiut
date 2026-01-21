import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get appName => dotenv.env['APP_NAME'] ?? 'Komiut';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.komiut.com/v1';
  static int get apiTimeout => int.parse(dotenv.env['API_TIMEOUT'] ?? '30000');
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  static bool get enableMockData => dotenv.env['ENABLE_MOCK_DATA'] == 'true';
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING'] == 'true';
  
  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
}
