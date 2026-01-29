/// Passenger discovery feature barrel file.
///
/// Exports all discovery-related files for the passenger feature.
/// This feature handles Sacco (Organization) discovery for passengers.
///
/// Usage:
/// ```dart
/// import 'package:komiut/features/passenger/discovery/discovery.dart';
/// ```
library;

// Domain
export 'domain/entities/sacco.dart';

// Data - Models
export 'data/models/sacco_model.dart';

// Data - Datasources
export 'data/datasources/sacco_remote_datasource.dart';

// Data - Repositories
export 'data/repositories/sacco_repository.dart';

// Presentation - Providers
export 'presentation/providers/sacco_providers.dart';
