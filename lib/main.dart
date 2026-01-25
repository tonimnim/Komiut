```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:komiut_app/core/config/app_config.dart';
import 'package:komiut_app/core/routes/app_router.dart';
import 'package:komiut_app/core/theme/app_theme.dart';
import 'package:komiut_app/di/injection_container.dart';
import 'package:komiut_app/core/theme/theme_bloc.dart';
import 'package:komiut_app/core/theme/theme_provider.dart';
import 'package:komiut_app/core/constants/app_constants.dart';
import 'features/queue/presentation/providers/notification_providers.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Keep splash screen visible while app initializes (unless skipping auth)
  if (!AppConfig.skipAuth) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  } else {
    FlutterNativeSplash.remove();
  }

  await dotenv.load(fileName: '.env');
  await initializeDependencies();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: BlocProvider(
        create: (context) => getIt<ThemeBloc>(),
        child: const KomiutApp(),
      ),
    ),
  );
}

class KomiutApp extends ConsumerWidget {
  const KomiutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider); // This line is kept as per instruction, but themeMode for MaterialApp.router comes from BlocBuilder
    final isDark = themeMode == ThemeMode.dark;
    final router = ref.watch(appRouterProvider);

    // Initialize notification service with router for navigation
    setNotificationRouter(router);
    // Initialize the notification service
    ref.read(notificationServiceProvider).initialize();

    // Set status bar style based on theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode, // Theme mode from Bloc
          routerConfig: router, // Router from Riverpod
        );
      },
    );
  }
}
```
