// providers/history_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import '../models/history_item.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = false;
  String? _error;

  List<HistoryItem> get history => _historyItems;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

    Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
    final historyStringList = prefs.getStringList('scan_history') ?? [];
    _historyItems = historyStringList
        .map((item) => HistoryItem.fromJson(json.decode(item)))
        .toList();
    } catch (e) {
      _error = "Failed to load history: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHistoryItem(File tempImageFile, String label) async {
    try {
      // 1. Get permanent directory
      final appDir = await getApplicationDocumentsDirectory();
      
      // 2. Create a unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = join(appDir.path, fileName);

      // 3. Copy file to permanent path
      await tempImageFile.copy(permanentPath);

      // 4. Create HistoryItem with the permanent path
      final newItem = HistoryItem(
        imagePath: permanentPath,
        label: label,
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      );

      _historyItems.insert(0, newItem); // Add to the beginning of the list

      // 5. Save the updated list to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final historyStringList = _historyItems.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList('scan_history', historyStringList);
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving history item: $e");
    }
  }

    Future<void> clearHistory() async {
    _isLoading = true;
    notifyListeners();
    // Delete all saved image files
    for (var item in _historyItems) {
      try {
        final file = File(item.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint("Error deleting file ${item.imagePath}: $e");
      }
    }

    _historyItems = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scan_history');
    
    _isLoading = false;
    notifyListeners();
  }
}
