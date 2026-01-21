import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:komiut_app/core/config/app_config.dart';
import 'package:komiut_app/core/routes/app_router.dart';
import 'package:komiut_app/core/theme/app_theme.dart';
import 'package:komiut_app/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  
  await initializeDependencies();
  
  runApp(const KomiutApp());
}

class KomiutApp extends StatelessWidget {
  const KomiutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
