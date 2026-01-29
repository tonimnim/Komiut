/// SaccoSearchBar - Search widget for filtering saccos.
///
/// Provides debounced search functionality for the sacco list.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../providers/sacco_providers.dart';

/// A search bar widget for searching saccos.
class SaccoSearchBar extends ConsumerStatefulWidget {
  /// Creates a SaccoSearchBar.
  const SaccoSearchBar({
    super.key,
    this.hint = 'Search saccos...',
    this.autofocus = false,
  });

  /// Hint text for the search field.
  final String hint;

  /// Whether to autofocus the search field.
  final bool autofocus;

  @override
  ConsumerState<SaccoSearchBar> createState() => _SaccoSearchBarState();
}

class _SaccoSearchBarState extends ConsumerState<SaccoSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(saccoSearchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(saccoSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchQuery = ref.watch(saccoSearchQueryProvider);
    final hasText = searchQuery.isNotEmpty || _controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : AppColors.textHint,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[500] : AppColors.textHint,
            size: 22,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.grey[500] : AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
