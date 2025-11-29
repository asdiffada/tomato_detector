import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'widgets.dart'; // Mengambil Sidebar & ResultDisplay

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  File? _image;
  String _label = "Pilih Foto";
  String _confidence = "";
  String _debugInfo = "Ambil dari Galeri HP";
  Color _statusColor = Colors.grey;
  bool _isLoading = false;

  Future<void> _processGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _label = "Mengupload...";
      });

      // Panggil API
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
      // Ubah warna AppBar biar beda dikit dengan kamera
      appBar: AppBar(title: const Text("Mode Galeri"), backgroundColor: Colors.orange),
      drawer: const AppDrawer(), // Sidebar
      body: ResultDisplay(
        image: _image,
        label: _label,
        confidence: _confidence,
        debugInfo: _debugInfo,
        statusColor: _statusColor,
        isLoading: _isLoading,
        onActionButtonTap: _processGallery,
        actionIcon: Icons.photo_library,
        actionLabel: "Buka Galeri",
      ),
    );
  }
}