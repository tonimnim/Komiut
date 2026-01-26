/// Staggered List - Staggered list item animations.
///
/// Provides animated list views with staggered item entrance animations.
library;

import 'package:flutter/material.dart';

import '../../utils/animation_utils.dart';
import 'slide_in_widget.dart';

/// An animated list that staggers item entrance animations.
class StaggeredList extends StatefulWidget {
  /// Creates a StaggeredList.
  const StaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = AnimationDurations.normal,
    this.direction = SlideInDirection.bottom,
    this.slideOffset = 0.2,
    this.separatorBuilder,
    this.reverse = false,
  });

  /// Number of items in the list.
  final int itemCount;

  /// Builder for list items.
  final Widget Function(BuildContext, int) itemBuilder;

  /// Scroll controller.
  final ScrollController? controller;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Whether the list should shrink-wrap.
  final bool shrinkWrap;

  /// Delay between each item's animation.
  final Duration staggerDelay;

  /// Duration of each item's animation.
  final Duration itemDuration;

  /// Direction items slide in from.
  final SlideInDirection direction;

  /// Offset for the slide animation.
  final double slideOffset;

  /// Optional separator builder.
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Whether to reverse the list.
  final bool reverse;

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList> {
  @override
  Widget build(BuildContext context) {
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: widget.controller,
        physics: widget.physics,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        itemCount: widget.itemCount,
        separatorBuilder: widget.separatorBuilder!,
        itemBuilder: (context, index) => _StaggeredItem(
          index: index,
          staggerDelay: widget.staggerDelay,
          duration: widget.itemDuration,
          direction: widget.direction,
          slideOffset: widget.slideOffset,
          child: widget.itemBuilder(context, index),
        ),
      );
    }

    return ListView.builder(
      controller: widget.controller,
      physics: widget.physics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      reverse: widget.reverse,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => _StaggeredItem(
        index: index,
        staggerDelay: widget.staggerDelay,
        duration: widget.itemDuration,
        direction: widget.direction,
        slideOffset: widget.slideOffset,
        child: widget.itemBuilder(context, index),
      ),
    );
  }
}

/// An animated sliver list that staggers item entrance animations.
class SliverStaggeredList extends StatelessWidget {
  /// Creates a SliverStaggeredList.
  const SliverStaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = AnimationDurations.normal,
    this.direction = SlideInDirection.bottom,
    this.slideOffset = 0.2,
  });

  /// Number of items in the list.
  final int itemCount;

  /// Builder for list items.
  final Widget Function(BuildContext, int) itemBuilder;

  /// Delay between each item's animation.
  final Duration staggerDelay;

  /// Duration of each item's animation.
  final Duration itemDuration;

  /// Direction items slide in from.
  final SlideInDirection direction;

  /// Offset for the slide animation.
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _StaggeredItem(
          index: index,
          staggerDelay: staggerDelay,
          duration: itemDuration,
          direction: direction,
          slideOffset: slideOffset,
          child: itemBuilder(context, index),
        ),
        childCount: itemCount,
      ),
    );
  }
}

/// An animated grid with staggered item entrance animations.
class StaggeredGrid extends StatelessWidget {
  /// Creates a StaggeredGrid.
  const StaggeredGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = AnimationDurations.normal,
    this.direction = SlideInDirection.bottom,
    this.slideOffset = 0.2,
  });

  /// Number of items in the grid.
  final int itemCount;

  /// Builder for grid items.
  final Widget Function(BuildContext, int) itemBuilder;

  /// Grid delegate.
  final SliverGridDelegate gridDelegate;

  /// Scroll controller.
  final ScrollController? controller;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Padding around the grid.
  final EdgeInsetsGeometry? padding;

  /// Whether the grid should shrink-wrap.
  final bool shrinkWrap;

  /// Delay between each item's animation.
  final Duration staggerDelay;

  /// Duration of each item's animation.
  final Duration itemDuration;

  /// Direction items slide in from.
  final SlideInDirection direction;

  /// Offset for the slide animation.
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      physics: physics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) => _StaggeredItem(
        index: index,
        staggerDelay: staggerDelay,
        duration: itemDuration,
        direction: direction,
        slideOffset: slideOffset,
        child: itemBuilder(context, index),
      ),
    );
  }
}

/// Internal widget for staggered animation per item.
class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({
    required this.index,
    required this.child,
    required this.staggerDelay,
    required this.duration,
    required this.direction,
    required this.slideOffset,
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;
  final Duration duration;
  final SlideInDirection direction;
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    return SlideAndFadeIn(
      direction: direction,
      duration: duration,
      delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
      slideOffset: slideOffset,
      child: child,
    );
  }
}

/// A widget that animates adding/removing items in a list.
class AnimatedListItem extends StatelessWidget {
  /// Creates an AnimatedListItem.
  const AnimatedListItem({
    super.key,
    required this.animation,
    required this.child,
    this.direction = SlideInDirection.right,
    this.slideOffset = 1.0,
  });

  /// The animation to drive this item.
  final Animation<double> animation;

  /// The child widget.
  final Widget child;

  /// Direction to slide from.
  final SlideInDirection direction;

  /// Slide offset multiplier.
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    final begin = _getBeginOffset();

    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: AnimationCurves.fastOutSlowIn),
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  Offset _getBeginOffset() {
    switch (direction) {
      case SlideInDirection.left:
        return Offset(-slideOffset, 0.0);
      case SlideInDirection.right:
        return Offset(slideOffset, 0.0);
      case SlideInDirection.top:
        return Offset(0.0, -slideOffset);
      case SlideInDirection.bottom:
        return Offset(0.0, slideOffset);
    }
  }
}
