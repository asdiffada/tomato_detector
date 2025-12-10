import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'history_service.dart';
import 'widgets.dart';

class ScanPage extends StatefulWidget {
  final Function(int) onTabChange;
  final bool isActive; 

  const ScanPage({
    super.key, 
    required this.onTabChange, 
    required this.isActive
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _initCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isActive) _initCamera();
    }
  }

  @override
  void didUpdateWidget(ScanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _initCamera();
      } else {
        _disposeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (_isCameraInitialized) return;
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final camera = _cameras!.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );
        await _setupController(camera);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _setupController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(FlashMode.off);
      if (mounted) {
        setState(() {
          _controller = cameraController;
          _isCameraInitialized = true;
          _flashMode = FlashMode.off;
        });
      }
    } catch (e) {
      debugPrint("Setup Error: $e");
    }
  }

  Future<void> _disposeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _controller = null;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isCameraInitialized) return;
    FlashMode newMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(newMode);
      setState(() => _flashMode = newMode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur flash tidak didukung")));
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final XFile imageFile = await _controller!.takePicture();
      if (_flashMode == FlashMode.torch) {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => _flashMode = FlashMode.off);
      }
      await _processFile(File(imageFile.path));
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Gagal foto: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      await _processFile(File(pickedFile.path));
    }
  }

  Future<void> _processFile(File image) async {
    try {
      var apiResult = await ApiService.uploadImage(image);
      
      var details = apiResult['details'] ?? {};
      int colorScore = details['color_score'] ?? 0;
      int shapeScore = details['shape_score'] ?? 0;
      int textureScore = details['texture_score'] ?? 0;
      int sizeMm = details['size_mm'] ?? 0;
      String quality = details['quality'] ?? "Unknown";

      var newScan = ScanResult(
        image: image,
        imagePath: image.path, 
        label: apiResult['label'] ?? "Error",
        confidence: apiResult['confidence'] ?? "-",
        debugInfo: apiResult['debug_info'] ?? "-",
        colorStatus: apiResult['color_status'] ?? "grey",
        timestamp: DateTime.now(),
        colorScore: colorScore,
        shapeScore: shapeScore,
        textureScore: textureScore,
        sizeMm: sizeMm,
        quality: quality,
      );
      
      await HistoryService.addResult(newScan);

      if (mounted) {
        setState(() => _isLoading = false);
        widget.onTabChange(1);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError("Error: $e");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFFF3B30)),
              SizedBox(height: 20),
              Text("Menganalisis Tomat...", style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
      );
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
                  border: Border.all(color: const Color(0xFFFF3B30), width: 1.5)
                ),
                child: const Icon(Icons.menu, color: Color(0xFFFF3B30), size: 20),
              ),
            );
          }
        ),
        title: const Text(
          "Scan Tomat",
          style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isCameraInitialized && _controller != null)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return OverflowBox(
                            maxWidth: double.infinity,
                            maxHeight: double.infinity,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxWidth * _controller!.value.aspectRatio,
                              child: CameraPreview(_controller!),
                            ),
                          );
                        },
                      )
                    else
                      const Center(child: CircularProgressIndicator(color: Colors.white)),

                    Center(
                      child: Container(
                        width: 250, 
                        height: 250, 
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                    ),

                    Positioned(top: 15, left: 15, child: _cornerWidget(isTop: true, isLeft: true)),
                    Positioned(top: 15, right: 15, child: _cornerWidget(isTop: true, isLeft: false)),
                    Positioned(bottom: 15, left: 15, child: _cornerWidget(isTop: false, isLeft: true)),
                    Positioned(bottom: 15, right: 15, child: _cornerWidget(isTop: false, isLeft: false)),

                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Pusatkan tomat di dalam kotak putih",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Jaga jarak HP sekitar 15 cm dari tomat", 
                              style: TextStyle(color: Colors.white70, fontSize: 14, shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  const Text("Deteksi Kematangan Tomat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("Posisikan tomat di dalam frame agar akurat", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _controlButton(
                        icon: Icons.photo_library_outlined,
                        label: "Galeri",
                        color: const Color(0xFFFF3B30),
                        bgColor: const Color(0xFFFFEBEE),
                        onTap: _pickFromGallery,
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFFF3B30).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: const Icon(Icons.camera, color: Colors.white, size: 35),
                        ),
                      ),
                      _controlButton(
                        icon: _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                        label: _flashMode == FlashMode.off ? "Flash Off" : "Flash On",
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFFFFDE7),
                        onTap: _toggleFlash,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerWidget({required bool isTop, required bool isLeft}) {
    const double size = 30;
    const double thickness = 4;
    const Color color = Color(0xFFFF6B6B); 
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color, width: thickness) : BorderSide.none,
          left: isLeft ? BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: (isTop && isLeft) ? const Radius.circular(12) : Radius.zero,
          topRight: (isTop && !isLeft) ? const Radius.circular(12) : Radius.zero,
          bottomLeft: (!isTop && isLeft) ? const Radius.circular(12) : Radius.zero,
          bottomRight: (!isTop && !isLeft) ? const Radius.circular(12) : Radius.zero,
        )
      ),
    );
  }

  Widget _controlButton({
    required IconData icon, required String label, required Color color, required Color bgColor, required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}