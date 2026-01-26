/// Performance Guidelines for Komiut App.
///
/// This file documents performance optimization patterns and best practices
/// used throughout the app. Refer to this for guidance when building new
/// features or optimizing existing code.
///
/// ## Table of Contents
/// 1. [Widget Optimization](#widget-optimization)
/// 2. [List Performance](#list-performance)
/// 3. [Image Handling](#image-handling)
/// 4. [Provider Optimization](#provider-optimization)
/// 5. [Memory Management](#memory-management)
/// 6. [Search & Filter](#search--filter)
///
/// ---
///
/// ## Widget Optimization
///
/// ### Use const constructors
/// ```dart
/// // Good
/// const SizedBox(height: 16),
/// const Text('Static text'),
///
/// // Bad - creates new instance on each build
/// SizedBox(height: 16),
/// Text('Static text'),
/// ```
///
/// ### Extract static widgets
/// ```dart
/// // Good - separate widget class
/// class _StaticHeader extends StatelessWidget {
///   const _StaticHeader();
///   // ...
/// }
///
/// // Bad - inline widget that rebuilds with parent
/// Widget _buildHeader() => Container(...);
/// ```
///
/// ### Use RepaintBoundary for complex widgets
/// ```dart
/// RepaintBoundary(
///   child: ComplexAnimatedWidget(),
/// )
/// ```
///
/// ### Use ValueKey for lists
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) => WidgetItem(
///     key: ValueKey(items[index].id),
///     item: items[index],
///   ),
/// )
/// ```
///
/// ---
///
/// ## List Performance
///
/// ### Always use ListView.builder
/// ```dart
/// // Good
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) => ItemWidget(item: items[index]),
/// )
///
/// // Bad - builds all items at once
/// ListView(
///   children: items.map((item) => ItemWidget(item: item)).toList(),
/// )
/// ```
///
/// ### Use itemExtent when items have fixed height
/// ```dart
/// ListView.builder(
///   itemExtent: 72.0, // Fixed height improves scroll performance
///   itemBuilder: (context, index) => FixedHeightItem(),
/// )
/// ```
///
/// ### Disable automatic keep-alives for long lists
/// ```dart
/// ListView.builder(
///   addAutomaticKeepAlives: false,
///   addRepaintBoundaries: true,
///   itemBuilder: (context, index) => Item(),
/// )
/// ```
///
/// ### Use PaginatedListView for large datasets
/// ```dart
/// PaginatedListView<Item>(
///   items: items,
///   hasMore: hasMoreItems,
///   onLoadMore: loadMoreItems,
///   itemBuilder: (context, item, index) => ItemWidget(item: item),
/// )
/// ```
///
/// ---
///
/// ## Image Handling
///
/// ### Use OptimizedImage for network images
/// ```dart
/// OptimizedImage(
///   imageUrl: url,
///   width: 200,
///   height: 150,
///   cacheWidth: 400, // 2x for retina
///   cacheHeight: 300,
/// )
/// ```
///
/// ### Use ThumbnailImage for lists
/// ```dart
/// ThumbnailImage(
///   imageUrl: url,
///   width: 80,
///   height: 80,
/// )
/// ```
///
/// ### Preload images before navigation
/// ```dart
/// await preloadImages(context, imageUrls);
/// Navigator.push(...);
/// ```
///
/// ---
///
/// ## Provider Optimization
///
/// ### Use select for granular updates
/// ```dart
/// // Good - only rebuilds when name changes
/// final userName = ref.watch(userProvider.select((u) => u?.name));
///
/// // Bad - rebuilds on any user change
/// final user = ref.watch(userProvider);
/// final userName = user?.name;
/// ```
///
/// ### Use autoDispose for transient data
/// ```dart
/// final searchResultsProvider = FutureProvider.autoDispose<List<Result>>((ref) async {
///   return await api.search(query);
/// });
/// ```
///
/// ### Cache expensive computations
/// ```dart
/// final cachedDataProvider = Provider<CachedProvider<Data>>((ref) {
///   return CachedProvider(
///     duration: Duration(minutes: 5),
///     provider: (ref) => fetchData(),
///   );
/// });
/// ```
///
/// ---
///
/// ## Memory Management
///
/// ### Dispose controllers properly
/// ```dart
/// class _MyWidgetState extends State<MyWidget> {
///   late TextEditingController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = TextEditingController();
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
/// }
/// ```
///
/// ### Cancel subscriptions
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with SubscriptionManager {
///   @override
///   void initState() {
///     super.initState();
///     addSubscription(stream.listen(handleEvent));
///   }
///
///   @override
///   void dispose() {
///     cancelAllSubscriptions();
///     super.dispose();
///   }
/// }
/// ```
///
/// ### Clear caches on low memory
/// ```dart
/// MemoryAwareWidget(
///   onLowMemory: () {
///     clearImageCache();
///     AppCacheManager.instance.clearAllCaches();
///   },
///   child: MyApp(),
/// )
/// ```
///
/// ---
///
/// ## Search & Filter
///
/// ### Use debouncing for search inputs
/// ```dart
/// final _searchDebouncer = Debouncer(milliseconds: 300);
///
/// void _onSearchChanged(String query) {
///   _searchDebouncer.run(() {
///     performSearch(query);
///   });
/// }
/// ```
///
/// ### Use throttling for scroll events
/// ```dart
/// final _scrollThrottler = Throttler(milliseconds: 100);
///
/// void _onScroll(double position) {
///   _scrollThrottler.run(() {
///     updateScrollIndicator(position);
///   });
/// }
/// ```
///
/// ---
///
/// ## Related Files
///
/// - `lib/core/utils/debounce.dart` - Debouncing utilities
/// - `lib/core/utils/throttle.dart` - Throttling utilities
/// - `lib/core/utils/performance_utils.dart` - Memoization and caching
/// - `lib/core/utils/memory_utils.dart` - Memory management helpers
/// - `lib/core/widgets/images/optimized_image.dart` - Optimized image widgets
/// - `lib/core/widgets/layout/lazy_load_widget.dart` - Lazy loading widgets
/// - `lib/core/widgets/lists/paginated_list.dart` - Paginated list widgets
/// - `lib/core/providers/provider_utils.dart` - Provider optimization helpers
library;

// This file is documentation only - no code exports.
// Import the actual utilities from their respective files.
