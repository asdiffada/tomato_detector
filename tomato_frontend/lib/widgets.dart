import 'package:flutter/material.dart';
import 'main.dart'; // Import main agar bisa navigasi ke MainNavigation

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30), 
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN LOGO DIGANTI ---
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Atur padding sesuai selera
                    child: Image.asset(
                      'assets/tomato_icon.png', // Pastikan file ini ada di assets Anda
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // ---------------------------
                const SizedBox(height: 15),
                const Text(
                  'TomaCam',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Powered by JST & FFT', 
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

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
                _buildDrawerItem(context, Icons.info_outline, "About", -1), 
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "v1.0.1 Beta",
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
        Navigator.pop(context); 

        if (targetIndex != -1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(initialIndex: targetIndex),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Aplikasi Deteksi Tomat v1.0"))
          );
        }
      },
    );
  }
}