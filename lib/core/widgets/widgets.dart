/// Widgets barrel file.
///
/// Exports all shared widget components for easy importing.
///
/// Usage:
/// ```dart
/// import 'package:komiut/core/widgets/widgets.dart';
/// ```
library;

// ─────────────────────────────────────────────────────────────────────────────
// Animations
// ─────────────────────────────────────────────────────────────────────────────

export 'animations/exports.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────────

export 'buttons/app_button.dart';
export 'buttons/app_icon_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────

export 'inputs/app_text_field.dart';
export 'inputs/app_dropdown.dart';
export 'inputs/app_search_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cards
// ─────────────────────────────────────────────────────────────────────────────

export 'cards/app_card.dart';
export 'cards/info_card.dart';
export 'cards/stat_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Feedback
// ─────────────────────────────────────────────────────────────────────────────

export 'feedback/app_loading.dart';
export 'feedback/app_error.dart';
export 'feedback/app_empty_state.dart';
export 'feedback/app_snackbar.dart';
export 'feedback/app_dialog.dart';
export 'feedback/network_error_screen.dart';
export 'feedback/offline_banner.dart';
export 'feedback/offline_aware_button.dart';
export 'feedback/cached_network_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────────────────────────────────────

export 'loading/shimmer_loading.dart';
export 'loading/loading_overlay.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Lists
// ─────────────────────────────────────────────────────────────────────────────

export 'lists/app_list_tile.dart';
export 'lists/app_section_header.dart';
export 'lists/app_divider.dart';
export 'lists/paginated_list.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Layout
// ─────────────────────────────────────────────────────────────────────────────

export 'layout/app_scaffold.dart';
export 'layout/lazy_load_widget.dart';
export 'layout/responsive_builder.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Images
// ─────────────────────────────────────────────────────────────────────────────

export 'images/optimized_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Legacy widgets (for backwards compatibility)
// ─────────────────────────────────────────────────────────────────────────────

export 'custom_button.dart';
export 'custom_text_field.dart';
export 'bottom_nav_bar.dart';
export 'main_app_shell.dart';
export 'main_navigation.dart';
export 'loading_widget.dart';
export 'error_widget.dart';
export 'empty_state_widget.dart';
export 'app_list_tile.dart' hide AppListTile; // Hide to avoid conflict
export 'app_tab_bar.dart';
export 'list_state_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Navigation
// ─────────────────────────────────────────────────────────────────────────────

export 'navigation/navigation.dart';
