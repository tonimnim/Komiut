/// Auth feature barrel file.
///
/// Exports all auth-related files.
///
/// Usage:
/// ```dart
/// import 'package:komiut/features/auth/auth.dart';
/// ```
library;

// Domain
export 'domain/entities/user_entity.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/usecases/login_usecase.dart';
export 'domain/usecases/signup_usecase.dart';

// Data
export 'data/models/user_model.dart';
export 'data/datasources/auth_local_datasource.dart';
export 'data/repositories/auth_repository_impl.dart';

// Presentation - Screens
export 'presentation/screens/splash_screen.dart';
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/signup_screen.dart';
export 'presentation/screens/forgot_password_screen.dart';
export 'presentation/screens/two_factor_screen.dart';

// Presentation - Providers
export 'presentation/providers/auth_providers.dart';
export 'presentation/providers/auth_state_notifier.dart';
