/// Shimmer Loading - Reusable shimmer loading components.
///
/// Provides shimmer effect placeholders for various UI patterns.
library;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Base shimmer container widget with animated gradient effect.
///
/// Use this as a building block for custom shimmer layouts.
class ShimmerBox extends StatefulWidget {
  /// Creates a ShimmerBox.
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
    this.baseColor,
    this.highlightColor,
  });

  /// Width of the shimmer box. Defaults to full width if null.
  final double? width;

  /// Height of the shimmer box.
  final double height;

  /// Border radius of the shimmer box.
  final double borderRadius;

  /// Base color of the shimmer effect.
  final Color? baseColor;

  /// Highlight color of the shimmer effect.
  final Color? highlightColor;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = widget.baseColor ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade300);
    final highlightColor = widget.highlightColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A circular shimmer placeholder.
class ShimmerCircle extends StatelessWidget {
  /// Creates a ShimmerCircle.
  const ShimmerCircle({
    super.key,
    this.size = 48,
  });

  /// Diameter of the circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

/// Shimmer loading placeholder for list tile items.
///
/// Mimics the structure of a typical list tile with leading icon,
/// title, and subtitle.
class ShimmerListTile extends StatelessWidget {
  /// Creates a ShimmerListTile.
  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.hasTrailing = false,
    this.leadingSize = 40,
    this.padding,
  });

  /// Whether to show a leading placeholder.
  final bool hasLeading;

  /// Whether to show a subtitle placeholder.
  final bool hasSubtitle;

  /// Whether to show a trailing placeholder.
  final bool hasTrailing;

  /// Size of the leading placeholder.
  final double leadingSize;

  /// Padding around the tile.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading) ...[
            ShimmerCircle(size: leadingSize),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 16, width: 150),
                if (hasSubtitle) ...[
                  const SizedBox(height: 8),
                  const ShimmerBox(height: 12, width: 100),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16),
            const ShimmerBox(width: 40, height: 16),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder for card components.
///
/// Provides a card-like container with shimmer content.
/// Adapts content based on available height.
class ShimmerCard extends StatelessWidget {
  /// Creates a ShimmerCard.
  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius = 12,
  });

  /// Height of the card.
  final double height;

  /// Width of the card. Defaults to full width if null.
  final double? width;

  /// Padding inside the card.
  final EdgeInsets? padding;

  /// Margin outside the card.
  final EdgeInsets? margin;

  /// Border radius of the card.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectivePadding = padding ?? const EdgeInsets.all(16);
    final innerHeight = height - effectivePadding.vertical;

    return Container(
      height: height,
      width: width,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildContent(innerHeight),
    );
  }

  Widget _buildContent(double innerHeight) {
    // Simple layout for small cards
    if (innerHeight < 80) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FractionallySizedBox(
            widthFactor: 0.7,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 16),
          ),
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 14),
          ),
        ],
      );
    }

    // Standard layout for medium cards
    if (innerHeight < 120) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FractionallySizedBox(
            widthFactor: 0.8,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 18),
          ),
          FractionallySizedBox(
            widthFactor: 0.6,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 14),
          ),
          FractionallySizedBox(
            widthFactor: 0.4,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 14),
          ),
        ],
      );
    }

    // Full layout for larger cards
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: 0.8,
              alignment: Alignment.centerLeft,
              child: const ShimmerBox(height: 18),
            ),
            const SizedBox(height: 12),
            FractionallySizedBox(
              widthFactor: 0.6,
              alignment: Alignment.centerLeft,
              child: const ShimmerBox(height: 14),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: ShimmerBox(height: 14)),
            SizedBox(width: 16),
            ShimmerBox(height: 32, width: 70, borderRadius: 16),
          ],
        ),
      ],
    );
  }
}

/// Shimmer loading placeholder for wallet/balance cards.
///
/// Mimics a typical wallet card layout with balance display.
class ShimmerWalletCard extends StatelessWidget {
  /// Creates a ShimmerWalletCard.
  const ShimmerWalletCard({
    super.key,
    this.height = 160,
  });

  /// Height of the wallet card.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBoxLight(height: 14, width: 100),
          SizedBox(height: 8),
          _ShimmerBoxLight(height: 32, width: 150),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBoxLight(height: 12, width: 60),
                  SizedBox(height: 4),
                  _ShimmerBoxLight(height: 14, width: 100),
                ],
              ),
              _ShimmerBoxLight(height: 40, width: 40, borderRadius: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Light variant shimmer box for dark backgrounds.
class _ShimmerBoxLight extends StatefulWidget {
  const _ShimmerBoxLight({
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<_ShimmerBoxLight> createState() => _ShimmerBoxLightState();
}

class _ShimmerBoxLightState extends State<_ShimmerBoxLight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.4),
                Colors.white.withValues(alpha: 0.2),
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer loading placeholder for trip history items.
///
/// Mimics a trip card with origin/destination and details.
class ShimmerTripCard extends StatelessWidget {
  /// Creates a ShimmerTripCard.
  const ShimmerTripCard({
    super.key,
    this.margin,
  });

  /// Margin around the card.
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and status row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(height: 12, width: 80),
              ShimmerBox(height: 24, width: 70, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          // Origin/destination
          Row(
            children: [
              Column(
                children: [
                  const ShimmerCircle(size: 12),
                  Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const ShimmerCircle(size: 12),
                ],
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14, width: 140),
                    SizedBox(height: 20),
                    ShimmerBox(height: 14, width: 160),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bottom row - price and details
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(height: 16, width: 60),
              ShimmerBox(height: 12, width: 80),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading for a list of items.
///
/// Displays multiple shimmer list tiles.
class ShimmerList extends StatelessWidget {
  /// Creates a ShimmerList.
  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
    this.separatorBuilder,
  });

  /// Number of shimmer items to display.
  final int itemCount;

  /// Custom builder for shimmer items.
  final Widget Function(BuildContext, int)? itemBuilder;

  /// Custom separator builder.
  final Widget Function(BuildContext, int)? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder:
          separatorBuilder ?? (context, index) => const Divider(height: 1),
      itemBuilder: itemBuilder ?? (context, index) => const ShimmerListTile(),
    );
  }
}

/// Shimmer loading for a grid of cards.
class ShimmerGrid extends StatelessWidget {
  /// Creates a ShimmerGrid.
  const ShimmerGrid({
    super.key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.padding,
  });

  /// Number of shimmer items to display.
  final int itemCount;

  /// Number of columns in the grid.
  final int crossAxisCount;

  /// Aspect ratio of each grid item.
  final double childAspectRatio;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// Padding around the grid.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerCard(
        height: double.infinity,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
