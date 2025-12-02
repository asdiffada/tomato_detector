import 'package:flutter/material.dart';
import 'history_service.dart';
import 'api_service.dart';
import 'widgets.dart';

class AnalysisPage extends StatelessWidget {
  final Function(int)? onTabChange; 

  const AnalysisPage({super.key, this.onTabChange});

  // --- LOGIC CHART ---
  Map<String, double> _getChartData(ScanResult result) {
    // 1. Cek apakah string debug_info mengandung format data JST baru
    // Format dari Backend: "... | JST Probs: M:0.99 S:0.01 U:0.00"
    if (result.debugInfo.contains("JST Probs")) {
      try {
        // Ambil bagian setelah "JST Probs:"
        final parts = result.debugInfo.split("JST Probs:")[1];
        
        // Parsing angka setelah M:, S:, dan U:
        // Contoh string: " M:0.99 S:0.01 U:0.00"
        final mStr = parts.split("M:")[1].split(" ")[0]; // Ambil 0.99
        final sStr = parts.split("S:")[1].split(" ")[0]; // Ambil 0.01
        
        // U biasanya ada di akhir string, jadi kita trim() biar bersih
        String uStr = parts.split("U:")[1]; 
        // Bersihkan karakter aneh jika ada (misal sisa kurung tutup)
        uStr = uStr.replaceAll(RegExp(r'[^0-9.]'), ''); 

        double matang = double.parse(mStr) * 100;
        double setengah = double.parse(sStr) * 100;
        double mentah = double.parse(uStr) * 100;

        return {
          "Matang": matang,
          "Setengah Matang": setengah,
          "Mentah": mentah,
        };
      } catch (e) {
        debugPrint("Gagal parsing chart data: $e");
        // Lanjut ke fallback di bawah jika gagal
      }
    }

    // --- FALLBACK (JIKA PARSING GAGAL ATAU DATA LAMA) ---
    // Ini yang membuat diagram jadi "100%" rata jika logic di atas error.
    if (result.label == "RIPE") return {"Matang": 100, "Setengah Matang": 0, "Mentah": 0};
    if (result.label == "TURNING") return {"Matang": 0, "Setengah Matang": 100, "Mentah": 0};
    return {"Matang": 0, "Setengah Matang": 0, "Mentah": 100};
  }

  Map<String, String> _getRecommendation(String label) {
    if (label == "RIPE") {
      return {
        "status": "Siap Dikonsumsi",
        "desc": "Tomat dalam kondisi optimal untuk dimakan langsung.",
        "time": "Konsumsi dalam 2-3 hari",
        "storage": "Simpan di suhu ruang/kulkas"
      };
    } else if (label == "TURNING") {
      return {
        "status": "Hampir Matang",
        "desc": "Tekstur mulai lunak, rasa sedikit manis.",
        "time": "Matang penuh dalam 2 hari",
        "storage": "Simpan suhu ruang dengan apel"
      };
    } else {
      return {
        "status": "Belum Siap Makan",
        "desc": "Masih keras dan masam. Cocok untuk dimasak.",
        "time": "Matang penuh dalam 5-7 hari",
        "storage": "JANGAN masukkan kulkas"
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = HistoryService.latestResult;

    // Tampilan kosong jika belum ada data scan
    if (result == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        drawer: const AppDrawer(), 
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
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
            "Analysis",
            style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 20),
              const Text("Belum ada data analisis.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final chartValues = _getChartData(result);
    final rec = _getRecommendation(result.label);
    final color = ApiService.getColorFromString(result.colorStatus);
    
    String displayLabel = "Tomat Matang";
    String shortStatus = "Matang";

    if (result.label == "TURNING") {
      displayLabel = "Setengah Matang";
      shortStatus = "Setengah Matang"; 
    }
    if (result.label == "UNRIPE") {
      displayLabel = "Tomat Mentah";
      shortStatus = "Mentah";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
          "Analysis",
          style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO IMAGE CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.file(
                      result.image,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                displayLabel, 
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 8, color: color),
                                  const SizedBox(width: 5),
                                  Text(
                                    result.confidence.contains('%') ? result.confidence : "${result.confidence}%",
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Scan: ${result.timestamp.day}/${result.timestamp.month} ${result.timestamp.hour}:${result.timestamp.minute} WIB",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusItem(Icons.check_circle, color, "Status", shortStatus),
                            _buildStatusItem(Icons.calendar_today, Colors.blue, "Konsumsi", "Hari ini"),
                            _buildStatusItem(
                                Icons.star, 
                                Colors.orange, 
                                "Kualitas", 
                                result.quality 
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CHART SECTION
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Color(0xFF3F51B5)),
                SizedBox(width: 10),
                Text("Tingkat Akurasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Distribusi Tingkat Kematangan", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: BarChartPainter(
                  ripe: chartValues["Matang"]!,
                  turning: chartValues["Setengah Matang"]!,
                  unripe: chartValues["Mentah"]!,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Matang", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text("Setengah Matang", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text("Mentah", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 30),

            // DETAILS SECTION
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple),
                SizedBox(width: 10),
                Text("Analisis Detail", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            
            // WARNA
            _buildDetailRow(
              Icons.color_lens, 
              "Warna", 
              "Dominan ${result.colorStatus}", 
              color, 
              "${result.colorScore}%" 
            ),
            
            // BENTUK
            _buildDetailRow(
              Icons.circle, 
              "Bentuk", 
              result.shapeScore > 80 ? "Bulat Sempurna" : "Agak Lonjong", 
              Colors.blue, 
              "${result.shapeScore}%"
            ),
            
            // TEKSTUR
            _buildDetailRow(
              Icons.texture, 
              "Tekstur", 
              result.textureScore > 70 ? "Halus mengkilap" : "Sedikit Kasar", 
              Colors.orange, 
              "${result.textureScore}%"
            ),

            // UKURAN
            _buildDetailRow(
              Icons.straighten,
              "Ukuran", 
              "Diameter Rata-rata", 
              Colors.purple, 
              "${result.sizeMm} mm"
            ),

            const SizedBox(height: 30),

            // REKOMENDASI SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3B30), Color(0xFFFF5252)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF3B30).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Rekomendasi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildRecItem(Icons.restaurant, rec['status']!, rec['desc']!),
                  _buildRecItem(Icons.access_time, "Waktu Konsumsi", rec['time']!),
                  _buildRecItem(Icons.ac_unit, "Penyimpanan", rec['storage']!),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TOMBOL AKSI
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (onTabChange != null) onTabChange!(2);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Scan Tomat Lain", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: const Color(0xFFFF3B30).withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                   if (onTabChange != null) onTabChange!(3);
                },
                icon: const Icon(Icons.history, size: 18),
                label: const Text("Riwayat Scan"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildStatusItem(IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, Color color, String score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(score, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildRecItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Chart Painter
class BarChartPainter extends CustomPainter {
  final double ripe;
  final double turning;
  final double unripe;

  BarChartPainter({required this.ripe, required this.turning, required this.unripe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final double barWidth = size.width / 5;
    
    for (int i = 0; i <= 5; i++) {
      double y = size.height - (size.height * (i * 0.2));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // RIPE (MERAH)
    paint.color = const Color(0xFFD50000); 
    double h1 = (ripe / 100) * size.height; 
    Rect r1 = Rect.fromLTWH(barWidth * 0.5, size.height - h1, barWidth, h1);
    canvas.drawRRect(RRect.fromRectAndRadius(r1, const Radius.circular(4)), paint);

    // TURNING (ORANGE)
    paint.color = const Color(0xFFFFAB00); 
    double h2 = (turning / 100) * size.height;
    Rect r2 = Rect.fromLTWH(barWidth * 2, size.height - h2, barWidth, h2);
    canvas.drawRRect(RRect.fromRectAndRadius(r2, const Radius.circular(4)), paint);

    // UNRIPE (HIJAU)
    paint.color = const Color(0xFF00C853);
    double h3 = (unripe / 100) * size.height;
    Rect r3 = Rect.fromLTWH(barWidth * 3.5, size.height - h3, barWidth, h3);
    canvas.drawRRect(RRect.fromRectAndRadius(r3, const Radius.circular(4)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}