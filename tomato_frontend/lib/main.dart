import 'package:flutter/material.dart';
import 'home_page.dart';
import 'scan_page.dart';
import 'analysis_page.dart';
import 'history_page.dart';
import 'discover_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tomato Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF3B30)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // 0: HOME
      HomePage(
        onScanPress: () => _onTabTapped(2), 
        onHistoryPress: () => _onTabTapped(3), // <-- TAMBAHAN: Pindah ke Tab History (Index 3)
      ),
      
      // 1: ANALYSIS
      AnalysisPage(onTabChange: _onTabTapped), 
      
      // 2: SCAN
      ScanPage(onTabChange: _onTabTapped, isActive: _currentIndex == 2),
      
      // 3: HISTORY
      const HistoryPage(), 
      
      // 4: DISCOVER
      const DiscoverPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2), 
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFFFF3B30), 
          unselectedItemColor: Colors.grey[400],    
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Analysis'),
            BottomNavigationBarItem(
              icon: Container(
                margin: const EdgeInsets.only(bottom: 4), 
                padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30), 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3B30).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
              ),
              label: 'Scan',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
            const BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Discover'),
          ],
        ),
      ),
    );
  }
}