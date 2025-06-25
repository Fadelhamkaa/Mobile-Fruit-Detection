// screens/home_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../tflite_helper.dart';
import './result_page.dart';
import './history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    TFLiteHelper.init();
  }

  Future<void> _processImage(ImageSource source) async {
    setState(() => _isProcessing = true);

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        setState(() => _isProcessing = false);
        return;
      }
      File imageFile = File(pickedFile.path);

      final recognition = await TFLiteHelper.classifyImage(imageFile);

      await Provider.of<HistoryProvider>(context, listen: false)
          .addHistoryItem(imageFile, recognition['label']);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            imageFile: imageFile,
            label: recognition['label'],
            confidence: recognition['confidence'],
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FruitLens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
            tooltip: 'Scan History',
          ),
        ],
      ),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Analyzing Image..."),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _processImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Select from Gallery'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _processImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take a Photo'),
                  ),
                ],
              ),
      ),
    );
  }
}
