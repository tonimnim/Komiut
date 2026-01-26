/// AppDialog - Dialog helper utilities.
///
/// Helper functions for showing consistent dialogs.
library;

import 'package:flutter/material.dart';

import '../buttons/app_button.dart';

/// Helper class for showing dialogs.
class AppDialog {
  const AppDialog._();

  /// Shows a confirmation dialog.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          AppButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
            variant: isDestructive
                ? ButtonVariant.primary
                : ButtonVariant.primary,
            size: ButtonSize.small,
            backgroundColor: isDestructive ? Colors.red : null,
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows an alert dialog.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  /// Shows a loading dialog.
  static Future<T> loading<T>(
    BuildContext context, {
    required Future<T> future,
    String message = 'Loading...',
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await future;
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  /// Shows an input dialog.
  static Future<String?> input(
    BuildContext context, {
    required String title,
    String? message,
    String? initialValue,
    String? hint,
    String confirmLabel = 'Submit',
    String cancelLabel = 'Cancel',
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message != null) ...[
                Text(message),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: controller,
                decoration: InputDecoration(hintText: hint),
                validator: validator,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// Shows a bottom sheet.
  static Future<T?> bottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => child,
    );
  }
}
