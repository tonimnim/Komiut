/// Destination Search - Search widget for finding routes by destination.
///
/// Provides a "Where to?" style search interface with autocomplete
/// suggestions from route stops and destinations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../providers/route_providers.dart';

/// Recent destinations storage provider.
///
/// Stores the user's recent destination searches.
final recentDestinationsProvider = StateProvider<List<String>>((ref) => []);

/// A destination search widget with autocomplete functionality.
///
/// Shows a "Where to?" search field with suggestions from route stops.
/// Also displays recent destination searches for quick access.
class DestinationSearch extends ConsumerStatefulWidget {
  /// Creates a DestinationSearch widget.
  const DestinationSearch({
    super.key,
    this.onDestinationSelected,
    this.placeholder = 'Where to?',
    this.showRecent = true,
    this.maxSuggestions = 5,
    this.maxRecent = 3,
  });

  /// Callback when a destination is selected.
  final void Function(String destination)? onDestinationSelected;

  /// Placeholder text for the search field.
  final String placeholder;

  /// Whether to show recent destinations.
  final bool showRecent;

  /// Maximum number of suggestions to show.
  final int maxSuggestions;

  /// Maximum number of recent destinations to show.
  final int maxRecent;

  @override
  ConsumerState<DestinationSearch> createState() => _DestinationSearchState();
}

class _DestinationSearchState extends ConsumerState<DestinationSearch> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showSuggestions = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destinationsAsync = ref.watch(routeDestinationsProvider);
    final recentDestinations = ref.watch(recentDestinationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.primaryBlue
                  : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              width: _focusNode.hasFocus ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Location icon
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),

              // Search field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    setState(() {
                      _currentQuery = value;
                    });
                  },
                  onSubmitted: _onDestinationSubmit,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : AppColors.textHint,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              // Clear button
              if (_currentQuery.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.grey[500] : AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _currentQuery = '';
                    });
                  },
                ),
            ],
          ),
        ),

        // Suggestions/Recent destinations dropdown
        if (_showSuggestions) ...[
          const SizedBox(height: 4),
          _buildSuggestionsDropdown(
            isDark,
            destinationsAsync,
            recentDestinations,
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionsDropdown(
    bool isDark,
    AsyncValue<List<String>> destinationsAsync,
    List<String> recentDestinations,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent destinations (only if query is empty)
            if (_currentQuery.isEmpty &&
                widget.showRecent &&
                recentDestinations.isNotEmpty) ...[
              _buildSectionHeader(isDark, 'Recent'),
              ...recentDestinations
                  .take(widget.maxRecent)
                  .map((dest) => _buildSuggestionTile(
                        isDark,
                        dest,
                        Icons.history,
                      )),
              if (recentDestinations.isNotEmpty)
                Divider(
                  height: 1,
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                ),
            ],

            // Suggestions
            destinationsAsync.when(
              data: (destinations) {
                final filtered = _filterDestinations(destinations);
                if (filtered.isEmpty && _currentQuery.isNotEmpty) {
                  return _buildNoResults(isDark);
                }

                if (_currentQuery.isEmpty) {
                  // Show popular destinations header
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(isDark, 'Popular destinations'),
                      ...destinations
                          .take(widget.maxSuggestions)
                          .map((dest) => _buildSuggestionTile(
                                isDark,
                                dest,
                                Icons.place_outlined,
                              )),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(isDark, 'Suggestions'),
                    ...filtered
                        .take(widget.maxSuggestions)
                        .map((dest) => _buildSuggestionTile(
                              isDark,
                              dest,
                              Icons.place_outlined,
                              highlight: _currentQuery,
                            )),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              error: (_, __) => _buildNoResults(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[500] : AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(
    bool isDark,
    String destination,
    IconData icon, {
    String? highlight,
  }) {
    return InkWell(
      onTap: () => _selectDestination(destination),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.grey[500] : AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: highlight != null
                  ? _buildHighlightedText(
                      destination,
                      highlight,
                      isDark,
                    )
                  : Text(
                      destination,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? Colors.grey[300] : AppColors.textPrimary,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String highlight,
    bool isDark,
  ) {
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final index = lowerText.indexOf(lowerHighlight);

    if (index < 0) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.grey[300] : AppColors.textPrimary,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.grey[300] : AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + highlight.length),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          TextSpan(text: text.substring(index + highlight.length)),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.search_off,
            size: 20,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Text(
            'No destinations found',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _filterDestinations(List<String> destinations) {
    if (_currentQuery.isEmpty) return destinations;

    final query = _currentQuery.toLowerCase();
    return destinations
        .where((dest) => dest.toLowerCase().contains(query))
        .toList();
  }

  void _selectDestination(String destination) {
    _controller.text = destination;
    setState(() {
      _currentQuery = destination;
      _showSuggestions = false;
    });
    _focusNode.unfocus();

    // Add to recent destinations
    final recent = ref.read(recentDestinationsProvider);
    if (!recent.contains(destination)) {
      ref.read(recentDestinationsProvider.notifier).state = [
        destination,
        ...recent.take(4),
      ];
    }

    // Update the filter state
    ref.read(routeFilterStateProvider.notifier).state =
        ref.read(routeFilterStateProvider).copyWith(
              destinationFilter: destination,
            );

    // Callback
    widget.onDestinationSelected?.call(destination);
  }

  void _onDestinationSubmit(String value) {
    if (value.isNotEmpty) {
      _selectDestination(value);
    }
  }
}
