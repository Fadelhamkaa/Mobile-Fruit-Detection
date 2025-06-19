import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/history_provider.dart';
import 'result_page.dart';
import 'fruit_data.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, provider, _) {
              if (provider.history.isEmpty || provider.isLoading) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                tooltip: 'Clear History',
                onPressed: () => _showClearHistoryDialog(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return _buildErrorState(context, provider.error!);
          }

          if (provider.history.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildHistoryList(context, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_toggle_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Scan History',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your scan history will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () => context.read<HistoryProvider>().loadHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, HistoryProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await provider.loadHistory();
          if (provider.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to refresh: ${provider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to refresh history'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.history.length,
        itemBuilder: (context, index) {
          final item = provider.history[index];
          String dateText = 'Unknown date';
          try {
            if (item['date'] != null) {
              final date = DateTime.tryParse(item['date'].toString());
              if (date != null) {
                dateText = DateFormat('MMM d, y - HH:mm').format(date);
              }
            }
          } catch (e) {
            debugPrint('Error parsing date: $e');
          }
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _navigateToResult(context, item),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildItemImage(item),
                    const SizedBox(width: 16),
                    _buildItemDetails(item, dateText),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemImage(Map<String, dynamic> item) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: item['imagePath'] != null && File(item['imagePath']).existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(item['imagePath']),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildErrorIcon(),
              ),
            )
          : _buildErrorIcon(),
    );
  }

  Widget _buildItemDetails(Map<String, dynamic> item, String date) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['label']?.toString() ?? 'Unknown',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (fruitData.containsKey(item['label']))
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                fruitData[item['label']]?['scientific_name']?.toString() ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToResult(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          imagePath: item['imagePath']?.toString() ?? '',
          result: {
            'label': item['label']?.toString() ?? 'Unknown',
            'confidence': '95.00', // Mock confidence for history
          },
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return const Center(
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _showClearHistoryDialog(
      BuildContext context, HistoryProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all scan history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);

      try {
        final success = await provider.clearHistory();
        if (success && context.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('History cleared'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (context.mounted) {
          throw Exception('Failed to clear history');
        }
      } catch (e) {
        if (context.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to clear history'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
