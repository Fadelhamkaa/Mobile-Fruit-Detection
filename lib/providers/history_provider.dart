import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? historyList = prefs.getStringList('scan_history');
      
      if (historyList != null) {
        _history = historyList.map((e) {
          try {
            return Map<String, dynamic>.from(jsonDecode(e));
          } catch (e) {
            debugPrint('Error parsing history item: $e');
            return null;
          }
        }).whereType<Map<String, dynamic>>().toList();
      } else {
        _history = [];
      }
    } catch (e) {
      _error = 'Failed to load history';
      debugPrint('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addScan({
    required String imagePath,
    required String label,
    required DateTime date,
    double? confidence,
  }) async {
    try {
      // Verify the image file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        _error = 'Image file not found';
        return false;
      }

      final scan = {
        'imagePath': imagePath,
        'label': label,
        'date': date.toIso8601String(),
        'confidence': confidence?.toString(),
      };

      _history.insert(0, scan);
      await _saveHistory();
      return true;
    } catch (e) {
      _error = 'Failed to save scan';
      debugPrint('Error adding scan: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList = _history.map((e) => jsonEncode(e)).toList();
      return await prefs.setStringList('scan_history', encodedList);
    } catch (e) {
      _error = 'Failed to save history';
      debugPrint('Error saving history: $e');
      return false;
    }
  }

  Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _history = [];
      await prefs.remove('scan_history');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to clear history';
      debugPrint('Error clearing history: $e');
      return false;
    }
  }

  Future<bool> deleteScan(int index) async {
    try {
      if (index >= 0 && index < _history.length) {
        _history.removeAt(index);
        await _saveHistory();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to delete scan';
      debugPrint('Error deleting scan: $e');
      return false;
    }
  }
}
