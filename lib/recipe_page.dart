import 'package:flutter/material.dart';
import 'fruit_data.dart';

class RecipePage extends StatelessWidget {
  final String fruit;
  const RecipePage({Key? key, required this.fruit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipes = fruitData[fruit]?['recipes'] as List<dynamic>?;
    return Scaffold(
      appBar: AppBar(title: Text('$fruit Recipes')),
      body: recipes == null
          ? const Center(child: Text('No recipes available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(recipe['title'] ?? ''),
                    subtitle: Text(recipe['description'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
