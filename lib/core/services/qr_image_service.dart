import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

abstract class QrImageService {
  Future<Uint8List> renderPng(
    String data, {
    int sizePx = 1024,
    Uint8List? embeddedImageBytes,
  });

  Future<void> saveToGallery(Uint8List pngBytes, String fileName);

  Future<void> sharePng(Uint8List pngBytes, String fileName, {String? text});
}

class QrImageServiceImpl implements QrImageService {
  @override
  Future<Uint8List> renderPng(
    String data, {
    int sizePx = 1024,
    Uint8List? embeddedImageBytes,
  }) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
    );

    if (embeddedImageBytes == null) {
      final byteData = await painter.toImageData(
        sizePx.toDouble(),
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw StateError('Failed to render QR image data.');
      }

      return byteData.buffer.asUint8List();
    }

    final qrImageData = await painter.toImageData(
      sizePx.toDouble(),
      format: ui.ImageByteFormat.png,
    );

    if (qrImageData == null) {
      throw StateError('Failed to render QR image data.');
    }

    final qrImage = await _decodeImage(qrImageData.buffer.asUint8List());
    final logoImage = await _decodeImage(embeddedImageBytes);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, sizePx.toDouble(), sizePx.toDouble()),
    );

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, sizePx.toDouble(), sizePx.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    final fullRect = ui.Rect.fromLTWH(
      0,
      0,
      sizePx.toDouble(),
      sizePx.toDouble(),
    );
    canvas.drawImageRect(
      qrImage,
      ui.Rect.fromLTWH(
        0,
        0,
        qrImage.width.toDouble(),
        qrImage.height.toDouble(),
      ),
      fullRect,
      ui.Paint(),
    );

    final logoSize = sizePx * 0.22;
    final logoRect = ui.Rect.fromCenter(
      center: ui.Offset(sizePx / 2, sizePx / 2),
      width: logoSize,
      height: logoSize,
    );

    final whitePadRect = ui.RRect.fromRectAndRadius(
      logoRect.inflate(logoSize * 0.14),
      ui.Radius.circular(logoSize * 0.16),
    );

    canvas.drawRRect(
      whitePadRect,
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    canvas.drawImageRect(
      logoImage,
      ui.Rect.fromLTWH(
        0,
        0,
        logoImage.width.toDouble(),
        logoImage.height.toDouble(),
      ),
      logoRect,
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(sizePx, sizePx);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      throw StateError('Failed to render QR image with embedded logo.');
    }

    return bytes.buffer.asUint8List();
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
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
