import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class MainAppShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainAppShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  void _onNavTap(int index) {
    if (index == widget.currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/activity');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/payments');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
