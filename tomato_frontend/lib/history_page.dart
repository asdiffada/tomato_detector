import 'package:flutter/material.dart';
import 'history_service.dart';
import 'api_service.dart';
import 'widgets.dart'; 
import 'analysis_page.dart'; 

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = "Semua"; 

  // Fungsi Filter dipindah ke dalam agar bisa menerima list dinamis
  List<ScanResult> _filterData(List<ScanResult> allData) {
    final now = DateTime.now();

    if (_selectedFilter == "Hari Ini") {
      return allData.where((item) {
        return item.timestamp.year == now.year &&
               item.timestamp.month == now.month &&
               item.timestamp.day == now.day;
      }).toList();
    } else if (_selectedFilter == "Minggu Ini") {
      return allData.where((item) {
        return now.difference(item.timestamp).inDays <= 7;
      }).toList();
    } else if (_selectedFilter == "Bulan Ini") {
      return allData.where((item) {
        return item.timestamp.year == now.year &&
               item.timestamp.month == now.month;
      }).toList();
    }
    return allData; 
  }

  // Helper hitung statistik
  int _countByLabel(List<ScanResult> data, String label) {
    return data.where((e) => e.label == label).length;
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
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3B30),
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
                  color: Colors.white.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.5)
                ),
                child: const Icon(Icons.menu, color: Colors.white, size: 20),
              ),
            );
          }
        ),
        title: const Text(
          "Riwayat Scan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      // --- WRAP DENGAN VALUE LISTENABLE BUILDER ---
      body: ValueListenableBuilder<List<ScanResult>>(
        valueListenable: HistoryService.historyNotifier, // Mendengarkan perubahan
        builder: (context, allHistory, child) {
          
          // Data yang ditampilkan di UI diambil dari 'allHistory' yang real-time
          final displayList = _filterData(allHistory);
          
          final mentahCount = _countByLabel(allHistory, "UNRIPE");
          final setengahCount = _countByLabel(allHistory, "TURNING");
          final matangCount = _countByLabel(allHistory, "RIPE");

          return Column(
            children: [
              // STATS HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                color: Colors.white,
                child: Row(
                  children: [
                    _buildStatCard("Mentah", mentahCount, const Color(0xFF00C853)), 
                    const SizedBox(width: 10),
                    _buildStatCard("Setengah", setengahCount, const Color(0xFFFFAB00)), 
                    const SizedBox(width: 10),
                    _buildStatCard("Matang", matangCount, const Color(0xFFFF3B30)), 
                  ],
                ),
              ),

              // FILTER TABS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterBtn("Semua"),
                    const SizedBox(width: 10),
                    _buildFilterBtn("Hari Ini"),
                    const SizedBox(width: 10),
                    _buildFilterBtn("Minggu Ini"),
                    const SizedBox(width: 10),
                    _buildFilterBtn("Bulan Ini"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // LIST HISTORY
              Expanded(
                child: displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text(
                              "Tidak ada riwayat scan $_selectedFilter",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: displayList.length + 1, 
                        itemBuilder: (context, index) {
                          if (index == displayList.length) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  "Tidak ada riwayat scan lainnya",
                                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                ),
                              ),
                            );
                          }

                          final item = displayList[index];
                          String confidenceStr = item.confidence.contains('%') 
                              ? item.confidence 
                              : "${item.confidence}%";

                          return _buildHistoryCard(item, confidenceStr, index);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDERS (SAMA SEPERTI SEBELUMNYA) ---

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(String text) {
    bool isActive = _selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF3B30) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ScanResult item, String confidence, int index) {
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

    return GestureDetector(
      onTap: () {
        HistoryService.latestResult = item;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalysisPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ],
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(item.timestamp),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}