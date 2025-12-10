import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // IMPORT SUDAH DITAMBAHKAN
import 'dart:io';
import 'history_service.dart';
import 'widgets.dart';

class HistoryPage extends StatefulWidget {
  final Function(int)? onTabChange;

  const HistoryPage({super.key, this.onTabChange});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = "Semua";

  List<ScanResult> _filterData(List<ScanResult> allData) {
    if (_selectedFilter == "Semua") return allData;

    final now = DateTime.now();
    return allData.where((item) {
      final itemDate = item.timestamp;
      if (_selectedFilter == "Hari Ini") {
        return itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day;
      } else if (_selectedFilter == "Minggu Ini") {
        final difference = now.difference(itemDate).inDays;
        return difference <= 7;
      } else if (_selectedFilter == "Bulan Ini") {
        return itemDate.year == now.year && itemDate.month == now.month;
      }
      return true;
    }).toList();
  }

  int _countByLabel(List<ScanResult> data, String label) {
    return data.where((item) => item.label == label).length;
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
          builder: (context) {
            return InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFFFF3B30), width: 1.5),
                ),
                child: const Icon(Icons.menu,
                    color: Color(0xFFFF3B30), size: 20),
              ),
            );
          },
        ),
        title: const Text(
          "History",
          style: TextStyle(
              color: Color(0xFFFF3B30), fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<ScanResult>>(
        valueListenable: HistoryService.historyNotifier,
        builder: (context, allHistory, child) {
          final sortedHistory = List<ScanResult>.from(allHistory)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final displayList = _filterData(sortedHistory);
          final mentahCount = _countByLabel(allHistory, "UNRIPE");
          final matangCount = _countByLabel(allHistory, "RIPE");

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                color: Colors.white,
                child: Row(
                  children: [
                    _buildStatCard("Mentah", mentahCount,
                        const Color(0xFF00C853)),
                    const SizedBox(width: 10),
                    _buildStatCard("Matang", matangCount,
                        const Color(0xFFFF3B30)),
                  ],
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

              Expanded(
                child: displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 60, color: Colors.grey[300]),
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
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12),
                                ),
                              ),
                            );
                          }

                          final item = displayList[index];
                          String confidenceStr =
                              item.confidence.contains('%')
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

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(String text) {
    bool isSelected = _selectedFilter == text;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF3B30) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ScanResult item, String confidence, int index) {
    final bool isRipe = item.label == "RIPE";
    final Color statusColor =
        isRipe ? const Color(0xFFFF3B30) : const Color(0xFF00C853);
    final String statusText = isRipe ? "Matang" : "Mentah";

    // PERBAIKAN: Gunakan hashCode karena 'id' tidak ada di ScanResult
    String itemId = item.hashCode.toString().substring(0, 3);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Logic pindah tab
            HistoryService.latestResult = item;
            if (widget.onTabChange != null) {
              widget.onTabChange!(1); 
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.image != null && item.image!.existsSync()
                      ? Image.file(
                          item.image!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tomat #$itemId", // FIXED
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tingkat Akurasi: $confidence",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // Format tanggal sekarang aman karena intl sudah diimport
                        DateFormat('EEE, d MMM y • HH:mm')
                            .format(item.timestamp),
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}