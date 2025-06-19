import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About FruitLens')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'FruitLens',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'FruitLens is a mobile app that classifies images of fruits (Apple, Cherry, Tomato) using an on-device AI model. It provides nutritional information, recipe ideas, and keeps a local scan history.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 18),
            Text('Developer: Muhammad Fadel Hamka', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('Model credits: TFLite model for fruit classification', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
