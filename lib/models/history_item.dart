// models/history_item.dart

class HistoryItem {
  final String imagePath; // Must be the PERMANENT path
  final String label;
  final String date;

  HistoryItem({required this.imagePath, required this.label, required this.date});

  // Factory constructor to create from a map (for JSON decoding)
  factory HistoryItem.fromJson(Map<String, dynamic> jsonData) {
    return HistoryItem(
      imagePath: jsonData['imagePath'],
      label: jsonData['label'],
      date: jsonData['date'],
    );
  }

  // Method to convert the instance to a map (for JSON encoding)
  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'label': label,
      'date': date,
    };
  }
}
