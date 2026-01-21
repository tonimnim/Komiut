import 'package:flutter/material.dart';

class ActiveTripsScreen extends StatelessWidget {
  const ActiveTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Trips')),
      body: const Center(child: Text('Active Trips List (Coming Soon)')),
    );
  }
}
