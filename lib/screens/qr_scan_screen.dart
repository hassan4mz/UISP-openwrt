import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/services.dart';


/// QR code scanning screen for device discovery
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final DiscoveryService _discoveryService = DiscoveryService();
  MobileScannerController? _controller;
  bool _hasProcessedCode = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Localization removed
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_hasProcessedCode) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQrData(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Scan the QR code on your device',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQrData(String data) async {
    setState(() => _hasProcessedCode = true);
    
    try {
      final deviceInfo = _discoveryService.parseQrCodeData(data);
      
      if (deviceInfo != null && deviceInfo.ipAddress != null) {
        // Try to add the device
        await _discoveryService.addDeviceByIp(deviceInfo.ipAddress!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Device ${deviceInfo.hostname} added')),
          );
          Navigator.pop(context);
        }
      } else if (data.startsWith('http')) {
        // It's a setup URL
        final uri = Uri.parse(data);
        if (uri.host.isNotEmpty) {
          await _discoveryService.addDeviceByIp(uri.host);
          
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code format')),
          );
          setState(() => _hasProcessedCode = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _hasProcessedCode = false);
      }
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    final path = Path()
      ..addRect(Rect.largest)
      ..addRect(rect)
      ..fillType = PathFillType.evenOdd;

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Draw corner markers
    final markerPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const markerLength = 30.0;
    
    // Top-left
    canvas.drawLine(
      Offset(rect.left - 10, rect.top),
      Offset(rect.left + markerLength, rect.top),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top - 10),
      Offset(rect.left, rect.top + markerLength),
      markerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right - markerLength, rect.top),
      Offset(rect.right + 10, rect.top),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top - 10),
      Offset(rect.right, rect.top + markerLength),
      markerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left - 10, rect.bottom),
      Offset(rect.left + markerLength, rect.bottom),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom - markerLength),
      Offset(rect.left, rect.bottom + 10),
      markerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right - markerLength, rect.bottom),
      Offset(rect.right + 10, rect.bottom),
      markerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - markerLength),
      Offset(rect.right, rect.bottom + 10),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
