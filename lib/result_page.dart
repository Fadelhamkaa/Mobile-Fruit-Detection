import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'nutrition_page.dart';
import 'recipe_page.dart';
import 'fruit_data.dart';
import 'providers/history_provider.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ResultPage({
    Key? key,
    required this.imagePath,
    required this.result,
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final DateTime scanTime;
  
  @override
  void initState() {
    super.initState();
    scanTime = DateTime.now();
    // Save to history when the page is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveToHistory();
    });
  }

  Future<void> _saveToHistory() async {
    try {
      final historyProvider = Provider.of<HistoryProvider>(
        context, 
        listen: false,
      );
      
      final double? confidence = double.tryParse(widget.result['confidence']?.toString() ?? '0.0');
      
      await historyProvider.addScan(
        imagePath: widget.imagePath,
        label: widget.result['label']?.toString() ?? 'Unknown',
        date: scanTime,
        confidence: confidence,
      );
    } catch (e) {
      debugPrint('Error saving to history: $e');
      // Don't show error to user as this is a background operation
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, y - HH:mm').format(scanTime);
    final fruitName = widget.result['label'] as String;
    final confidence = widget.result['confidence'] as String;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification Result'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              
              // Result Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Fruit Name
                      Text(
                        fruitName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Confidence
                      Text(
                        'Confidence: $confidence%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Scan Time
                      Text(
                        'Scanned on: $formattedDate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nutrition Summary
                      if (fruitData.containsKey(fruitName))
                        Text(
                          fruitData[fruitName]!['nutrition_summary']!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NutritionPage(fruit: fruitName),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Nutrition Info',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipePage(fruit: fruitName),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.green[700]!),
                ),
                child: Text(
                  'View Recipes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
