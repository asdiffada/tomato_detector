import 'package:flutter/material.dart';
import 'widgets.dart'; // Untuk Sidebar
import 'camera_page.dart';
import 'gallery_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Tomat"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(), // Sidebar
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            const Text(
              "Halo, Petani Cerdas! 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Mari cek kualitas tomatmu hari ini.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            
            const SizedBox(height: 20),

            // --- BAGIAN PILIH MODE (TOMBOL BESAR) ---
            const Text(
              "Mulai Deteksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Tombol Kamera
                Expanded(
                  child: _buildModeCard(
                    context,
                    title: "Kamera",
                    icon: Icons.camera_alt,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CameraPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                // Tombol Galeri
                Expanded(
                  child: _buildModeCard(
                    context,
                    title: "Galeri",
                    icon: Icons.photo_library,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GalleryPage()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- BAGIAN INFORMASI TOMAT ---
            const Text(
              "Ensiklopedia Tomat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Kartu Informasi Mentah
            _buildInfoCard(
              title: "Mentah (Unripe)",
              description: "Warna dominan hijau. Tekstur keras dan rasa masam. Cocok untuk dimasak atau sambal hijau.",
              color: Colors.green,
              textColor: Colors.white,
            ),
            
            // Kartu Informasi Setengah Matang
            _buildInfoCard(
              title: "Setengah Matang (Turning)",
              description: "Warna kuning atau oranye. Tekstur mulai melunak. Rasa sedikit manis. Tahan disimpan beberapa hari.",
              color: Colors.orange,
              textColor: Colors.white,
            ),

            // Kartu Informasi Matang
            _buildInfoCard(
              title: "Matang (Ripe)",
              description: "Warna merah penuh. Tekstur lunak dan berair. Kaya akan Likopen. Paling enak dimakan langsung.",
              color: Colors.red,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Tombol Mode
  Widget _buildModeCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Info Card
  Widget _buildInfoCard({required String title, required String description, required Color color, required Color textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 5),
          Text(description, style: TextStyle(color: textColor, fontSize: 14)),
        ],
      ),
    );
  }
}