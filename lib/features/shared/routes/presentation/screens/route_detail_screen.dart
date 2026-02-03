import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../providers/route_providers.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (route == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: Text('Route not found')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          route.name,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Route summary card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.routeSummary,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${route.formattedFare} · ${route.formattedDuration} · ${route.stopsCount} stops',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stops header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Stops',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stops timeline
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              itemCount: route.stops.length,
              itemBuilder: (context, index) {
                final stop = route.stops[index];
                final isFirst = index == 0;
                final isLast = index == route.stops.length - 1;

                return _StopTile(
                  name: stop,
                  isFirst: isFirst,
                  isLast: isLast,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Route selection coming soon'),
                  backgroundColor: AppColors.primaryBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Select This Route',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  final String name;
  final bool isFirst;
  final bool isLast;

  const _StopTile({
    required this.name,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        SizedBox(
          width: 24,
          child: Column(
            children: [
              // Top line
              Container(
                width: 2,
                height: 8,
                color: isFirst
                    ? Colors.transparent
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
              // Dot
              Container(
                width: isFirst || isLast ? 12 : 8,
                height: isFirst || isLast ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst || isLast
                      ? AppColors.primaryBlue
                      : (isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
              // Bottom line
              Container(
                width: 2,
                height: 32,
                color: isLast
                    ? Colors.transparent
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Stop name
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    isFirst || isLast ? FontWeight.w600 : FontWeight.normal,
                color: isFirst || isLast
                    ? theme.colorScheme.onSurface
                    : (isDark ? Colors.grey[400] : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
