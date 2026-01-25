/// Paginated List Widget.
///
/// Provides an efficient list implementation with pagination support,
/// proper memory management, and smooth scrolling performance.
library;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../loading/shimmer_loading.dart';

/// A paginated list with automatic loading and efficient memory usage.
///
/// Features:
/// - Automatic pagination when scrolling to bottom
/// - Pull-to-refresh support
/// - Loading indicators
/// - Error handling
/// - Memory-efficient with ListView.builder
///
/// Example:
/// ```dart
/// PaginatedListView<UserEntity>(
///   items: users,
///   isLoading: isLoadingMore,
///   hasMore: hasMoreUsers,
///   onLoadMore: () => loadMoreUsers(),
///   onRefresh: () => refreshUsers(),
///   itemBuilder: (context, user, index) => UserTile(user: user),
/// )
/// ```
class PaginatedListView<T> extends StatefulWidget {
  /// Creates a PaginatedListView.
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onRefresh,
    this.loadMoreThreshold = 200.0,
    this.padding,
    this.separatorBuilder,
    this.emptyWidget,
    this.errorWidget,
    this.loadingWidget,
    this.loadingMoreWidget,
    this.headerWidget,
    this.footerWidget,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
    this.itemExtent,
    this.cacheExtent,
  });

  /// List of items to display.
  final List<T> items;

  /// Builder for each item.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Whether currently loading more items.
  final bool isLoading;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Callback to load more items.
  final VoidCallback? onLoadMore;

  /// Callback to refresh the list.
  final Future<void> Function()? onRefresh;

  /// Distance from bottom to trigger loading more.
  final double loadMoreThreshold;

  /// Padding around the list.
  final EdgeInsets? padding;

  /// Builder for item separators.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Widget to show when list is empty.
  final Widget? emptyWidget;

  /// Widget to show on error.
  final Widget? errorWidget;

  /// Widget to show during initial loading.
  final Widget? loadingWidget;

  /// Widget to show when loading more items.
  final Widget? loadingMoreWidget;

  /// Widget to display above the list.
  final Widget? headerWidget;

  /// Widget to display below the list.
  final Widget? footerWidget;

  /// Scroll controller.
  final ScrollController? scrollController;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Whether to shrink wrap the list.
  final bool shrinkWrap;

  /// Whether to reverse the list.
  final bool reverse;

  /// Fixed item extent for better performance.
  final double? itemExtent;

  /// Cache extent for viewport.
  final double? cacheExtent;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _isInternalController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      _scrollController.removeListener(_onScroll);
      if (_isInternalController) {
        _scrollController.dispose();
      }

      if (widget.scrollController != null) {
        _scrollController = widget.scrollController!;
        _isInternalController = false;
      } else {
        _scrollController = ScrollController();
        _isInternalController = true;
      }
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_isInternalController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoading || widget.onLoadMore == null) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.isLoading) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    if (widget.items.isEmpty && widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? _buildDefaultEmpty();
    }

    final list = _buildList();

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: AppColors.primaryBlue,
        child: list,
      );
    }

    return list;
  }

  Widget _buildList() {
    // Calculate total item count including header/footer/loading
    int itemCount = widget.items.length;
    int headerOffset = widget.headerWidget != null ? 1 : 0;
    int footerOffset = 0;

    if (widget.footerWidget != null) footerOffset++;
    if (widget.hasMore && widget.isLoading) footerOffset++;
    if (widget.hasMore && !widget.isLoading && widget.items.isNotEmpty) {
      footerOffset++; // Space for "Load More" trigger
    }

    final totalCount = headerOffset + itemCount + footerOffset;

    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _scrollController,
        physics: widget.physics ?? const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        cacheExtent: widget.cacheExtent,
        itemCount: totalCount,
        separatorBuilder: (context, index) {
          // No separator for header/footer
          if (index < headerOffset || index >= headerOffset + itemCount - 1) {
            return const SizedBox.shrink();
          }
          return widget.separatorBuilder!(context, index - headerOffset);
        },
        itemBuilder: (context, index) =>
            _buildItem(context, index, headerOffset, itemCount),
      );
    }

    if (widget.itemExtent != null) {
      return ListView.builder(
        controller: _scrollController,
        physics: widget.physics ?? const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        cacheExtent: widget.cacheExtent,
        itemExtent: widget.itemExtent,
        itemCount: totalCount,
        itemBuilder: (context, index) =>
            _buildItem(context, index, headerOffset, itemCount),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics ?? const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      reverse: widget.reverse,
      cacheExtent: widget.cacheExtent,
      itemCount: totalCount,
      itemBuilder: (context, index) =>
          _buildItem(context, index, headerOffset, itemCount),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    int headerOffset,
    int itemCount,
  ) {
    // Header
    if (widget.headerWidget != null && index == 0) {
      return widget.headerWidget!;
    }

    // Items
    final itemIndex = index - headerOffset;
    if (itemIndex >= 0 && itemIndex < itemCount) {
      return widget.itemBuilder(
        context,
        widget.items[itemIndex],
        itemIndex,
      );
    }

    // Loading more indicator
    if (widget.hasMore && widget.isLoading) {
      return widget.loadingMoreWidget ?? _buildLoadingMore();
    }

    // Footer
    if (widget.footerWidget != null) {
      return widget.footerWidget!;
    }

    return const SizedBox.shrink();
  }

  Widget _buildDefaultLoading() {
    return const ShimmerList(itemCount: 5);
  }

  Widget _buildDefaultEmpty() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
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
    );
  }
}

/// A grid version of paginated list.
class PaginatedGridView<T> extends StatefulWidget {
  /// Creates a PaginatedGridView.
  const PaginatedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.gridDelegate,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onRefresh,
    this.loadMoreThreshold = 200.0,
    this.padding,
    this.emptyWidget,
    this.loadingWidget,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.cacheExtent,
  });

  /// List of items to display.
  final List<T> items;

  /// Builder for each item.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Grid delegate for layout.
  final SliverGridDelegate gridDelegate;

  /// Whether currently loading more items.
  final bool isLoading;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Callback to load more items.
  final VoidCallback? onLoadMore;

  /// Callback to refresh the list.
  final Future<void> Function()? onRefresh;

  /// Distance from bottom to trigger loading more.
  final double loadMoreThreshold;

  /// Padding around the grid.
  final EdgeInsets? padding;

  /// Widget to show when grid is empty.
  final Widget? emptyWidget;

  /// Widget to show during initial loading.
  final Widget? loadingWidget;

  /// Scroll controller.
  final ScrollController? scrollController;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Whether to shrink wrap the grid.
  final bool shrinkWrap;

  /// Cache extent for viewport.
  final double? cacheExtent;

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  late ScrollController _scrollController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _isInternalController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_isInternalController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoading || widget.onLoadMore == null) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.isLoading) {
      return widget.loadingWidget ?? const ShimmerGrid();
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? _buildDefaultEmpty();
    }

    final grid = GridView.builder(
      controller: _scrollController,
      physics: widget.physics ?? const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      cacheExtent: widget.cacheExtent,
      gridDelegate: widget.gridDelegate,
      itemCount: widget.items.length + (widget.hasMore && widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryBlue,
              ),
            ),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: AppColors.primaryBlue,
        child: grid,
      );
    }

    return grid;
  }

  Widget _buildDefaultEmpty() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A builder that provides pagination state for custom list implementations.
class PaginationBuilder<T> extends StatefulWidget {
  /// Creates a PaginationBuilder.
  const PaginationBuilder({
    super.key,
    required this.items,
    required this.builder,
    this.pageSize = 20,
    this.onLoadMore,
    this.scrollController,
  });

  /// All items (loaded so far).
  final List<T> items;

  /// Builder that receives pagination state.
  final Widget Function(
    BuildContext context,
    List<T> displayedItems,
    bool hasMore,
    bool isLoading,
    VoidCallback loadMore,
  ) builder;

  /// Number of items per page.
  final int pageSize;

  /// Callback to load more items.
  final Future<List<T>> Function()? onLoadMore;

  /// Scroll controller for detecting scroll position.
  final ScrollController? scrollController;

  @override
  State<PaginationBuilder<T>> createState() => _PaginationBuilderState<T>();
}

class _PaginationBuilderState<T> extends State<PaginationBuilder<T>> {
  bool _isLoading = false;
  bool _hasMore = true;

  void _loadMore() async {
    if (_isLoading || !_hasMore || widget.onLoadMore == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.onLoadMore!();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = newItems.length >= widget.pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.items,
      _hasMore,
      _isLoading,
      _loadMore,
    );
  }
}
