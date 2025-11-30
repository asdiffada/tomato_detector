import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- KONFIGURASI SERVER ---
// GANTI IP INI SESUAI IP LAPTOP ANDA
final String SERVER_URL = "http://192.168.3.63:5000/predict"; 

class ApiService {
  // Fungsi untuk upload gambar ke server
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(SERVER_URL));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "label": "Error Server",
          "debug_info": "Status Code: ${response.statusCode}",
          "color_status": "grey"
        };
      }
    } catch (e) {
      return {
        "label": "Gagal Koneksi",
        "debug_info": "Pastikan Server Nyala & IP Benar.\nError: $e",
        "color_status": "purple"
      };
    }
  }

  // Helper konversi warna
  static Color getColorFromString(String? colorName) {
    switch (colorName) {
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'red': return Colors.red;
      case 'purple': return Colors.purple;
      default: return Colors.grey;
    }
  }
}