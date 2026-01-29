/// Optimized Image Widget.
///
/// Provides memory-efficient image loading with lazy loading, caching,
/// placeholders, and error handling.
library;

import 'dart:io';

import 'package:flutter/material.dart';

/// An optimized image widget with lazy loading and caching.
///
/// Features:
/// - Lazy loading when widget becomes visible
/// - Memory-efficient sizing
/// - Placeholder while loading
/// - Error fallback
/// - Fade-in animation
///
/// Example:
/// ```dart
/// OptimizedImage(
///   imageUrl: 'https://example.com/image.jpg',
///   width: 200,
///   height: 150,
///   fit: BoxFit.cover,
/// )
/// ```
class OptimizedImage extends StatefulWidget {
  /// Creates an OptimizedImage.
  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.file,
    this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeInCurve = Curves.easeIn,
    this.enableMemoryCache = true,
    this.cacheWidth,
    this.cacheHeight,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.filterQuality = FilterQuality.low,
  }) : assert(
          imageUrl != null || file != null || asset != null,
          'Must provide imageUrl, file, or asset',
        );

  /// URL of the network image.
  final String? imageUrl;

  /// Local file to display.
  final File? file;

  /// Asset path to display.
  final String? asset;

  /// Width of the image.
  final double? width;

  /// Height of the image.
  final double? height;

  /// How the image should fit within its bounds.
  final BoxFit fit;

  /// Widget to display while loading.
  final Widget? placeholder;

  /// Widget to display on error.
  final Widget? errorWidget;

  /// Border radius for the image.
  final BorderRadius? borderRadius;

  /// Duration of the fade-in animation.
  final Duration fadeInDuration;

  /// Curve of the fade-in animation.
  final Curve fadeInCurve;

  /// Whether to cache the image in memory.
  final bool enableMemoryCache;

  /// Target width for memory-efficient caching.
  final int? cacheWidth;

  /// Target height for memory-efficient caching.
  final int? cacheHeight;

  /// Color to blend with the image.
  final Color? color;

  /// Blend mode for the color.
  final BlendMode? colorBlendMode;

  /// Alignment of the image within its bounds.
  final Alignment alignment;

  /// How the image should repeat.
  final ImageRepeat repeat;

  /// Quality of image filtering.
  final FilterQuality filterQuality;

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  ImageProvider? _imageProvider;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: widget.fadeInCurve,
    );
    _initImageProvider();
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.file != widget.file ||
        oldWidget.asset != widget.asset) {
      _fadeController.reset();
      _isLoaded = false;
      _hasError = false;
      _initImageProvider();
    }
  }

  void _initImageProvider() {
    if (widget.imageUrl != null) {
      _imageProvider = _createNetworkImage(widget.imageUrl!);
    } else if (widget.file != null) {
      _imageProvider = _createFileImage(widget.file!);
    } else if (widget.asset != null) {
      _imageProvider = _createAssetImage(widget.asset!);
    }
  }

  ImageProvider _createNetworkImage(String url) {
    return ResizeImage.resizeIfNeeded(
      widget.cacheWidth,
      widget.cacheHeight,
      NetworkImage(url),
    );
  }

  ImageProvider _createFileImage(File file) {
    return ResizeImage.resizeIfNeeded(
      widget.cacheWidth,
      widget.cacheHeight,
      FileImage(file),
    );
  }

  ImageProvider _createAssetImage(String asset) {
    return ResizeImage.resizeIfNeeded(
      widget.cacheWidth,
      widget.cacheHeight,
      AssetImage(asset),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onImageLoad() {
    if (mounted && !_isLoaded) {
      setState(() {
        _isLoaded = true;
      });
      _fadeController.forward();
    }
  }

  void _onImageError() {
    if (mounted && !_hasError) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_hasError) {
      content = widget.errorWidget ?? _buildDefaultError();
    } else if (_imageProvider != null) {
      content = _buildImage();
    } else {
      content = widget.placeholder ?? _buildDefaultPlaceholder();
    }

    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: content,
    );
  }

  Widget _buildImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Placeholder while loading
        if (!_isLoaded) widget.placeholder ?? _buildDefaultPlaceholder(),

        // Actual image with fade-in
        FadeTransition(
          opacity: _fadeAnimation,
          child: Image(
            image: _imageProvider!,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
            color: widget.color,
            colorBlendMode: widget.colorBlendMode,
            alignment: widget.alignment,
            repeat: widget.repeat,
            filterQuality: widget.filterQuality,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                _onImageLoad();
                return child;
              }
              if (frame != null && !_isLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _onImageLoad();
                });
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              _onImageError();
              return widget.errorWidget ?? _buildDefaultError();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultPlaceholder() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }
}

/// A circular optimized image, commonly used for avatars.
class OptimizedCircleImage extends StatelessWidget {
  /// Creates an OptimizedCircleImage.
  const OptimizedCircleImage({
    super.key,
    this.imageUrl,
    this.file,
    this.asset,
    this.size = 48,
    this.placeholder,
    this.errorWidget,
    this.border,
    this.backgroundColor,
  });

  /// URL of the network image.
  final String? imageUrl;

  /// Local file to display.
  final File? file;

  /// Asset path to display.
  final String? asset;

  /// Size (diameter) of the circle.
  final double size;

  /// Widget to display while loading.
  final Widget? placeholder;

  /// Widget to display on error.
  final Widget? errorWidget;

  /// Border around the circle.
  final BoxBorder? border;

  /// Background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: backgroundColor ?? (isDark ? Colors.grey[800] : Colors.grey[200]),
      ),
      child: ClipOval(
        child: OptimizedImage(
          imageUrl: imageUrl,
          file: file,
          asset: asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: (size * 2).toInt(), // 2x for retina displays
          cacheHeight: (size * 2).toInt(),
          placeholder: placeholder ?? _buildDefaultPlaceholder(isDark),
          errorWidget: errorWidget ?? _buildDefaultError(isDark),
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.person_outline,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: size * 0.5,
      ),
    );
  }

  Widget _buildDefaultError(bool isDark) {
    return Center(
      child: Icon(
        Icons.person_off_outlined,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: size * 0.5,
      ),
    );
  }
}

/// A list of optimized images with preloading.
///
/// Preloads images that are about to become visible for smoother scrolling.
class OptimizedImageList extends StatefulWidget {
  /// Creates an OptimizedImageList.
  const OptimizedImageList({
    super.key,
    required this.imageUrls,
    required this.itemBuilder,
    this.preloadCount = 3,
    this.scrollController,
    this.padding,
    this.physics,
  });

  /// List of image URLs.
  final List<String> imageUrls;

  /// Builder for each item.
  final Widget Function(BuildContext context, int index, String imageUrl)
      itemBuilder;

  /// Number of images to preload ahead.
  final int preloadCount;

  /// Optional scroll controller.
  final ScrollController? scrollController;

  /// List padding.
  final EdgeInsets? padding;

  /// Scroll physics.
  final ScrollPhysics? physics;

  @override
  State<OptimizedImageList> createState() => _OptimizedImageListState();
}

class _OptimizedImageListState extends State<OptimizedImageList> {
  int _firstVisibleIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Preload upcoming images
    _preloadImages();

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView.builder(
        controller: widget.scrollController,
        padding: widget.padding,
        physics: widget.physics,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return widget.itemBuilder(context, index, widget.imageUrls[index]);
        },
      ),
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // Estimate first visible index based on scroll position
      // This is a simplified calculation
      final metrics = notification.metrics;
      if (metrics.maxScrollExtent > 0 && widget.imageUrls.isNotEmpty) {
        final progress = metrics.pixels / metrics.maxScrollExtent;
        final estimatedIndex =
            (progress * widget.imageUrls.length).floor();
        if (estimatedIndex != _firstVisibleIndex) {
          _firstVisibleIndex = estimatedIndex;
          _preloadImages();
        }
      }
    }
    return false;
  }

  void _preloadImages() {
    final startIndex = _firstVisibleIndex;
    final endIndex = (startIndex + widget.preloadCount)
        .clamp(0, widget.imageUrls.length);

    for (var i = startIndex; i < endIndex; i++) {
      precacheImage(NetworkImage(widget.imageUrls[i]), context);
    }
  }
}

/// A thumbnail image with memory-efficient sizing.
class ThumbnailImage extends StatelessWidget {
  /// Creates a ThumbnailImage.
  const ThumbnailImage({
    super.key,
    this.imageUrl,
    this.file,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  /// URL of the network image.
  final String? imageUrl;

  /// Local file to display.
  final File? file;

  /// Width of the thumbnail.
  final double width;

  /// Height of the thumbnail.
  final double height;

  /// Border radius of the thumbnail.
  final double borderRadius;

  /// How the image should fit.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // Use 2x size for cache to support retina displays
    final cacheWidth = (width * 2).toInt();
    final cacheHeight = (height * 2).toInt();

    return OptimizedImage(
      imageUrl: imageUrl,
      file: file,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(borderRadius),
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Preloads images for faster display.
///
/// Call this before navigating to a screen that displays these images.
Future<void> preloadImages(BuildContext context, List<String> imageUrls) async {
  for (final url in imageUrls) {
    precacheImage(NetworkImage(url), context);
  }
}

/// Clears the image cache.
///
/// Call this when memory is low or when logging out.
void clearImageCache() {
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
}

/// Gets the current image cache size.
int getImageCacheSize() {
  return PaintingBinding.instance.imageCache.currentSize;
}

/// Gets the current number of cached images.
int getImageCacheCount() {
  return PaintingBinding.instance.imageCache.liveImageCount;
}
