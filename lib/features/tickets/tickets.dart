/// Tickets feature barrel export.
///
/// Exports all public APIs for the tickets feature.
library;

// Domain
export 'domain/entities/ticket.dart';

// Data
export 'data/models/ticket_model.dart';
export 'data/datasources/ticket_remote_datasource.dart';

// Presentation - Providers
export 'presentation/providers/ticket_providers.dart';

// Presentation - Screens
export 'presentation/screens/ticket_screen.dart';
export 'presentation/screens/my_tickets_screen.dart';
export 'presentation/screens/boarding_confirmation_screen.dart';

// Presentation - Widgets
export 'presentation/widgets/ticket_qr_code.dart';
export 'presentation/widgets/ticket_card.dart';
export 'presentation/widgets/ticket_details.dart';
export 'presentation/widgets/ticket_status_badge.dart';
export 'presentation/widgets/boarding_success_animation.dart';
