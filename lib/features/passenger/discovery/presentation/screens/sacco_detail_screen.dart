/// Sacco Detail Screen - Displays detailed information about a Sacco.
///
/// Shows Sacco information including header, description, routes, and contact info.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../domain/entities/sacco.dart';
import '../providers/sacco_providers.dart';
import '../widgets/sacco_contact_card.dart';
import '../widgets/sacco_header.dart';
import '../widgets/sacco_routes_section.dart';

/// Screen displaying detailed information about a specific Sacco.
///
/// Includes:
/// - Header with logo, name, and status
/// - Description (if available)
/// - List of routes operated by the Sacco
/// - Contact information
///
/// ```dart
/// SaccoDetailScreen(saccoId: 'sacco-123')
/// ```
class SaccoDetailScreen extends ConsumerWidget {
  /// Creates a SaccoDetailScreen.
  const SaccoDetailScreen({
    required this.saccoId,
    super.key,
  });

  /// The unique identifier of the Sacco to display.
  final String saccoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saccoAsync = ref.watch(saccoByIdProvider(saccoId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: saccoAsync.when(
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, ref, error),
        data: (sacco) => _buildContent(context, sacco),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Sacco sacco) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            sacco.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: false,
        ),

        // Content
        SliverList(
          delegate: SliverChildListDelegate([
            // Header with logo, name, status
            SaccoHeader(
              name: sacco.name,
              logoUrl: sacco.logoUrl,
              isActive: sacco.isActive,
              routeCount: sacco.routeCount,
            ),

            // Description (if available)
            if (sacco.description != null && sacco.description!.isNotEmpty)
              _DescriptionSection(
                description: sacco.description!,
                isDark: isDark,
              ),

            const SizedBox(height: 8),

            // Routes section
            SaccoRoutesSection(saccoId: saccoId),

            const SizedBox(height: 8),

            // Contact section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Contact Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Contact card
            SaccoContactCard(
              phone: sacco.contactPhone,
              email: sacco.contactEmail,
              website: null, // Sacco entity doesn't have website field
            ),

            // Bottom spacing
            const SizedBox(height: 32),
          ]),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const ShimmerBox(width: 150, height: 24),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SaccoHeaderShimmer(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(height: 60),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(width: 120, height: 20),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ShimmerCard(height: 88, margin: EdgeInsets.zero),
                  SizedBox(height: 12),
                  ShimmerCard(height: 88, margin: EdgeInsets.zero),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(width: 150, height: 20),
            ),
            const SizedBox(height: 16),
            const ShimmerCard(height: 140),
          ]),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AppErrorWidget(
        title: 'Failed to load Sacco',
        message: 'We could not load the Sacco details. Please try again.',
        type: ErrorType.server,
        onRetry: () => ref.invalidate(saccoByIdProvider(saccoId)),
      ),
    );
  }
}

/// Description section widget.
class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.description,
    required this.isDark,
  });

  final String description;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'About',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
