import 'package:flutter/material.dart';

class SmoothieDetailsScreen extends StatelessWidget {
  const SmoothieDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smoothieId = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('Smoothie Details')),
      body: Center(
        child: Text('Smoothie details for ID: $smoothieId'),
      ),
    );
  }
}