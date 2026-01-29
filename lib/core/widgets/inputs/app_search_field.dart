/// AppSearchField - Search input component.
///
/// A search field with clear button and search icon.
library;

import 'package:flutter/material.dart';

/// A search input field with clear functionality.
class AppSearchField extends StatefulWidget {
  /// Creates an AppSearchField.
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
  });

  /// Text controller.
  final TextEditingController? controller;

  /// Hint text.
  final String hint;

  /// Callback when text changes.
  final void Function(String)? onChanged;

  /// Callback when search is submitted.
  final void Function(String)? onSubmitted;

  /// Callback when clear button is pressed.
  final VoidCallback? onClear;

  /// Whether to autofocus.
  final bool autofocus;

  /// Whether the field is enabled.
  final bool enabled;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: _clear,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
