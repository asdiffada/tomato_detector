import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets.dart'; // Import AppDrawer

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  // Fungsi Helper untuk Membuka Link
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
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
        // --- 1. SIDEBAR ICON (DISAMAKAN DENGAN SCAN/HOME) ---
        leading: Builder(
          builder: (context) {
            return InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(8), 
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.5), width: 1.5)
                ),
                child: const Icon(Icons.menu, color: Color(0xFFFF3B30), size: 24),
              ),
            );
          }
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
            // (Fitur Pencarian Dihapus sesuai permintaan)

            // --- 2. HERO BANNER ---
            GestureDetector(
              onTap: () => _launchURL("https://distan.bulelengkab.go.id/informasi/detail/artikel/budi-daya-tanaman-tomat-25"),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage("assets/leaf_pattern.png"), // Opsional, hapus baris ini jika tidak ada asset
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Panduan Lengkap\nBudidaya Tomat",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pelajari tahapan tanam hingga panen",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _launchURL("https://distan.bulelengkab.go.id/informasi/detail/artikel/budi-daya-tanaman-tomat-25"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF3B30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text("Pelajari Sekarang", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // --- 3. TINGKAT KEMATANGAN (LINKED) ---
            // Tombol "Lihat Semua" dihapus
            const Text("Tingkat Kematangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),
            
            _buildMaturityCard(
              "Green (Hijau)", 
              "Tomat masih mentah, keras, cocok untuk masakan", 
              const Color(0xFF00C853), 
              const Color(0xFFE8F5E9),
              "https://id.wikipedia.org/wiki/Tomat_hijau" 
            ),
            const SizedBox(height: 10),
            _buildMaturityCard(
              "Turning (Setengah Matang)", 
              "Mulai berubah warna, tekstur mulai lunak", 
              const Color(0xFFFF6D00), 
              const Color(0xFFFFF3E0),
              "https://p2mal.uma.ac.id/2023/08/04/teknik-budidaya-tomat-panduan-lengkap-untuk-hasil-panen-yang-melimpah/"
            ),
            const SizedBox(height: 10),
            _buildMaturityCard(
              "Red (Matang)", 
              "Matang sempurna, kaya likopen, siap makan", 
              const Color(0xFFD50000), 
              const Color(0xFFFFEBEE),
              "https://hellosehat.com/nutrisi/fakta-gizi/manfaat-tomat-bagi-kesehatan/"
            ),
            
            const SizedBox(height: 25),

            // --- 4. TIPS & PANDUAN (LINKED) ---
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
                _buildTipCard(
                  Icons.eco, "Cara Menyimpan", "Agar tidak cepat busuk", 
                  const Color(0xFFFFCDD2), Colors.red,
                  "https://rri.co.id/lain-lain/1158859/cara-menyimpan-tomat-agar-tidak-cepat-busuk"
                ),
                _buildTipCard(
                  Icons.water_drop, "Nutrisi Tomat", "Kandungan gizi & manfaat", 
                  const Color(0xFFBBDEFB), Colors.blue,
                  "https://hellosehat.com/nutrisi/fakta-gizi/manfaat-tomat-bagi-kesehatan/"
                ),
                _buildTipCard(
                  Icons.access_time_filled, "Masa Simpan", "Tips awet 1 bulan", 
                  const Color(0xFFC8E6C9), Colors.green,
                  "https://jatimtimes.com/baca/317711/20240803/014400/begini-cara-simpan-tomat-supaya-awet-1-bulan-tanpa-dikulkas"
                ),
                _buildTipCard(
                  Icons.restaurant_menu, "Resep Tomat", "Olahan lezat & sehat", 
                  const Color(0xFFE1BEE7), Colors.purple,
                  "https://www.fimela.com/food/read/5426966/6-resep-serba-tomat-lezat-yang-ampuh-turunkan-kolesterol-tinggi"
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- 5. ARTIKEL TERBARU (LINKED & REAL DATA) ---
            const Text("Artikel Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),
            
            _buildArticleCard(
              "Tips Memilih Tomat Segar dan Berkualitas",
              "Panduan praktis membedakan tomat segar di pasar.",
              "Tips",
              "https://cdn.rri.co.id/berita/1/images/1695885265057-images_(22)/1695885265057-images_(22).jpeg", // Image URL RRI
              "RRI.co.id",
              "https://rri.co.id/iptek/1002045/bingung-memilih-tomat-yang-segar-dan-berkualitas"
            ),
            const SizedBox(height: 15),
            _buildArticleCard(
              "Cara Budidaya Tomat Agar Berbuah Lebat",
              "Panduan lengkap menanam tomat untuk pemula.",
              "Pertanian",
              "https://gdm.id/wp-content/uploads/2021/09/budidaya-tomat.jpg", // Image URL GDM
              "GDM Organik",
              "https://gdm.id/budidaya-tomat/"
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildMaturityCard(String title, String desc, Color iconColor, Color bgColor, String url) {
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.circle, color: Colors.white, size: 20),
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

  Widget _buildArticleCard(String title, String subtitle, String tag, String imageUrl, String author, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300], // Loading color
          image: DecorationImage(
            image: NetworkImage(imageUrl), 
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Fallback jika gagal load image
            },
          ),
        ),
        child: Stack(
          children: [
            // Overlay Gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            // Konten Teks
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.9), // Tag Merah
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(radius: 8, backgroundColor: Colors.white, child: Icon(Icons.person, size: 10, color: Colors.grey)),
                      const SizedBox(width: 6),
                      Text(author, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.open_in_new, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text("Buka Artikel", style: TextStyle(color: Colors.white70, fontSize: 10)),
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