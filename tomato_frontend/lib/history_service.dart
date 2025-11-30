import 'dart:io';

class ScanResult {
  final File image;
  final String label;
  final String confidence;
  final String debugInfo;
  final String colorStatus;
  final DateTime timestamp;
  
  // --- Field Baru untuk Analisis Detail ---
  final int colorScore;
  final int shapeScore;
  final int textureScore;

  ScanResult({
    required this.image,
    required this.label,
    required this.confidence,
    required this.debugInfo,
    required this.colorStatus,
    required this.timestamp,
    // Default value 0 jika data lama tidak punya field ini
    this.colorScore = 0,
    this.shapeScore = 0,
    this.textureScore = 0,
  });
}

class HistoryService {
  static List<ScanResult> history = [];
  static ScanResult? latestResult;

  static void addResult(ScanResult result) {
    history.insert(0, result);
    latestResult = result;
  }
}