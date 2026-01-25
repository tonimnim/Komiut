/// AppScaffold - Standard scaffold wrapper.
///
/// A scaffold with consistent styling and common features.
library;

import 'package:flutter/material.dart';

/// A scaffold wrapper with consistent styling.
class AppScaffold extends StatelessWidget {
  /// Creates an AppScaffold.
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.showBackButton = true,
  });

  /// Body content.
  final Widget body;

  /// Custom app bar.
  final PreferredSizeWidget? appBar;

  /// App bar title (if no custom appBar).
  final String? title;

  /// App bar actions.
  final List<Widget>? actions;

  /// App bar leading widget.
  final Widget? leading;

  /// Floating action button.
  final Widget? floatingActionButton;

  /// Bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Drawer.
  final Widget? drawer;

  /// Background color.
  final Color? backgroundColor;

  /// Whether to resize body when keyboard appears.
  final bool resizeToAvoidBottomInset;

  /// Whether to extend body behind app bar.
  final bool extendBodyBehindAppBar;

  /// Whether to show back button (when canPop).
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final effectiveAppBar = appBar ??
        (title != null
            ? AppBar(
                title: Text(title!),
                actions: actions,
                leading: leading,
                automaticallyImplyLeading: showBackButton,
              )
            : null);

    return Scaffold(
      appBar: effectiveAppBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
