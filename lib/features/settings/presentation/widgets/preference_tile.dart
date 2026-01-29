/// Preference tile widget.
///
/// A reusable tile for displaying preference settings with optional
/// toggle switch, navigation arrow, or custom trailing widget.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Type of preference tile.
enum PreferenceTileType {
  /// Tile with a toggle switch.
  toggle,

  /// Tile with navigation arrow.
  navigation,

  /// Tile with custom trailing widget.
  custom,
}

/// A reusable preference row widget for settings screens.
///
/// Supports multiple tile types:
/// - Toggle: Shows a switch for boolean settings
/// - Navigation: Shows an arrow for navigation
/// - Custom: Shows any custom trailing widget
class PreferenceTile extends StatelessWidget {
  /// Creates a toggle preference tile.
  const PreferenceTile.toggle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  })  : _type = PreferenceTileType.toggle,
        _value = value,
        _onChanged = onChanged,
        _onTap = null,
        _trailing = null;

  /// Creates a navigation preference tile.
  const PreferenceTile.navigation({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required VoidCallback onTap,
  })  : _type = PreferenceTileType.navigation,
        _value = false,
        _onChanged = null,
        _onTap = onTap,
        _trailing = null;

  /// Creates a preference tile with custom trailing widget.
  const PreferenceTile.custom({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  })  : _type = PreferenceTileType.custom,
        _value = false,
        _onChanged = null,
        _onTap = onTap,
        _trailing = trailing;

  /// The leading icon.
  final IconData icon;

  /// The main title text.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  final PreferenceTileType _type;
  final bool _value;
  final ValueChanged<bool>? _onChanged;
  final VoidCallback? _onTap;
  final Widget? _trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildTrailing(context, isDark),
        ],
      ),
    );

    if (_type == PreferenceTileType.toggle) {
      return content;
    }

    return InkWell(
      onTap: _onTap,
      child: content,
    );
  }

  Widget _buildTrailing(BuildContext context, bool isDark) {
    switch (_type) {
      case PreferenceTileType.toggle:
        return Transform.scale(
          scale: 0.85,
          child: Switch(
            value: _value,
            onChanged: _onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        );

      case PreferenceTileType.navigation:
        return Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey[600] : AppColors.textHint,
        );

      case PreferenceTileType.custom:
        return _trailing ?? const SizedBox.shrink();
    }
  }
}

/// A section header for grouping preference tiles.
class PreferenceSection extends StatelessWidget {
  /// Creates a preference section.
  const PreferenceSection({
    super.key,
    required this.title,
    required this.children,
  });

  /// The section title.
  final String title;

  /// The preference tiles in this section.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: _buildChildrenWithDividers(isDark),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(bool isDark) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Divider(
          height: 1,
          color: isDark ? Colors.grey[800] : AppColors.divider,
        ));
      }
    }
    return result;
  }
}
