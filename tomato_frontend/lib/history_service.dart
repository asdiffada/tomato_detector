import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanResult {
  final File? image; 
  final String imagePath; 
  final String label;
  final String confidence;
  final String debugInfo;
  final String colorStatus;
  final DateTime timestamp;
  final int colorScore;
  final int shapeScore;
  final int textureScore;
  final int sizeMm;
  final String quality;

  ScanResult({
    this.image,
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.debugInfo,
    required this.colorStatus,
    required this.timestamp,
    this.colorScore = 0,
    this.shapeScore = 0,
    this.textureScore = 0,
    this.sizeMm = 0,
    this.quality = "Unknown",
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'label': label,
      'confidence': confidence,
      'debugInfo': debugInfo,
      'colorStatus': colorStatus,
      'timestamp': timestamp.toIso8601String(),
      'colorScore': colorScore,
      'shapeScore': shapeScore,
      'textureScore': textureScore,
      'sizeMm': sizeMm,
      'quality': quality,
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      image: File(json['imagePath']), 
      imagePath: json['imagePath'],
      label: json['label'],
      confidence: json['confidence'],
      debugInfo: json['debugInfo'],
      colorStatus: json['colorStatus'],
      timestamp: DateTime.parse(json['timestamp']),
      colorScore: json['colorScore'] ?? 0,
      shapeScore: json['shapeScore'] ?? 0,
      textureScore: json['textureScore'] ?? 0,
      sizeMm: json['sizeMm'] ?? 0,
      quality: json['quality'] ?? "Unknown",
    );
  }
}

class HistoryService {
  static final ValueNotifier<List<ScanResult>> historyNotifier = ValueNotifier([]);
  static List<ScanResult> get history => historyNotifier.value;
  static ScanResult? latestResult;

  static const String _storageKey = 'tomato_history_v1';

  static Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_storageKey);

    if (historyJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(historyJson);
        final List<ScanResult> loadedData = decodedList
            .map((item) => ScanResult.fromJson(item))
            .toList();
        
        historyNotifier.value = loadedData;
        
        if (loadedData.isNotEmpty) {
          latestResult = loadedData.first;
        }
      } catch (e) {
        debugPrint("Gagal load history: $e");
      }
    }
  }

  static Future<void> addResult(ScanResult result) async {
    final currentList = historyNotifier.value;
    final newList = List<ScanResult>.from(currentList);
    
    newList.insert(0, result);
    historyNotifier.value = newList;
    latestResult = result;

    await _saveToStorage(newList);
  }

  static Future<void> _saveToStorage(List<ScanResult> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }
}