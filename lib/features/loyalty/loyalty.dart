/// Loyalty feature barrel file.
///
/// Exports all loyalty-related files for the loyalty feature.
/// This feature handles loyalty points, tiers, and rewards.
///
/// Usage:
/// ```dart
/// import 'package:komiut/features/loyalty/loyalty.dart';
/// ```
library;

// Domain - Entities
export 'domain/entities/loyalty_points.dart';

// Domain - Rules
export 'domain/loyalty_rules.dart';

// Data - Models
export 'data/models/loyalty_models.dart';

// Data - Datasources
export 'data/datasources/loyalty_remote_datasource.dart';

// Presentation - Providers
export 'presentation/providers/loyalty_providers.dart';

// Presentation - Screens
export 'presentation/screens/loyalty_screen.dart';

// Presentation - Widgets
export 'presentation/widgets/points_balance_card.dart';
export 'presentation/widgets/tier_progress_bar.dart';
export 'presentation/widgets/points_transaction_item.dart';
export 'presentation/widgets/redeem_points_sheet.dart';
export 'presentation/widgets/tier_benefits_card.dart';
