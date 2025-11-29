import 'dart:io';
import 'package:flutter/material.dart';
import 'camera_page.dart';
import 'gallery_page.dart';
import 'dashboard_page.dart';

// --- WIDGET 1: SIDEBAR (DRAWER) ---
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Merah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.red,
            child: const SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco, color: Colors.white, size: 60),
                  SizedBox(height: 10),
                  Text(
                    'Deteksi Tomat',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Hybrid AI + Hue',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          // --- TAMBAHKAN TOMBOL DASHBOARD DISINI ---
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const DashboardPage())
              );
            },
          ),
          const Divider(), // Garis pemisah

          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Mode Kamera'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const CameraPage())
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Mode Galeri'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const GalleryPage())
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGET 2: TAMPILAN HASIL (RESULT DISPLAY) ---
class ResultDisplay extends StatelessWidget {
  final File? image;
  final String label;
  final String debugInfo;
  final String confidence;
  final Color statusColor;
  final bool isLoading;
  final VoidCallback onActionButtonTap;
  final IconData actionIcon;
  final String actionLabel;

  const ResultDisplay({
    super.key,
    required this.image,
    required this.label,
    required this.debugInfo,
    required this.confidence,
    required this.statusColor,
    required this.isLoading,
    required this.onActionButtonTap,
    required this.actionIcon,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Preview Gambar
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: image != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(image!, fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(actionIcon, size: 80, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text("Belum ada gambar", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            
            // Indikator Loading
            if (isLoading) 
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Sedang Menganalisis..."),
                ],
              ),

            // Hasil
            if (!isLoading) ...[
              Text(
                label,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: statusColor),
              ),
              Text(
                confidence,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              
              // Kotak Debug Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Text("Detail Analisis:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(debugInfo, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace')),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
            
            // Tombol Aksi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onActionButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor == Colors.grey ? Colors.blue : statusColor,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(actionIcon),
                label: Text(actionLabel, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}