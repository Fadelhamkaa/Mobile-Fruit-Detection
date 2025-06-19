import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'result_page.dart';
import 'history_page.dart';
import 'providers/history_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Mock classification function
  Future<Map<String, dynamic>> _classifyImage(File imageFile) async {
    // Simulate model loading time
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock classification based on filename for testing
    final fileName = imageFile.path.split(Platform.pathSeparator).last.toLowerCase();
    String label = 'Apple'; // Default
    double confidence = 0.95;
    
    if (fileName.contains('cherry')) {
      label = 'Cherry';
      confidence = 0.93;
    } else if (fileName.contains('tomato')) {
      label = 'Tomato';
      confidence = 0.91;
    }
    
    return {
      'label': label,
      'confidence': (confidence * 100).toStringAsFixed(2),
      'isMock': true, // Flag to indicate this is a mock result
    };
  }

  Future<void> _pickImage(ImageSource source) async {
    // On Windows, only allow gallery
    if (Platform.isWindows && source == ImageSource.camera) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera is not supported on Windows. Please use gallery instead.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        debugPrint('No image selected');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final imageFile = File(pickedFile.path);
      debugPrint('Image selected: ${imageFile.path}');

      // Classify the image
      final result = await _classifyImage(imageFile);
      debugPrint('Classification result: $result');

      // Save to history
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      await historyProvider.addScan(
        imagePath: imageFile.path,
        label: result['label'] as String,
        date: DateTime.now(),
        confidence: double.tryParse(result['confidence'] as String) ?? 0.0,
      );

      // Navigate to result page
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            imagePath: imageFile.path,
            result: result,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error picking/classifying image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 30),
          label: Text(label, style: const TextStyle(fontSize: 18)),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit Classifier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Select an image to classify',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                      if (!Platform.isWindows) // Only show camera button on mobile
                        _buildButton(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
