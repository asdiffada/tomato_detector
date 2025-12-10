import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.all(8), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF3B30), width: 1.5)
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF3B30), size: 20),
            ),
          ),
        ),
        title: const Text(
          "Discover",
          style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), 
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            GestureDetector(
              onTap: () => _launchURL("https://distan.bulelengkab.go.id/informasi/detail/artikel/budi-daya-tanaman-tomat-25"),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF1744).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Panduan Lengkap\nKematangan Tomat",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pelajari tahapan kematangan tomat",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Pelajari Sekarang",
                        style: TextStyle(color: Color(0xFFFF3B30), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("Tingkat Kematangan", showViewAll: true),
            const SizedBox(height: 15),
            
            _buildMaturityCard(
              "Green (Hijau)", 
              "Tomat masih mentah, keras dan belum matang", 
              Colors.white, 
              const Color(0xFF2ECC71), 
              const Color(0xFFE8F5E9), 
              "https://id.wikipedia.org/wiki/Tomat_hijau" 
            ),
            const SizedBox(height: 12),
            _buildMaturityCard(
              "Red (Matang)", 
              "Tomat matang sempurna, kaya likopen", 
              Colors.white,
              const Color(0xFFFF3B30), 
              const Color(0xFFFFEBEE), 
              "https://hellosehat.com/"
            ),
            
            const SizedBox(height: 25),

            const Text("Tips & Panduan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildTipCard(Icons.kitchen, "Cara Menyimpan", "Panduan menyimpan tomat", const Color(0xFFFFEBEE), const Color(0xFFFF3B30), "https://rri.co.id/lain-lain/1158859/cara-menyimpan-tomat-agar-tidak-cepat-busuk"),
                _buildTipCard(Icons.water_drop, "Nutrisi Tomat", "Kandungan gizi tomat", const Color(0xFFE3F2FD), Colors.blue, "https://hellosehat.com/nutrisi/fakta-gizi/manfaat-tomat-bagi-kesehatan/"),
                _buildTipCard(Icons.access_time_filled, "Masa Simpan", "Berapa lama bisa disimpan", const Color(0xFFE8F5E9), Colors.green, "https://jatimtimes.com/"),
                _buildTipCard(Icons.restaurant_menu, "Resep Tomat", "Kreasi olahan tomat", const Color(0xFFF3E5F5), Colors.purple, "https://www.fimela.com/"),
              ],
            ),

            const SizedBox(height: 25),

            
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildMaturityCard(String title, String desc, Color dotColor, Color boxColor, Color bgColor, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(IconData icon, String title, String subtitle, Color bgColor, Color iconColor, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              subtitle, 
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(String title, String subtitle, String tag, String imageUrl, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300], 
          image: DecorationImage(
            image: NetworkImage(imageUrl), 
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.4, 1.0], 
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF3B30))),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      CircleAvatar(radius: 8, backgroundColor: Colors.white, child: Icon(Icons.person, size: 10, color: Colors.grey)),
                      SizedBox(width: 6),
                      Text("Admin", style: TextStyle(color: Colors.white, fontSize: 10)),
                      Spacer(),
                      Text("5 min read", style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}