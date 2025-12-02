import 'dart:io';
import 'package:flutter/material.dart';

class ScanResult {
  final File image;
  final String label;
  final String confidence;
  final String debugInfo;
  final String colorStatus;
  final DateTime timestamp;
  
  final int colorScore;
  final int shapeScore;
  final int textureScore;
  final int sizeMm;
  
  // --- Field Baru: Kualitas ---
  final String quality; 

  ScanResult({
    required this.image,
    required this.label,
    required this.confidence,
    required this.debugInfo,
    required this.colorStatus,
    required this.timestamp,
    this.colorScore = 0,
    this.shapeScore = 0,
    this.textureScore = 0,
    this.sizeMm = 0,
    this.quality = "Unknown", // Default
  });
}

class HistoryService {
  static final ValueNotifier<List<ScanResult>> historyNotifier = ValueNotifier([]);
  static List<ScanResult> get history => historyNotifier.value;
  static ScanResult? latestResult;

  static void addResult(ScanResult result) {
    final currentList = historyNotifier.value;
    final newList = List<ScanResult>.from(currentList);
    newList.insert(0, result);
    historyNotifier.value = newList;
    latestResult = result;
  }
}