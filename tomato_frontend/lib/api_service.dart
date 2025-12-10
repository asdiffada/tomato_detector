import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// GANTI IP INI SESUAI IP LAPTOP ANDA
final String SERVER_URL = "http://192.168.18.74:5000/predict"; 

class ApiService {
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

  static Color getColorFromString(String? colorName) {
    switch (colorName) {
      case 'green': return const Color(0xFF00C853);
      case 'orange': return const Color(0xFFFFAB00);
      case 'red': return const Color(0xFFD50000);
      case 'purple': return Colors.purple;
      default: return Colors.grey;
    }
  }
}