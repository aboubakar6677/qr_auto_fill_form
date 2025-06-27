import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'qr_auto_fill_controller.dart';

Future<void> launchQRFormScanner({
  required context,
  required QRFormAutoFillController controller,
  VoidCallback? onBeforeScan,
  bool showConfirmation = false,
  String? confirmTitle,
  String? confirmContent,
  String successMessage = "Form auto-filled from QR",
  String errorMessage = "Invalid QR code format",
  QRDataFormat format = QRDataFormat.json, // Default to JSON
}) async {
  onBeforeScan?.call();

  try {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QRScannerScreen()));

    if (result != null && result.isNotEmpty) {
      try {
        // Fill the form using the selected format

        // Optional: Show confirmation dialog
        if (showConfirmation) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(confirmTitle ?? 'Confirm Auto-Fill'),
              content: Text(
                confirmContent ??
                    'Do you want to fill the form with this data?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );

          if (confirmed != true) return;
        }
        controller.fillFromRawQRData(result, format: format);

        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
      } catch (e) {
        debugPrint('Error parsing QR data: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  } catch (e) {
    debugPrint('QR scan failed: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('QR scan failed: ${e.toString()}')));
  }
}

class QRScannerScreen extends StatefulWidget {
  final Color overlayColor;
  final double cutoutSize;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final bool showFlashToggle;
  final bool showCloseButton;
  final String title;
  final Color appBarColor;
  final Color appBarForegroundColor;

  const QRScannerScreen({
    super.key,
    this.overlayColor = Colors.blue,
    this.cutoutSize = 0.7,
    this.borderRadius = 16,
    this.borderLength = 30,
    this.borderWidth = 6,
    this.showFlashToggle = true,
    this.showCloseButton = true,
    this.title = "Scan QR Code",
    this.appBarColor = Colors.blue,
    this.appBarForegroundColor = Colors.white,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isFlashOn = false;
  bool _hasScanned = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCameraLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    setState(() => _isCameraLoading = false);

    _controller?.scannedDataStream.listen((scanData) async {
      if (!_hasScanned && scanData.code != null) {
        _hasScanned = true;
        await _controller?.pauseCamera();

        if (!mounted) return; // ✅ Guard context
        Navigator.pop(context, scanData.code);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildOverlay() {
    final size = MediaQuery.of(context).size;
    final cutoutSize = size.width * widget.cutoutSize;

    return Stack(
      alignment: Alignment.center,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withAlpha(100),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
                child: Center(
                  child: Container(
                    width: cutoutSize,
                    height: cutoutSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: (size.height - cutoutSize) / 2.3,
          left: (size.width - cutoutSize) / 2,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Transform.translate(
                offset: Offset(0, cutoutSize * _animation.value),
                child: Container(
                  width: cutoutSize,
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.overlayColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cutOut = MediaQuery.of(context).size.width * widget.cutoutSize;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        foregroundColor: widget.appBarForegroundColor,
        title: Text(widget.title),
        actions: [
          if (widget.showFlashToggle)
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_off : Icons.flash_on,
                // color: Colors.white,
              ),
              onPressed: () async {
                await _controller?.toggleFlash();
                bool? isOn = await _controller?.getFlashStatus();
                setState(() => _isFlashOn = isOn ?? false);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: widget.overlayColor,
              borderRadius: widget.borderRadius,
              borderLength: widget.borderLength,
              borderWidth: widget.borderWidth,
              cutOutSize: cutOut,
            ),
          ),
          _buildOverlay(),
          if (_isCameraLoading)
            const Center(child: CircularProgressIndicator()),
          if (widget.showCloseButton)
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text("Cancel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _controller?.stopCamera();
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
    );
  }
}
