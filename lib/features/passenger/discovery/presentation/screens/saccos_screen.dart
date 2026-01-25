/// SaccosScreen - Sacco discovery list screen.
///
/// Main screen for passengers to discover and browse saccos.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../../core/widgets/feedback/app_error.dart';
import '../providers/sacco_providers.dart';
import '../widgets/sacco_card.dart';
import '../widgets/sacco_filter_chips.dart';
import '../widgets/sacco_search_bar.dart';
import '../widgets/sacco_shimmer.dart';

/// Screen for discovering and browsing saccos.
class SaccosScreen extends ConsumerStatefulWidget {
  /// Creates a SaccosScreen.
  const SaccosScreen({super.key});

  @override
  ConsumerState<SaccosScreen> createState() => _SaccosScreenState();
}

class _SaccosScreenState extends ConsumerState<SaccosScreen> {
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final saccosAsync = ref.watch(activeSaccosProvider);
    final searchQuery = ref.watch(saccoSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchExpanded
            ? null
            : const Text('Discover Saccos'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isSearchExpanded)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = true;
                });
              },
            ),
          if (_isSearchExpanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 56),
                child: _buildExpandedSearchBar(isDark),
              ),
            ),
          if (_isSearchExpanded)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                });
                ref.read(saccoSearchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(saccosProvider);
        },
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Search bar (when not expanded in app bar)
            if (!_isSearchExpanded)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: SaccoSearchBar(),
                ),
              ),

            // Filter chips
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SaccoFilterChips(),
              ),
            ),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  searchQuery.isEmpty ? 'All Saccos' : 'Search Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

            // Content
            saccosAsync.when(
              data: (saccos) {
                if (saccos.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(searchQuery),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sacco = saccos[index];
                        return SaccoCard(
                          sacco: sacco,
                          onTap: () => _navigateToSaccoDetail(context, sacco.id),
                        );
                      },
                      childCount: saccos.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: SaccoListShimmer(),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSearchBar(bool isDark) {
    return TextField(
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        ref.read(saccoSearchQueryProvider.notifier).state = value;
      },
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Search saccos...',
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : AppColors.textHint,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      return AppEmptyState.noResults(
        title: 'No Saccos Found',
        message: 'Try adjusting your search or filters',
      );
    }

    return AppEmptyState.noItems(
      title: 'No Saccos Available',
      message: 'Check back later for available transport operators',
      illustration: Icon(
        Icons.business_outlined,
        size: 80,
        color: AppColors.textHint.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return AppErrorWidget(
      title: 'Failed to Load Saccos',
      message: 'Something went wrong. Please try again.',
      type: ErrorType.generic,
      onRetry: () {
        ref.invalidate(saccosProvider);
      },
    );
  }

  void _navigateToSaccoDetail(BuildContext context, String saccoId) {
    context.push('/passenger/sacco/$saccoId');
  }
}
