import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'history_service.dart';
import 'api_service.dart';
import 'widgets.dart';

class AnalysisPage extends StatefulWidget {
  final Function(int)? onTabChange;

  const AnalysisPage({super.key, this.onTabChange});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  List<int> _histR = [];
  List<int> _histG = [];
  List<int> _histB = [];
  bool _isCalculating = false;

  // Variabel baru untuk menyimpan data analisis detail
  double _meanR = 0;
  double _meanG = 0;
  double _meanB = 0;
  int _totalPixels = 0;

  ScanResult? _currentResult;

  @override
  void initState() {
    super.initState();
    final initialResult = HistoryService.latestResult;
    if (initialResult != null) {
      _updateHistogram(initialResult);
    }
  }

  Future<void> _updateHistogram(ScanResult result) async {
    if (_currentResult == result) return;
    _currentResult = result;

    if (result.image == null || !result.image!.existsSync()) {
      if (mounted) {
        setState(() {
          _histR = [];
          _histG = [];
          _histB = [];
          _meanR = 0;
          _meanG = 0;
          _meanB = 0;
          _totalPixels = 0;
          _isCalculating = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isCalculating = true);

    try {
      final bytes = await result.image!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        // Resize untuk mempercepat perhitungan histogram
        final resized = img.copyResize(image, width: 300);

        final rCounts = List<int>.filled(256, 0);
        final gCounts = List<int>.filled(256, 0);
        final bCounts = List<int>.filled(256, 0);

        int totalR = 0;
        int totalG = 0;
        int totalB = 0;
        int pixelCount = 0;

        for (var pixel in resized) {
          int r = pixel.r.toInt().clamp(0, 255);
          int g = pixel.g.toInt().clamp(0, 255);
          int b = pixel.b.toInt().clamp(0, 255);

          // Filter background sederhana
          bool isBackground =
              (r > 250 && g > 250 && b > 250) || (r < 10 && g < 10 && b < 10);

          if (!isBackground) {
            rCounts[r]++;
            gCounts[g]++;
            bCounts[b]++;
            
            // Akumulasi untuk perhitungan Mean
            totalR += r;
            totalG += g;
            totalB += b;
            pixelCount++;
          }
        }

        if (mounted) {
          setState(() {
            _histR = rCounts;
            _histG = gCounts;
            _histB = bCounts;
            
            // Simpan hasil perhitungan Mean dan Total Piksel
            _totalPixels = pixelCount;
            _meanR = pixelCount > 0 ? totalR / pixelCount : 0;
            _meanG = pixelCount > 0 ? totalG / pixelCount : 0;
            _meanB = pixelCount > 0 ? totalB / pixelCount : 0;
            
            _isCalculating = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal hitung histogram: $e");
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  Map<String, double> _getChartData(ScanResult result) {
    try {
      if (result.debugInfo.contains("JST Probs")) {
        final parts = result.debugInfo.split("JST Probs:")[1];
        final mStr = parts.split("M:")[1].split(" ")[0];
        final uStr = parts.split("U:")[1];
        final cleanU = uStr.replaceAll(RegExp(r'[^0-9.]'), '');
        return {
          "Matang": double.parse(mStr) * 100,
          "Mentah": double.parse(cleanU) * 100,
        };
      }
    } catch (e) {}
    if (result.label == "RIPE") return {"Matang": 100, "Mentah": 0};
    return {"Matang": 0, "Mentah": 100};
  }

  Map<String, String> _getRecommendation(String label) {
    if (label == "RIPE") {
      return {
        "status": "Siap Dikonsumsi",
        "desc": "Tomat dalam kondisi optimal untuk dimakan langsung.",
        "time": "Konsumsi dalam 2-3 hari",
        "storage": "Simpan di suhu ruang/kulkas",
        "consumption_suggestion": "Hari ini"
      };
    } else {
      return {
        "status": "Belum Siap Makan",
        "desc": "Masih keras dan masam. Cocok untuk dimasak/sambal.",
        "time": "Matang penuh dalam 5-7 hari",
        "storage": "JANGAN masukkan kulkas",
        "consumption_suggestion": "5-7 Hari"
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ScanResult>>(
      valueListenable: HistoryService.historyNotifier,
      builder: (context, historyList, child) {
        final result = HistoryService.latestResult;

        if (result != null && result != _currentResult) {
          Future.microtask(() => _updateHistogram(result));
        }

        if (result == null) {
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFFF3B30), width: 1.5),
                    ),
                    child: const Icon(Icons.menu,
                        color: Color(0xFFFF3B30), size: 20),
                  ),
                ),
              ),
              title: const Text("Analysis",
                  style: TextStyle(
                      color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Belum ada data analisis.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        final chartValues = _getChartData(result);
        final rec = _getRecommendation(result.label);
        final color = ApiService.getColorFromString(result.colorStatus);
        String displayLabel =
            result.label == "RIPE" ? "Tomat Matang" : "Tomat Mentah";
        String shortStatus = result.label == "RIPE" ? "Matang" : "Mentah";

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFFF3B30), width: 1.5),
                  ),
                  child: const Icon(Icons.menu,
                      color: Color(0xFFFF3B30), size: 20),
                ),
              ),
            ),
            title: const Text("Analysis",
                style: TextStyle(
                    color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(20)),
                        child: result.image != null &&
                                result.image!.existsSync()
                            ? Image.file(result.image!,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover)
                            : Container(
                                height: 220,
                                color: Colors.grey[200],
                                child: const Center(
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.grey))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(displayLabel,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis)),
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 8, color: color),
                                      const SizedBox(width: 5),
                                      Text(
                                          result.confidence.contains('%')
                                              ? result.confidence
                                              : "${result.confidence}%",
                                          style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusItem(Icons.check_circle, color,
                                    "Status", shortStatus),
                                _buildStatusItem(Icons.calendar_today,
                                    Colors.blue, "Konsumsi", rec['consumption_suggestion']!),
                                _buildStatusItem(Icons.star, Colors.orange,
                                    "Kualitas", result.quality),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Color(0xFF3F51B5)),
                    SizedBox(width: 10),
                    Text("Histogram Warna",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Distribusi intensitas warna pada citra",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                _isCalculating
                    ? const SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFF3B30)),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bagian Histogram (Kiri)
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildLabeledHistogram(
                                    "Histogram Merah", _histR, Colors.red),
                                _buildLabeledHistogram(
                                    "Histogram Hijau", _histG, Colors.green),
                                _buildLabeledHistogram(
                                    "Histogram Biru", _histB, Colors.blue),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Bagian Detail Analisis (Kanan)
                          Expanded(
                            flex: 1,
                            child: _buildAnalysisDetailsBox(result),
                          ),
                        ],
                      ),

                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.purple),
                    SizedBox(width: 10),
                    Text("Analisis Detail",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                _buildDetailRow(Icons.color_lens, "Warna",
                    "Dominan ${result.colorStatus}", color, "${result.colorScore}%"),
                _buildDetailRow(
                    Icons.circle,
                    "Bentuk",
                    result.shapeScore > 80
                        ? "Bulat Sempurna"
                        : "Agak Lonjong",
                    Colors.blue,
                    "${result.shapeScore}%"),
                _buildDetailRow(
                    Icons.texture,
                    "Tekstur",
                    result.textureScore > 70
                        ? "Halus mengkilap"
                        : "Sedikit Kasar",
                    Colors.orange,
                    "${result.textureScore}%"),
                _buildDetailRow(Icons.straighten, "Ukuran",
                    "Diameter Rata-rata", Colors.purple, "${result.sizeMm} mm"),

                const SizedBox(height: 30),

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
                      BoxShadow(
                          color: const Color(0xFFFF3B30).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Rekomendasi",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildRecItem(
                          Icons.restaurant, rec['status']!, rec['desc']!),
                      _buildRecItem(Icons.access_time, "Waktu Konsumsi",
                          rec['time']!),
                      _buildRecItem(
                          Icons.ac_unit, "Penyimpanan", rec['storage']!),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onTabChange != null) widget.onTabChange!(2);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Scan Tomat Lain",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (widget.onTabChange != null) widget.onTabChange!(3);
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text("Riwayat Scan"),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget baru untuk menampilkan detail analisis di sebelah histogram
  Widget _buildAnalysisDetailsBox(ScanResult result) {
    // Menentukan output perceptron berdasarkan label hasil scan
    String perceptronOutput = result.label == "RIPE" ? "1 0 0" : "0 0 1";

    // Normalisasi: Membagi nilai mean dengan nilai maksimum mean dari ketiga channel
    double maxMean = [_meanR, _meanG, _meanB].reduce((a, b) => a > b ? a : b);
    double normR = maxMean > 0 ? _meanR / maxMean : 0;
    double normG = maxMean > 0 ? _meanG / maxMean : 0;
    double normB = maxMean > 0 ? _meanB / maxMean : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailText("NILAI RGB", fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildDetailText("MAX RGB"),
          _buildDetailText("$_totalPixels", fontSize: 14, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          _buildDetailText("MEAN", fontWeight: FontWeight.bold),
          _buildDetailText("RED", color: Colors.red),
          _buildDetailText(_meanR.toStringAsFixed(8), color: Colors.red, fontSize: 11),
          _buildDetailText("GREEN", color: Colors.green),
          _buildDetailText(_meanG.toStringAsFixed(8), color: Colors.green, fontSize: 11),
          _buildDetailText("BLUE", color: Colors.blue),
          _buildDetailText(_meanB.toStringAsFixed(8), color: Colors.blue, fontSize: 11),
          const SizedBox(height: 12),
          _buildDetailText("NORMALISASI", fontWeight: FontWeight.bold),
          _buildDetailText(normR.toStringAsFixed(8), color: Colors.red, fontSize: 11),
          _buildDetailText(normG.toStringAsFixed(8), color: Colors.green, fontSize: 11),
          _buildDetailText(normB.toStringAsFixed(8), color: Colors.blue, fontSize: 11),
          const SizedBox(height: 12),
          _buildDetailText("HASIL PROSES", fontWeight: FontWeight.bold),
          _buildDetailText("PERCEPTRON", fontWeight: FontWeight.bold),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade100,
            ),
            child: Text(perceptronOutput, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
          ),
          const SizedBox(height: 12),
          _buildDetailText("TARGET :", fontWeight: FontWeight.bold),
          _buildTargetBox("1 0 0", "matang", Colors.red),
          _buildTargetBox("0 1 0", "mentah", Colors.green),
        ],
      ),
    );
  }

  Widget _buildDetailText(String text, {double fontSize = 12, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black87}) {
    return Text(text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color));
  }

  Widget _buildTargetBox(String values, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade50,
            ),
            child: Text(values, style: const TextStyle(fontSize: 11, letterSpacing: 2)),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: color, height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildLabeledHistogram(String title, List<int> data, Color color) {
    if (data.isEmpty) return const SizedBox();

    int maxVal = 0;
    
    if (data.length >= 251) {
      for (int i = 5; i < 251; i++) {
        if (data[i] > maxVal) maxVal = data[i];
      }
    }
    
    if (maxVal < 5) {
      for (var v in data) {
        if (v > maxVal) maxVal = v;
      }
    }
    
    if (maxVal == 0) maxVal = 100; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 5),

        SizedBox(
          height: 100,
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$maxVal", style: const TextStyle(fontSize: 9, color: Colors.grey)),
                  Text("${(maxVal / 2).floor()}", style: const TextStyle(fontSize: 9, color: Colors.grey)),
                  const Text("0", style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 5),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                    color: Colors.white,
                  ),
                  child: ClipRect(
                    child: CustomPaint(
                      painter: SingleChannelHistogramPainter(
                        counts: data, 
                        color: color
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.only(left: 25.0, top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("0", style: TextStyle(fontSize: 9, color: Colors.grey)),
              Text("128", style: TextStyle(fontSize: 9, color: Colors.grey)),
              Text("255", style: TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildStatusItem(IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
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
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
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
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))]))
        ],
      ),
    );
  }
}

class SingleChannelHistogramPainter extends CustomPainter {
  final List<int> counts;
  final Color color;

  SingleChannelHistogramPainter({required this.counts, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (counts.isEmpty) return;

    final paint = Paint()..color = color.withOpacity(0.6)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5;

    int maxVal = 1;
    
    for (int i = 5; i < 251; i++) { 
      if (counts[i] > maxVal) maxVal = counts[i];
    }
    if (maxVal < 5) {
       for (var v in counts) if (v > maxVal) maxVal = v;
    }

    final path = Path();
    double binWidth = size.width / 256;

    path.moveTo(0, size.height); 
    for (int i = 0; i < 256; i++) {
      double x = i * binWidth;
      
      double barHeight = (counts[i] / maxVal * size.height);
      
      if (barHeight > size.height) barHeight = size.height; 
      
      path.lineTo(x, size.height - barHeight);
    }
    path.lineTo(size.width, size.height); 
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint); 
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}