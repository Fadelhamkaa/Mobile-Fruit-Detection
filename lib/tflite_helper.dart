import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class TFLiteHelper {
  static const String _modelPath = 'assets/model.tflite';
  static const String _labelsPath = 'assets/labels.txt';

  static List<String> _labels = [];
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  // Initialize the TFLite model
  static Future<void> init() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    debugPrint('Initializing TFLite model...');

    try {
      // In a real app, you would load the model here
      // For now, we'll just simulate a successful initialization
      await Future.delayed(Duration(milliseconds: 500));

      // Load mock labels
      try {
        final labelTxt = await rootBundle.loadString(_labelsPath);
        _labels = labelTxt
            .split('\n')
            .map((label) => label.trim())
            .where((label) => label.isNotEmpty)
            .toList();
        debugPrint('Loaded ${_labels.length} labels');
      } catch (e) {
        debugPrint('Error loading labels: $e');
        _labels = ['Apple', 'Banana', 'Orange']; // Default labels
      }

      _isInitialized = true;
      debugPrint('TFLite model initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize TFLite model: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  // Classify an image file
  static Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    debugPrint('Starting image classification...');

    try {
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist: ${imageFile.path}');
        return {
          'label': 'Error',
          'confidence': 0.0,
          'error': 'Image file not found',
          'isMock': true,
        };
      }

      // Simulate processing time
      debugPrint('Processing image...');
      await Future.delayed(Duration(milliseconds: 500));

      // Generate a more realistic confidence score between 0.7 and 0.99
      final random = Random();
      final confidence = 0.7 + (random.nextDouble() * 0.29); // 0.7 - 0.99
      final labelIndex = random.nextInt(_labels.length);
      final label = _labels.isNotEmpty ? _labels[labelIndex] : 'Fruit';
      
      debugPrint('Classification complete. Result: $label (${confidence.toStringAsFixed(2)}%)');

      return <String, dynamic>{
        'label': label,
        'confidence': confidence,
        'isMock': true,
      };
    } catch (e) {
      debugPrint('Error during image classification: $e');
      return <String, dynamic>{
        'label': 'Error',
        'confidence': 0.0,
        'error': 'Classification failed: ${e.toString()}',
        'isMock': true,
      };
    }
  }

  // Clean up resources
  static void dispose() {
    _isInitialized = false;
  }

  // Check if the model is ready to use
  static bool get isReady => _isInitialized;
}
