/// Saved routes screen.
///
/// Displays and manages the user's favorite routes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_route.dart';
import '../providers/preferences_providers.dart';
import '../widgets/saved_item_card.dart';

/// Screen for managing saved/favorite routes.
class SavedRoutesScreen extends ConsumerWidget {
  /// Creates a saved routes screen.
  const SavedRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final routesAsync = ref.watch(savedRoutesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Routes'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(savedRoutesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: routesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, ref, error.toString()),
        data: (routes) => routes.isEmpty
            ? _buildEmptyState(context, isDark)
            : _buildRoutesList(context, ref, routes),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route_outlined,
              size: 80,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Routes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Save your favorite routes for quick access when booking trips.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tap the heart icon on any route to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[600] : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load routes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(savedRoutesProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutesList(
    BuildContext context,
    WidgetRef ref,
    List<SavedRoute> routes,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sort by most recently used, then by saved date
    final sortedRoutes = List<SavedRoute>.from(routes)
      ..sort((a, b) {
        if (a.lastUsedAt != null && b.lastUsedAt != null) {
          return b.lastUsedAt!.compareTo(a.lastUsedAt!);
        }
        if (a.lastUsedAt != null) return -1;
        if (b.lastUsedAt != null) return 1;
        return b.savedAt.compareTo(a.savedAt);
      });

    return RefreshIndicator(
      onRefresh: () => ref.read(savedRoutesProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${routes.length} saved ${routes.length == 1 ? 'route' : 'routes'}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedRoutes.map((route) => SavedRouteCard(
                routeName: route.routeName,
                startPoint: route.startPoint,
                endPoint: route.endPoint,
                customName: route.customName,
                useCount: route.useCount,
                onTap: () => _showRouteOptions(context, ref, route),
                onDelete: () => ref
                    .read(savedRoutesProvider.notifier)
                    .removeRoute(route.routeId),
              )),
        ],
      ),
    );
  }

  void _showRouteOptions(
      BuildContext context, WidgetRef ref, SavedRoute route) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route.summary,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Custom Name'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditNameDialog(context, ref, route);
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions),
                title: const Text('View Route Details'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to route details
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Route details coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Remove from Saved',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(savedRoutesProvider.notifier)
                      .removeRoute(route.routeId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, WidgetRef ref, SavedRoute route) {
    final controller = TextEditingController(text: route.customName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Custom Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Custom Name',
            hintText: 'Enter a custom name for this route',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              ref.read(savedRoutesProvider.notifier).updateRoute(
                    route.copyWith(
                      customName: newName.isEmpty ? null : newName,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
