import 'package:flutter/material.dart';
import 'main.dart'; // Import main agar bisa navigasi ke MainNavigation

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // --- HEADER SIDEBAR ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30), // Merah Tomat
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.eco, color: Color(0xFFFF3B30), size: 35),
                ),
                SizedBox(height: 15),
                Text(
                  'Tomato Detector',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Powered by JST AI',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- MENU ITEMS ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.home_rounded, "Home", 0),
                _buildDrawerItem(context, Icons.show_chart_rounded, "Analysis", 1),
                _buildDrawerItem(context, Icons.camera_alt_rounded, "Scan", 2),
                _buildDrawerItem(context, Icons.history_rounded, "History", 3),
                _buildDrawerItem(context, Icons.explore_rounded, "Discover", 4),
                
                const Divider(height: 30),
                
                _buildDrawerItem(context, Icons.info_outline, "Tentang Aplikasi", -1), // -1 tidak pindah tab
              ],
            ),
          ),

          // --- FOOTER ---
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "v1.0.0 Beta",
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, int targetIndex, {bool isHighlight = false}) {
    Color color = isHighlight ? const Color(0xFFFF3B30) : Colors.black87;
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal
        ),
      ),
      onTap: () {
        // Tutup Drawer dulu
        Navigator.pop(context);

        if (targetIndex != -1) {
          // Navigasi ke MainNavigation dengan index tertentu
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(initialIndex: targetIndex),
            ),
          );
        } else {
          // Logic untuk tombol "Tentang Aplikasi" (jika ada)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Aplikasi Deteksi Tomat v1.0"))
          );
        }
      },
    );
  }
}