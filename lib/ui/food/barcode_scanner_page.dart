import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _hasResult = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasResult) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _hasResult = true;
      final String code = barcodes.first.rawValue!;
      _controller.dispose();
      Navigator.pop(context, code);
    }
  }

  void _simulateScan(String code) {
    _hasResult = true;
    _controller.dispose();
    Navigator.pop(context, code);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Barcode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            _controller.dispose();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scan Overlay Target Frame
          Center(
            child: Container(
              width: 280,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.03, duration: 1200.ms),

          // Instruction Text
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              children: [
                const Text(
                  "Align the barcode within the frame to scan",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Simulator/Mock Options
                const Text(
                  "Running on a simulator? Tap below to simulate:",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      label: const Text("Simulate Nutella"),
                      onPressed: () => _simulateScan("3017620422003"),
                    ),
                    ActionChip(
                      label: const Text("Simulate Coca-Cola"),
                      onPressed: () => _simulateScan("5449000000996"),
                    ),
                    ActionChip(
                      label: const Text("Simulate Oreo"),
                      onPressed: () => _simulateScan("7622300744948"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
