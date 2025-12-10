import 'package:flutter/material.dart';
import 'dart:math'; // Untuk PI jika dibutuhkan painter
import 'history_service.dart'; 
import 'widgets.dart'; 

class HomePage extends StatefulWidget {
  final VoidCallback? onScanPress; 
  final VoidCallback? onHistoryPress; 

  const HomePage({super.key, this.onScanPress, this.onHistoryPress});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0 && time.day == now.day) {
      return "Hari ini, ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays == 1 || (diff.inDays == 0 && time.day != now.day)) {
      return "Kemarin";
    } else {
      return "${diff.inDays} hari lalu";
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  border: Border.all(color: const Color(0xFFFF3B30), width: 1.5)
                ),
                child: const Icon(Icons.menu, color: Color(0xFFFF3B30), size: 20),
              ),
            );
          }
        ),
        title: const Text(
          "TomaCam",
          style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<ScanResult>>(
        valueListenable: HistoryService.historyNotifier,
        builder: (context, history, child) {
          
          final now = DateTime.now();
          int todayScanCount = history.where((item) {
            return item.timestamp.year == now.year &&
                   item.timestamp.month == now.month &&
                   item.timestamp.day == now.day;
          }).length;

          double totalConf = 0;
          int countConf = 0;
          for (var item in history) {
            try {
              String numPart = item.confidence.split('%')[0];
              totalConf += double.parse(numPart);
              countConf++;
            } catch (e) {}
          }
          String averageAccuracy = countConf == 0 ? "0%" : "${(totalConf / countConf).toStringAsFixed(0)}%";

          int ripe = history.where((i) => i.label == "RIPE").length;
          int turning = history.where((i) => i.label == "TURNING").length;
          int unripe = history.where((i) => i.label == "UNRIPE").length;
          int totalData = history.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 20),

                Row(
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
                ),
                const SizedBox(height: 20),

                _buildChartSection(ripe, turning, unripe, totalData),
                const SizedBox(height: 20),

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
                
                if (history.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada data scan.", style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...history.take(3).map((scan) {
                    String timeLabel = _formatTime(scan.timestamp);
                    String conf = scan.confidence.contains('%') ? scan.confidence : "${scan.confidence}%";
                    return _buildHistoryStyleItem(context, scan, conf, timeLabel);
                  }).toList(),

                const SizedBox(height: 20),
                _buildTipsCard(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildStatCard({required IconData icon, required Color iconColor, required String percentage, required String count, required String label, bool isOrange = false}) {
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
              if (percentage.isNotEmpty) Text(percentage, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChartSection(int ripe, int turning, int unripe, int total) {
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
              Text("Hasil Deteksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                painter: DonutChartPainter(ripe: ripe, turning: turning, unripe: unripe, total: total),
              ),
            ),
            
            const SizedBox(height: 10),
            if (total > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    _buildLegendItem("Matang", const Color(0xFFD50000), ripe, total), 
                    _buildLegendItem("Mentah", const Color(0xFF00C853), unripe, total), 
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

  Widget _buildHistoryStyleItem(BuildContext context, ScanResult item, String confidence, String timeLabel) {
    Color badgeColor;
    Color badgeTextCol;
    String badgeLabel;

    if (item.label == "RIPE") {
      badgeColor = const Color(0xFFFFEBEE); 
      badgeTextCol = const Color(0xFFFF3B30); 
      badgeLabel = "Matang";
    } else {
      badgeColor = const Color(0xFFE8F5E9); 
      badgeTextCol = const Color(0xFF4CAF50); 
      badgeLabel = "Mentah";
    }

    // Perbaikan ID: Menggunakan hashCode karena id tidak ada
    String itemId = item.hashCode.toString().substring(0, 3);

    return Container(
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
            child: item.image != null && item.image!.existsSync()
                ? Image.file(
                    item.image!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
                      "Tomat #$itemId", // FIXED: Menggunakan itemId generator sederhana
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
                  "Tingkat Akurasi: $confidence", 
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
        ],
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