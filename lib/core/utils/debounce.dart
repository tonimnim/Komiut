/// Debounce utility for rate-limiting function calls.
///
/// Provides debouncing functionality to delay function execution until
/// a specified time has passed since the last call. Useful for search
/// inputs and other user interactions.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// A debouncer that delays function execution.
///
/// Commonly used for search inputs to avoid making API calls on every
/// keystroke. The function is only executed after the specified duration
/// has passed since the last call.
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 300);
///
/// void onSearchChanged(String query) {
///   debouncer.run(() {
///     performSearch(query);
///   });
/// }
/// ```
class Debouncer {
  /// Creates a Debouncer with the specified delay in milliseconds.
  Debouncer({
    this.milliseconds = 300,
  });

  /// The delay duration in milliseconds.
  final int milliseconds;

  Timer? _timer;

  /// Runs the provided action after the debounce delay.
  ///
  /// Any pending action from a previous call is cancelled.
  void run(VoidCallback action) {
    cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Runs the provided async action after the debounce delay.
  ///
  /// Any pending action from a previous call is cancelled.
  void runAsync(Future<void> Function() action) {
    cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      action();
    });
  }

  /// Cancels any pending debounced action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether a debounced action is pending.
  bool get isPending => _timer?.isActive ?? false;

  /// Disposes the debouncer and cancels any pending action.
  void dispose() {
    cancel();
  }
}

/// A debouncer that returns a Future for async operations.
///
/// Unlike [Debouncer], this returns a Future that completes when the
/// debounced action is executed. Useful when you need to await the result.
///
/// Example:
/// ```dart
/// final debouncer = AsyncDebouncer<List<SearchResult>>(milliseconds: 300);
///
/// Future<List<SearchResult>> search(String query) async {
///   return debouncer.run(() => api.search(query));
/// }
/// ```
class AsyncDebouncer<T> {
  /// Creates an AsyncDebouncer with the specified delay.
  AsyncDebouncer({
    this.milliseconds = 300,
  });

  /// The delay duration in milliseconds.
  final int milliseconds;

  Timer? _timer;
  Completer<T>? _completer;

  /// Runs the provided async action after the debounce delay.
  ///
  /// Returns a Future that completes with the action's result.
  /// Any pending action from a previous call is cancelled.
  Future<T> run(Future<T> Function() action) {
    // Cancel previous timer
    _timer?.cancel();

    // Complete previous completer with error if pending
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(
        DebounceCancelledException('Debounce cancelled by new request'),
      );
    }

    _completer = Completer<T>();
    final currentCompleter = _completer!;

    _timer = Timer(Duration(milliseconds: milliseconds), () async {
      if (!currentCompleter.isCompleted) {
        try {
          final result = await action();
          if (!currentCompleter.isCompleted) {
            currentCompleter.complete(result);
          }
        } catch (e, s) {
          if (!currentCompleter.isCompleted) {
            currentCompleter.completeError(e, s);
          }
        }
      }
    });

    return currentCompleter.future;
  }

  /// Cancels any pending debounced action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(
        DebounceCancelledException('Debounce manually cancelled'),
      );
    }
    _completer = null;
  }

  /// Disposes the debouncer.
  void dispose() {
    cancel();
  }
}

/// Exception thrown when a debounced operation is cancelled.
class DebounceCancelledException implements Exception {
  /// Creates a DebounceCancelledException.
  const DebounceCancelledException([this.message]);

  /// The exception message.
  final String? message;

  @override
  String toString() =>
      message ?? 'DebounceCancelledException: Operation was cancelled';
}

/// Extension for easy debouncing on functions.
extension DebouncedFunction on Function {
  /// Creates a debounced version of this function.
  ///
  /// Example:
  /// ```dart
  /// final debouncedSearch = search.debounced(milliseconds: 300);
  /// debouncedSearch('query');
  /// ```
  void Function(T) debounced<T>(
    void Function(T) original, {
    int milliseconds = 300,
  }) {
    final debouncer = Debouncer(milliseconds: milliseconds);
    return (T arg) => debouncer.run(() => original(arg));
  }
}

/// A search debouncer specifically for text input.
///
/// Provides additional functionality like minimum query length filtering.
class SearchDebouncer {
  /// Creates a SearchDebouncer.
  SearchDebouncer({
    this.milliseconds = 300,
    this.minQueryLength = 0,
    this.onSearch,
  });

  /// The delay duration in milliseconds.
  final int milliseconds;

  /// Minimum query length before triggering search.
  final int minQueryLength;

  /// Callback when search should be performed.
  final void Function(String query)? onSearch;

  final Debouncer _debouncer = Debouncer();
  String _lastQuery = '';

  /// Called when the search query changes.
  void onQueryChanged(String query) {
    _lastQuery = query;

    if (query.length < minQueryLength) {
      _debouncer.cancel();
      return;
    }

    _debouncer.run(() {
      if (_lastQuery == query) {
        onSearch?.call(query);
      }
    });
  }

  /// Gets the last query.
  String get lastQuery => _lastQuery;

  /// Cancels any pending search.
  void cancel() {
    _debouncer.cancel();
  }

  /// Disposes the debouncer.
  void dispose() {
    _debouncer.dispose();
  }
}
