// screens/history_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';
import './result_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // Show a confirmation dialog before clearing history
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Clear History"),
                  content: const Text("Are you sure you want to delete all scan history? This cannot be undone."),
                  actions: [
                    TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
                    TextButton(
                      child: const Text("Clear", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Provider.of<HistoryProvider>(context, listen: false).clearHistory();
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (historyProvider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${historyProvider.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (historyProvider.history.isEmpty) {
            return const Center(
              child: Text(
                "Your scan history will appear here.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: historyProvider.history.length,
            itemBuilder: (context, index) {
              final HistoryItem item = historyProvider.history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(item.imagePath),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                      },
                    ),
                  ),
                  title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.date),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(
                          imageFile: File(item.imagePath),
                          label: item.label,
                          confidence: -1, // -1 indicates this is from history
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
