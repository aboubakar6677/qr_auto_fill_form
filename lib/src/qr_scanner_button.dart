import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'qr_auto_fill_controller.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// /// A controller for managing QR-based form auto-filling
// class QRFormAutoFillController {
//   final Map<String, dynamic> Function(Map<String, dynamic>)? dataValidator;
//   final void Function(Map<String, dynamic>)? onDataFilled;

//   QRFormAutoFillController({
//     this.dataValidator,
//     this.onDataFilled,
//   });

//   /// Fills form data from QR code content
//   void fillFromQRData(Map<String, dynamic> data) {
//     try {
//       // Validate data if validator is provided
//       final validatedData = dataValidator?.call(data) ?? data;

//       // Notify about filled data
//       onDataFilled?.call(validatedData);
//     } catch (e) {
//       throw FormatException('Failed to process QR data: ${e.toString()}');
//     }
//   }
// }

/// A customizable button that launches QR scanner and auto-fills form
class QRScannerButton extends StatefulWidget {
  /// Controller for form auto-fill functionality
  final QRFormAutoFillController controller;

  /// Button text
  final String buttonText;

  /// Button icon
  final IconData icon;

  /// Custom button style
  final ButtonStyle? style;

  /// Success message when QR is scanned successfully
  final String? successMessage;

  /// Error message when QR format is invalid
  final String? errorMessage;

  /// Duration to show success/error messages
  final Duration messageDuration;

  /// Whether to show a confirmation dialog before filling form
  final bool showConfirmation;

  /// Confirmation dialog title
  final String? confirmationTitle;

  /// Confirmation dialog content
  final String? confirmationContent;

  const QRScannerButton({
    super.key,
    required this.controller,
    this.buttonText = "Scan QR",
    this.icon = Icons.qr_code_scanner,
    this.style,
    this.successMessage = 'Form auto-filled from QR',
    this.errorMessage = 'Invalid QR code format',
    this.messageDuration = const Duration(seconds: 2),
    this.showConfirmation = false,
    this.confirmationTitle = 'Confirm Auto-Fill',
    this.confirmationContent = 'Do you want to fill the form with this data?',
  });

  @override
  State<QRScannerButton> createState() => _QRScannerButtonState();
}

class _QRScannerButtonState extends State<QRScannerButton> {
  bool _isLoading = false;

  Future<void> _scanQR(BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const QRScannerScreen()));

      if (result != null && result is String) {
        _processQRResult(context, result);
      }
    } on PlatformException catch (e) {
      _showMessage(context, 'Camera permission denied: ${e.message}');
    } catch (e) {
      _showMessage(context, 'Failed to scan QR: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processQRResult(BuildContext context, String result) async {
    try {
      final parsed = json.decode(result);
      if (parsed is Map<String, dynamic>) {
        if (widget.showConfirmation) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(widget.confirmationTitle!),
              content: Text(widget.confirmationContent!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );

          if (confirmed != true) return;
        }

        widget.controller.fillFromQRData(parsed);
        _showMessage(context, widget.successMessage);
      } else {
        _showMessage(context, widget.errorMessage);
      }
    } on FormatException catch (_) {
      _showMessage(context, widget.errorMessage);
    }
  }

  void _showMessage(BuildContext context, String? message) {
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: widget.messageDuration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: widget.style ?? _defaultButtonStyle(context),
      onPressed: _isLoading ? null : () => _scanQR(context),
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon),
      label: Text(_isLoading ? 'Scanning...' : widget.buttonText),
    );
  }

  ButtonStyle _defaultButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

/// Full-screen QR scanner with customizable UI
class QRScannerScreen extends StatefulWidget {
  /// Color of the scanner overlay border
  final Color overlayColor;

  /// Size of the cutout area (percentage of screen width)
  final double cutoutSize;

  /// Border radius of the cutout
  final double borderRadius;

  /// Length of the border corners
  final double borderLength;

  /// Width of the border
  final double borderWidth;

  /// Whether to show flash toggle button
  final bool showFlashToggle;

  /// Whether to show close button
  final bool showCloseButton;

  /// AppBar title
  final String title;

  /// AppBar background color
  final Color appBarColor;

  const QRScannerScreen({
    super.key,
    this.overlayColor = Colors.teal,
    this.cutoutSize = 0.7,
    this.borderRadius = 12,
    this.borderLength = 30,
    this.borderWidth = 8,
    this.showFlashToggle = true,
    this.showCloseButton = true,
    this.title = "Scan QR Code",
    this.appBarColor = Colors.black,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isScanned = false;
  bool _isFlashOn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    _controller?.scannedDataStream.listen((scanData) {
      if (!_isScanned && scanData.code != null) {
        _isScanned = true;
        _controller?.pauseCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }

  Widget _buildScannerOverlay() {
    final size = MediaQuery.of(context).size;
    final cutoutSize = size.width * widget.cutoutSize;

    return Stack(
      children: [
        // Semi-transparent overlay
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
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
        // Animated scanning line
        Positioned(
          top: (size.height - cutoutSize) / 2,
          left: (size.width - cutoutSize) / 2,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, cutoutSize * _animation.value),
                child: Container(
                  width: cutoutSize,
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.overlayColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
        // Border corners
        _buildCorner(cutoutSize, Alignment.topLeft, [
          Alignment.topLeft,
          Alignment.topRight,
          Alignment.bottomLeft,
        ]),
        _buildCorner(cutoutSize, Alignment.topRight, [
          Alignment.topRight,
          Alignment.topLeft,
          Alignment.bottomRight,
        ]),
        _buildCorner(cutoutSize, Alignment.bottomLeft, [
          Alignment.bottomLeft,
          Alignment.topLeft,
          Alignment.bottomRight,
        ]),
        _buildCorner(cutoutSize, Alignment.bottomRight, [
          Alignment.bottomRight,
          Alignment.topRight,
          Alignment.bottomLeft,
        ]),
      ],
    );
  }

  Widget _buildCorner(double size, Alignment alignment, List<Alignment> edges) {
    return Align(
      alignment: alignment,
      child: Container(
        width: widget.borderLength,
        height: widget.borderLength,
        decoration: BoxDecoration(
          border: Border(
            top:
                edges.contains(Alignment.topLeft) ||
                    edges.contains(Alignment.topRight)
                ? BorderSide(
                    color: widget.overlayColor,
                    width: widget.borderWidth,
                  )
                : BorderSide.none,
            left:
                edges.contains(Alignment.topLeft) ||
                    edges.contains(Alignment.bottomLeft)
                ? BorderSide(
                    color: widget.overlayColor,
                    width: widget.borderWidth,
                  )
                : BorderSide.none,
            right:
                edges.contains(Alignment.topRight) ||
                    edges.contains(Alignment.bottomRight)
                ? BorderSide(
                    color: widget.overlayColor,
                    width: widget.borderWidth,
                  )
                : BorderSide.none,
            bottom:
                edges.contains(Alignment.bottomLeft) ||
                    edges.contains(Alignment.bottomRight)
                ? BorderSide(
                    color: widget.overlayColor,
                    width: widget.borderWidth,
                  )
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    if (!widget.showCloseButton) return const SizedBox.shrink();

    return Positioned(
      bottom: 40,
      left: 30,
      right: 30,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.close),
        label: const Text("Cancel"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          _controller?.stopCamera();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.appBarColor,
        actions: [
          if (widget.showFlashToggle)
            IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_off : Icons.flash_on),
              onPressed: () {
                _controller?.toggleFlash();
                setState(() => _isFlashOn = !_isFlashOn);
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
              cutOutSize: MediaQuery.of(context).size.width * widget.cutoutSize,
            ),
          ),
          _buildScannerOverlay(),
          _buildCloseButton(),
        ],
      ),
    );
  }
}
