import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

abstract class ScanImageService {
  Future<String?> pickAndScanQr();
}

class ScanImageServiceImpl implements ScanImageService {
  ScanImageServiceImpl({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pickAndScanQr() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }

    final controller = MobileScannerController(
      autoStart: false,
      formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );

    try {
      final capture = await controller.analyzeImage(
        image.path,
        formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
      );
      final barcodes = capture?.barcodes;
      if (barcodes == null || barcodes.isEmpty) {
        return null;
      }

      final raw = barcodes.first.rawValue?.trim();
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return raw;
    } finally {
      unawaited(controller.dispose());
    }
  }
}
