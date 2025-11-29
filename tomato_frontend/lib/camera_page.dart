import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'widgets.dart'; // Mengambil Sidebar & ResultDisplay

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  String _label = "Siap Foto";
  String _confidence = "";
  String _debugInfo = "Tekan tombol untuk mulai";
  Color _statusColor = Colors.grey;
  bool _isLoading = false;

  Future<void> _processCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _label = "Menganalisis...";
      });

      // Panggil API dari file terpisah
      var result = await ApiService.uploadImage(_image!);

      setState(() {
        _isLoading = false;
        _label = result['label'] ?? "Error";
        _confidence = result['confidence'] ?? "";
        _debugInfo = result['debug_info'] ?? "No Data";
        _statusColor = ApiService.getColorFromString(result['color_status']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mode Kamera")),
      drawer: const AppDrawer(), // Sidebar dari widgets.dart
      body: ResultDisplay(
        image: _image,
        label: _label,
        confidence: _confidence,
        debugInfo: _debugInfo,
        statusColor: _statusColor,
        isLoading: _isLoading,
        onActionButtonTap: _processCamera,
        actionIcon: Icons.camera_alt,
        actionLabel: "Buka Kamera",
      ),
    );
  }
}