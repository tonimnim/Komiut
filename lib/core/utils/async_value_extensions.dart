/// AsyncValue Extensions - Helper extensions for Riverpod AsyncValue in UI.
///
/// Provides convenient methods for handling loading, error, and data states
/// in widgets when using Riverpod's AsyncValue.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failures.dart';
import '../widgets/feedback/app_error.dart';
import '../widgets/feedback/app_loading.dart';
import 'error_handler.dart';

/// Extension on [AsyncValue] for enhanced UI building.
extension AsyncValueX<T> on AsyncValue<T> {
  /// Build a widget based on the AsyncValue state with enhanced options.
  ///
  /// Similar to the built-in `when` method, but with additional features:
  /// - Optional skip loading on refresh behavior
  /// - Automatic error message extraction
  ///
  /// ```dart
  /// asyncValue.when2(
  ///   data: (data) => DataWidget(data),
  ///   loading: () => LoadingWidget(),
  ///   error: (error, stack) => ErrorWidget(error),
  ///   skipLoadingOnRefresh: () => CachedDataWidget(),
  /// )
  /// ```
  Widget when2({
    required Widget Function(T data) data,
    required Widget Function() loading,
    required Widget Function(Object error, StackTrace? stack) error,
    Widget Function(T? previousData)? skipLoadingOnRefresh,
  }) {
    if (isLoading) {
      // Check if we should skip loading on refresh
      if (skipLoadingOnRefresh != null && hasValue) {
        return skipLoadingOnRefresh(valueOrNull);
      }
      return loading();
    }

    if (hasError) {
      return error(this.error!, stackTrace);
    }

    return data(value as T);
  }

  /// Build a widget with shimmer loading instead of a spinner.
  ///
  /// ```dart
  /// asyncValue.whenWithShimmer(
  ///   data: (data) => DataList(data),
  ///   shimmer: ShimmerList(),
  ///   error: (error) => ErrorWidget(error),
  /// )
  /// ```
  Widget whenWithShimmer({
    required Widget Function(T data) data,
    required Widget shimmer,
    required Widget Function(Object error) error,
    Widget Function(T? previousData)? skipLoadingOnRefresh,
  }) {
    if (isLoading) {
      // On refresh, show previous data with subtle loading indicator
      if (skipLoadingOnRefresh != null && hasValue) {
        return skipLoadingOnRefresh(valueOrNull);
      }
      return shimmer;
    }

    if (hasError) {
      return error(this.error!);
    }

    return data(value as T);
  }

  /// Build a widget with app-standard loading and error widgets.
  ///
  /// Uses the app's standard loading spinner and error display.
  ///
  /// ```dart
  /// asyncValue.whenStandard(
  ///   data: (data) => DataWidget(data),
  ///   onRetry: () => ref.refresh(myProvider),
  /// )
  /// ```
  Widget whenStandard({
    required Widget Function(T data) data,
    VoidCallback? onRetry,
    String? loadingMessage,
    String? errorTitle,
  }) {
    if (isLoading) {
      return AppLoading(message: loadingMessage);
    }

    if (hasError) {
      final failure = error is Failure ? error as Failure : null;
      final message = failure != null
          ? ErrorHandler.getMessage(failure)
          : error?.toString() ?? 'An error occurred';

      return AppErrorWidget(
        title: errorTitle ?? 'Error',
        message: message,
        onRetry: onRetry,
        type: failure != null
            ? _failureToErrorType(failure)
            : ErrorType.generic,
      );
    }

    return data(value as T);
  }

  /// Build a widget that handles empty data states.
  ///
  /// Shows an empty state widget when the data is an empty collection.
  ///
  /// ```dart
  /// asyncValue.whenWithEmpty(
  ///   data: (items) => ItemList(items),
  ///   empty: () => EmptyState.noItems(),
  ///   loading: () => LoadingWidget(),
  ///   error: (error) => ErrorWidget(error),
  /// )
  /// ```
  Widget whenWithEmpty({
    required Widget Function(T data) data,
    required Widget Function() empty,
    required Widget Function() loading,
    required Widget Function(Object error) error,
    bool Function(T data)? isEmpty,
  }) {
    if (isLoading) {
      return loading();
    }

    if (hasError) {
      return error(this.error!);
    }

    final value = this.value as T;
    final isDataEmpty = isEmpty?.call(value) ?? _isCollectionEmpty(value);

    if (isDataEmpty) {
      return empty();
    }

    return data(value);
  }

  /// Build a widget with shimmer loading and empty state support.
  ///
  /// Combines shimmer loading with empty state handling.
  ///
  /// ```dart
  /// asyncValue.whenWithShimmerAndEmpty(
  ///   data: (items) => ItemList(items),
  ///   shimmer: ShimmerList(),
  ///   empty: AppEmptyState.noItems(),
  ///   error: (error) => ErrorWidget(error),
  /// )
  /// ```
  Widget whenWithShimmerAndEmpty({
    required Widget Function(T data) data,
    required Widget shimmer,
    required Widget empty,
    required Widget Function(Object error) error,
    bool Function(T data)? isEmpty,
  }) {
    if (isLoading) {
      return shimmer;
    }

    if (hasError) {
      return error(this.error!);
    }

    final value = this.value as T;
    final isDataEmpty = isEmpty?.call(value) ?? _isCollectionEmpty(value);

    if (isDataEmpty) {
      return empty;
    }

    return data(value);
  }

  /// Convert any error to a user-friendly message.
  String get errorMessage {
    if (!hasError) return '';

    final err = error;
    if (err is Failure) {
      return ErrorHandler.getMessage(err);
    }
    return err?.toString() ?? 'An error occurred';
  }

  /// Check if the error is retryable.
  bool get isRetryable {
    if (!hasError) return false;

    final err = error;
    if (err is Failure) {
      return ErrorHandler.isRetryable(err);
    }
    return true; // Default to retryable for unknown errors
  }

  /// Get the error category.
  ErrorCategory get errorCategory {
    if (!hasError) return ErrorCategory.unknown;

    final err = error;
    if (err is Failure) {
      return ErrorHandler.getErrorCategory(err);
    }
    return ErrorCategory.unknown;
  }

  /// Check if a value is an empty collection.
  bool _isCollectionEmpty(T value) {
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    if (value is String) return value.isEmpty;
    return false;
  }

  /// Convert a Failure to an ErrorType.
  ErrorType _failureToErrorType(Failure failure) {
    if (failure is NetworkFailure) return ErrorType.network;
    if (failure is AuthenticationFailure) return ErrorType.unauthorized;
    if (failure is ServerFailure) {
      if (failure.statusCode == 404) return ErrorType.notFound;
      return ErrorType.server;
    }
    return ErrorType.generic;
  }
}

/// Extension on [AsyncValue] for list-specific operations.
extension AsyncValueListX<T> on AsyncValue<List<T>> {
  /// Build a list view with loading, error, and empty states.
  ///
  /// ```dart
  /// asyncValue.buildList(
  ///   itemBuilder: (context, item, index) => ListTile(title: Text(item.name)),
  ///   shimmer: ShimmerList(),
  ///   emptyState: AppEmptyState.noItems(),
  ///   onRetry: () => ref.refresh(myProvider),
  /// )
  /// ```
  Widget buildList({
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    required Widget shimmer,
    required Widget emptyState,
    VoidCallback? onRetry,
    Widget Function(BuildContext, int)? separatorBuilder,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    return whenWithShimmerAndEmpty(
      data: (items) => ListView.separated(
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: items.length,
        separatorBuilder: separatorBuilder ??
            (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => itemBuilder(context, items[index], index),
      ),
      shimmer: shimmer,
      empty: emptyState,
      error: (error) => AppErrorWidget(
        title: 'Error',
        message: error is Failure ? ErrorHandler.getMessage(error) : error.toString(),
        onRetry: onRetry,
        type: error is Failure
            ? _failureToErrorType(error)
            : ErrorType.generic,
      ),
    );
  }

  /// Convert a Failure to an ErrorType.
  ErrorType _failureToErrorType(Failure failure) {
    if (failure is NetworkFailure) return ErrorType.network;
    if (failure is AuthenticationFailure) return ErrorType.unauthorized;
    if (failure is ServerFailure) {
      if (failure.statusCode == 404) return ErrorType.notFound;
      return ErrorType.server;
    }
    return ErrorType.generic;
  }
}

/// Extension for nullable AsyncValue handling.
extension AsyncValueNullableX<T> on AsyncValue<T?> {
  /// Build a widget that handles null data as empty state.
  ///
  /// ```dart
  /// asyncValue.whenWithNullEmpty(
  ///   data: (data) => DataWidget(data),
  ///   empty: AppEmptyState.noItems(),
  ///   loading: () => LoadingWidget(),
  ///   error: (error) => ErrorWidget(error),
  /// )
  /// ```
  Widget whenWithNullEmpty({
    required Widget Function(T data) data,
    required Widget empty,
    required Widget Function() loading,
    required Widget Function(Object error) error,
  }) {
    if (isLoading) {
      return loading();
    }

    if (hasError) {
      return error(this.error!);
    }

    final value = this.value;
    if (value == null) {
      return empty;
    }

    return data(value);
  }
}
