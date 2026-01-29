/// Saved SACCOs screen.
///
/// Displays and manages the user's favorite transport operators (SACCOs).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_sacco.dart';
import '../providers/preferences_providers.dart';
import '../widgets/saved_item_card.dart';

/// Screen for managing saved/favorite SACCOs.
class SavedSaccosScreen extends ConsumerWidget {
  /// Creates a saved SACCOs screen.
  const SavedSaccosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final saccosAsync = ref.watch(savedSaccosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved SACCOs'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(savedSaccosProvider.notifier).refresh(),
          ),
        ],
      ),
      body: saccosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, ref, error.toString()),
        data: (saccos) => saccos.isEmpty
            ? _buildEmptyState(context, isDark)
            : _buildSaccosList(context, ref, saccos),
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
              Icons.business_outlined,
              size: 80,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved SACCOs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Save your favorite transport operators for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Browse SACCOs and tap the star icon to save them here.',
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
              'Failed to load SACCOs',
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
              onPressed: () => ref.read(savedSaccosProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaccosList(
    BuildContext context,
    WidgetRef ref,
    List<SavedSacco> saccos,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sort by most recently used, then by saved date
    final sortedSaccos = List<SavedSacco>.from(saccos)
      ..sort((a, b) {
        if (a.lastUsedAt != null && b.lastUsedAt != null) {
          return b.lastUsedAt!.compareTo(a.lastUsedAt!);
        }
        if (a.lastUsedAt != null) return -1;
        if (b.lastUsedAt != null) return 1;
        return b.savedAt.compareTo(a.savedAt);
      });

    return RefreshIndicator(
      onRefresh: () => ref.read(savedSaccosProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${saccos.length} saved ${saccos.length == 1 ? 'SACCO' : 'SACCOs'}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedSaccos.map((sacco) => SavedSaccoCard(
                saccoName: sacco.displayName,
                description: sacco.description,
                logoUrl: sacco.logoUrl,
                routeCount: sacco.routeCount,
                onTap: () => _showSaccoOptions(context, ref, sacco),
                onDelete: () => ref
                    .read(savedSaccosProvider.notifier)
                    .removeSacco(sacco.saccoId),
              )),
        ],
      ),
    );
  }

  void _showSaccoOptions(BuildContext context, WidgetRef ref, SavedSacco sacco) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                child: Row(
                  children: [
                    if (sacco.hasLogo)
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(sacco.logoUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sacco.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (sacco.routeCount > 0)
                            Text(
                              '${sacco.routeCount} routes',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[500]
                                    : AppColors.textSecondary,
                              ),
                            ),
                        ],
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
                  _showEditNameDialog(context, ref, sacco);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('View SACCO Details'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to SACCO details
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SACCO details coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.route_outlined),
                title: const Text('View Routes'),
                subtitle: Text('${sacco.routeCount} routes available'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to SACCO routes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Route list coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Remove from Saved',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(savedSaccosProvider.notifier).removeSacco(sacco.saccoId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, SavedSacco sacco) {
    final controller = TextEditingController(text: sacco.customName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Custom Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Custom Name',
            hintText: 'Enter a custom name for this SACCO',
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
              ref.read(savedSaccosProvider.notifier).updateSacco(
                    sacco.copyWith(
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
