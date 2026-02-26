import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

abstract class QrImageService {
  Future<Uint8List> renderPng(String data, {int sizePx = 1024});

  Future<void> saveToGallery(Uint8List pngBytes, String fileName);

  Future<void> sharePng(Uint8List pngBytes, String fileName, {String? text});
}

class QrImageServiceImpl implements QrImageService {
  @override
  Future<Uint8List> renderPng(String data, {int sizePx = 1024}) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
    );

    final byteData = await painter.toImageData(
      sizePx.toDouble(),
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw StateError('Failed to render QR image data.');
    }

    return byteData.buffer.asUint8List();
  }

  @override
  Future<void> saveToGallery(Uint8List pngBytes, String fileName) async {
    await Gal.putImageBytes(pngBytes, name: fileName.replaceAll('.png', ''));
  }

  @override
  Future<void> sharePng(
    Uint8List pngBytes,
    String fileName, {
    String? text,
  }) async {
    final tempDirectory = await getTemporaryDirectory();
    final outputPath = '${tempDirectory.path}/$fileName';
    final file = File(outputPath);
    await file.writeAsBytes(pngBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: <XFile>[XFile(file.path, mimeType: 'image/png')],
      ),
    );
  }
}
