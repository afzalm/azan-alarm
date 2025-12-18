/// Qibla compass screen

import 'package:flutter/material.dart';

class QiblaCompassScreen extends StatelessWidget {
  const QiblaCompassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compass_calibration,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              'Qibla Compass',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}