import 'package:flutter/material.dart';
import 'fruit_data.dart';

class NutritionPage extends StatelessWidget {
  final String fruit;
  const NutritionPage({Key? key, required this.fruit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final details = fruitData[fruit]?['nutrition_details'] as Map<String, String>?;
    return Scaffold(
      appBar: AppBar(title: Text('$fruit Nutrition')),
      body: details == null
          ? const Center(child: Text('No nutrition data available.'))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: details.entries
                  .map((e) => ListTile(
                        title: Text(e.key),
                        trailing: Text(e.value),
                      ))
                  .toList(),
            ),
    );
  }
}
