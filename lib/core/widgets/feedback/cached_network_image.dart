/// Cached Network Image - Image widget with offline fallback.
///
/// Provides an image widget that:
/// - Caches images for offline use
/// - Shows placeholder when loading
/// - Shows fallback when offline or error
/// - Supports fade-in animation
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../providers/connectivity_providers.dart';
import '../../theme/app_colors.dart';

/// Configuration for image caching.
class ImageCacheConfig {
  /// Creates image cache configuration.
  const ImageCacheConfig({
    this.maxCacheSize = 100 * 1024 * 1024, // 100 MB
    this.maxCacheAge = const Duration(days: 7),
    this.cacheDirectory = 'image_cache',
  });

  /// Maximum cache size in bytes.
  final int maxCacheSize;

  /// Maximum age of cached images.
  final Duration maxCacheAge;

  /// Directory name for cache.
  final String cacheDirectory;
}

/// Image cache manager for offline support.
class ImageCacheManager {
  /// Creates an image cache manager.
  ImageCacheManager({
    this.config = const ImageCacheConfig(),
  });

  /// Cache configuration.
  final ImageCacheConfig config;

  Directory? _cacheDir;
  bool _initialized = false;

  /// Initialize the cache manager.
  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/${config.cacheDirectory}');

    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }

    _initialized = true;

    // Clean old cache entries in background
    _cleanOldCache();
  }

  /// Get cached image bytes, or null if not cached.
  Future<Uint8List?> get(String url) async {
    await initialize();

    final file = _getCacheFile(url);
    if (await file.exists()) {
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);

      if (age < config.maxCacheAge) {
        return file.readAsBytes();
      } else {
        // Expired, delete
        await file.delete();
      }
    }

    return null;
  }

  /// Cache image bytes.
  Future<void> put(String url, Uint8List bytes) async {
    await initialize();

    final file = _getCacheFile(url);
    await file.writeAsBytes(bytes);
  }

  /// Check if image is cached.
  Future<bool> has(String url) async {
    await initialize();

    final file = _getCacheFile(url);
    return file.exists();
  }

  /// Clear all cache.
  Future<void> clear() async {
    await initialize();

    if (await _cacheDir!.exists()) {
      await _cacheDir!.delete(recursive: true);
      await _cacheDir!.create();
    }
  }

  File _getCacheFile(String url) {
    final hash = md5.convert(url.codeUnits).toString();
    return File('${_cacheDir!.path}/$hash');
  }

  Future<void> _cleanOldCache() async {
    try {
      final files = _cacheDir!.listSync();
      final now = DateTime.now();

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);

          if (age > config.maxCacheAge) {
            await entity.delete();
          }
        }
      }
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}

/// Provider for image cache manager.
final imageCacheManagerProvider = Provider<ImageCacheManager>((ref) {
  return ImageCacheManager();
});

/// A network image with caching and offline fallback.
///
/// ```dart
/// CachedNetworkImage(
///   imageUrl: 'https://example.com/image.jpg',
///   width: 100,
///   height: 100,
///   fit: BoxFit.cover,
/// )
/// ```
class CachedNetworkImage extends ConsumerStatefulWidget {
  /// Creates a cached network image.
  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.headers,
    this.cacheKey,
  });

  /// URL of the image to load.
  final String imageUrl;

  /// Width constraint.
  final double? width;

  /// Height constraint.
  final double? height;

  /// How to fit the image.
  final BoxFit fit;

  /// Widget to show while loading.
  final Widget? placeholder;

  /// Widget to show on error.
  final Widget? errorWidget;

  /// Duration of fade-in animation.
  final Duration fadeInDuration;

  /// Duration of fade-out animation.
  final Duration fadeOutDuration;

  /// Border radius for clipping.
  final BorderRadius? borderRadius;

  /// HTTP headers for request.
  final Map<String, String>? headers;

  /// Custom cache key (defaults to URL).
  final String? cacheKey;

  @override
  ConsumerState<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends ConsumerState<CachedNetworkImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    final cacheManager = ref.read(imageCacheManagerProvider);
    final cacheKey = widget.cacheKey ?? widget.imageUrl;

    // Try cache first
    try {
      final cached = await cacheManager.get(cacheKey);
      if (cached != null) {
        if (mounted) {
          setState(() {
            _imageBytes = cached;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      // Cache error, continue to network
    }

    // Check if online
    final isOnline = ref.read(isOnlineStateProvider);

    if (!isOnline) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Offline';
        });
      }
      return;
    }

    // Load from network
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(widget.imageUrl));

      if (widget.headers != null) {
        widget.headers!.forEach((key, value) {
          request.headers.add(key, value);
        });
      }

      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await _consolidateHttpClientResponse(response);

        // Cache the image
        await cacheManager.put(cacheKey, bytes);

        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<Uint8List> _consolidateHttpClientResponse(
    HttpClientResponse response,
  ) async {
    final chunks = <List<int>>[];
    await for (final chunk in response) {
      chunks.add(chunk);
    }
    final totalLength = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final result = Uint8List(totalLength);
    var offset = 0;
    for (final chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = widget.placeholder ?? _DefaultPlaceholder(
        width: widget.width,
        height: widget.height,
      );
    } else if (_hasError || _imageBytes == null) {
      content = widget.errorWidget ?? _DefaultErrorWidget(
        width: widget.width,
        height: widget.height,
        isOffline: _errorMessage == 'Offline',
      );
    } else {
      content = AnimatedOpacity(
        duration: widget.fadeInDuration,
        opacity: 1.0,
        child: Image.memory(
          _imageBytes!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stack) {
            return widget.errorWidget ?? _DefaultErrorWidget(
              width: widget.width,
              height: widget.height,
            );
          },
        ),
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  const _DefaultPlaceholder({
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({
    this.width,
    this.height,
    this.isOffline = false,
  });

  final double? width;
  final double? height;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.cloud_off_rounded : Icons.broken_image_outlined,
              size: 32,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            if (isOffline) ...[
              const SizedBox(height: 4),
              Text(
                'Offline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A circular cached network image (for avatars).
///
/// ```dart
/// CachedCircleAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   radius: 24,
/// )
/// ```
class CachedCircleAvatar extends StatelessWidget {
  /// Creates a cached circle avatar.
  const CachedCircleAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  /// URL of the avatar image.
  final String imageUrl;

  /// Radius of the circle.
  final double radius;

  /// Placeholder widget.
  final Widget? placeholder;

  /// Error widget.
  final Widget? errorWidget;

  /// Background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return ClipOval(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: bgColor,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: placeholder ?? _CirclePlaceholder(radius: radius),
          errorWidget: errorWidget ?? _CircleError(radius: radius),
        ),
      ),
    );
  }
}

class _CirclePlaceholder extends StatelessWidget {
  const _CirclePlaceholder({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: radius * 0.5,
          height: radius * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleError extends StatelessWidget {
  const _CircleError({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.3),
            AppColors.primaryGreen.withValues(alpha: 0.3),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: radius,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
