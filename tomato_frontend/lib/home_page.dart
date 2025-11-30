import 'package:flutter/material.dart';
import 'dart:math';
import 'history_service.dart'; 
import 'api_service.dart'; 
import 'widgets.dart'; // Import AppDrawer
import 'analysis_page.dart'; // IMPORT PENTING: Agar bisa pindah ke halaman analisis

class HomePage extends StatefulWidget {
  final VoidCallback? onScanPress; 
  final VoidCallback? onHistoryPress; 

  const HomePage({super.key, this.onScanPress, this.onHistoryPress});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int get todayScanCount {
    final now = DateTime.now();
    return HistoryService.history.where((item) {
      return item.timestamp.year == now.year &&
             item.timestamp.month == now.month &&
             item.timestamp.day == now.day;
    }).length;
  }

  String get averageAccuracy {
    if (HistoryService.history.isEmpty) return "0%";
    double total = 0;
    int count = 0;
    for (var item in HistoryService.history) {
      try {
        String numPart = item.confidence.split('%')[0];
        total += double.parse(numPart);
        count++;
      } catch (e) {}
    }
    if (count == 0) return "0%";
    return "${(total / count).toStringAsFixed(0)}%";
  }

  Map<String, int> get chartData {
    int ripe = HistoryService.history.where((i) => i.label == "RIPE").length;
    int turning = HistoryService.history.where((i) => i.label == "TURNING").length;
    int unripe = HistoryService.history.where((i) => i.label == "UNRIPE").length;
    return {"RIPE": ripe, "TURNING": turning, "UNRIPE": unripe};
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0 && time.day == now.day) {
      return "Hari ini, ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays == 1 || (diff.inDays == 0 && time.day != now.day)) {
      return "Kemarin, ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${diff.inDays} hari lalu";
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = chartData;
    int totalData = HistoryService.history.length;

    return Scaffold(
      key: _scaffoldKey, 
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
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
          "Tomato Detector",
          style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // BANNER
            _buildHeroBanner(),

            const SizedBox(height: 20),

            // STATS
            _buildStatsRow(),
            const SizedBox(height: 20),

            // CHART
            _buildChartSection(data, totalData),
            const SizedBox(height: 20),

            // RECENT SCANS HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Scan Terbaru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: widget.onHistoryPress, 
                  child: const Text("Lihat Semua", style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 10),
            
            // LIST SCAN TERBARU
            if (HistoryService.history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Belum ada data scan.", style: TextStyle(color: Colors.grey)),
              )
            else
              ...HistoryService.history.take(3).map((scan) {
                String timeLabel = _formatTime(scan.timestamp);
                String conf = scan.confidence.contains('%') ? scan.confidence : "${scan.confidence}%";

                // Kita kirim 'context' dan 'scan' object agar bisa di-klik
                return _buildHistoryStyleItem(context, scan, conf, timeLabel);
              }).toList(),

            const SizedBox(height: 20),
            _buildTipsCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B30).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        image: const DecorationImage(
          image: AssetImage("assets/leaf_pattern.png"), 
          fit: BoxFit.cover,
          opacity: 0.1,
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Scan Tomat Sekarang", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Deteksi tingkat kematangan tomat dengan AI",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: widget.onScanPress, 
            icon: const Icon(Icons.camera_alt, color: Color(0xFFFF3B30)),
            label: const Text("Mulai Scan", style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            percentage: "", 
            count: "$todayScanCount", 
            label: "Scan Hari Ini",
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            iconColor: Colors.orange,
            percentage: "",
            count: averageAccuracy, 
            label: "Rata-rata Akurasi",
            isOrange: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String percentage,
    required String count,
    required String label,
    bool isOrange = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (percentage.isNotEmpty)
                Text(percentage, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<String, int> data, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tingkat Kematangan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.pie_chart, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          
          if (total == 0)
            const SizedBox(
              height: 150, 
              child: Center(child: Text("Belum ada data untuk grafik", style: TextStyle(color: Colors.grey)))
            )
          else
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: DonutChartPainter(
                  ripe: data['RIPE']!, 
                  turning: data['TURNING']!, 
                  unripe: data['UNRIPE']!,
                  total: total
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            if (total > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _buildLegendItem("Matang", const Color(0xFFD50000), data['RIPE']!, total), 
                   _buildLegendItem("Setengah Matang", const Color(0xFFFFAB00), data['TURNING']!, total), 
                   _buildLegendItem("Mentah", const Color(0xFF00C853), data['UNRIPE']!, total), 
                ],
              )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, int total) {
    int pct = total == 0 ? 0 : ((count / total) * 100).toInt();
    return Column(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(height: 4),
        Text("$label ($pct%)", style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // --- ITEM LIST STYLE (UPDATED: Bisa Di-klik) ---
  Widget _buildHistoryStyleItem(BuildContext context, ScanResult item, String confidence, String timeLabel) {
    Color badgeColor;
    Color badgeTextCol;
    String badgeLabel;

    if (item.label == "RIPE") {
      badgeColor = const Color(0xFFFFEBEE); 
      badgeTextCol = const Color(0xFFFF3B30); 
      badgeLabel = "Matang";
    } else if (item.label == "TURNING") {
      badgeColor = const Color(0xFFFFF3E0); 
      badgeTextCol = const Color(0xFFFF9800); 
      badgeLabel = "Setengah Matang"; 
    } else {
      badgeColor = const Color(0xFFE8F5E9); 
      badgeTextCol = const Color(0xFF4CAF50); 
      badgeLabel = "Mentah";
    }

    // Menggunakan GestureDetector untuk Navigasi
    return GestureDetector(
      onTap: () {
        // 1. Set item ini sebagai data terbaru
        HistoryService.latestResult = item;
        
        // 2. Pindah ke Halaman Analisis
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalysisPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))
          ]
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                item.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tomat #${item.hashCode.toString().substring(0, 3)}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(color: badgeTextCol, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tingkat kematangan: $confidence", 
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5FF), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tips Hari Ini", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text(
                  "Untuk hasil scan terbaik, pastikan tomat dalam pencahayaan yang cukup dan hindari bayangan.",
                  style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Chart Painter (Sama)
class DonutChartPainter extends CustomPainter {
  final int ripe;
  final int turning;
  final int unripe;
  final int total;

  DonutChartPainter({required this.ripe, required this.turning, required this.unripe, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 40.0;
    
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    
    double pctRipe = total == 0 ? 0 : ripe / total;
    double pctTurn = total == 0 ? 0 : turning / total;
    double pctUnripe = total == 0 ? 0 : unripe / total;

    double startAngle = -pi / 2;

    if (pctRipe > 0) {
      drawSegment(canvas, rect, startAngle, pctRipe, const Color(0xFFD50000));
      startAngle += pctRipe * 2 * pi;
    }
    if (pctTurn > 0) {
      drawSegment(canvas, rect, startAngle, pctTurn, const Color(0xFFFFAB00));
      startAngle += pctTurn * 2 * pi;
    }
    if (pctUnripe > 0) {
      drawSegment(canvas, rect, startAngle, pctUnripe, const Color(0xFF00C853));
      startAngle += pctUnripe * 2 * pi;
    }
  }

  void drawSegment(Canvas canvas, Rect rect, double startAngle, double sweepPercent, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0
      ..color = color;
    
    final sweepAngle = sweepPercent * 2 * pi;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; 
}