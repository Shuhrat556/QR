import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/core/utils/type_mapper.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/result/result_screen.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_cubit.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_state.dart';
import 'package:uuid/uuid.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final MobileScannerController _controller;
  bool _cameraRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: false,
      formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );
    unawaited(context.read<ScanCubit>().refreshPermission());
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state.hasPermission) {
            _startScanner();
          } else {
            _stopScanner();
          }
        },
        builder: (context, state) {
          if (!state.hasPermission) {
            return _PermissionStateView(
              isPermanentlyDenied: state.isPermanentlyDenied,
              onRequestPermission: () => context.read<ScanCubit>().requestPermission(),
              onOpenSettings: () => context.read<ScanCubit>().openSettings(),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isEmpty) {
                    return;
                  }

                  final rawValue = barcodes.first.rawValue?.trim();
                  if (rawValue == null || rawValue.isEmpty) {
                    return;
                  }

                  final now = DateTime.now().millisecondsSinceEpoch;
                  if (!context.read<ScanCubit>().canProcessValue(rawValue, now)) {
                    return;
                  }

                  unawaited(_handleDetectedValue(rawValue));
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  children: <Widget>[
                    _RoundButton(
                      icon: state.torchEnabled ? Icons.flash_on : Icons.flash_off,
                      onPressed: () async {
                        final scanCubit = context.read<ScanCubit>();
                        await _controller.toggleTorch();
                        if (!mounted) {
                          return;
                        }
                        scanCubit.setTorchEnabled(!state.torchEnabled);
                      },
                    ),
                    const SizedBox(width: 12),
                    _RoundButton(
                      icon: Icons.cameraswitch,
                      onPressed: () => _controller.switchCamera(),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Point camera at a QR code',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startScanner() async {
    if (_cameraRunning) {
      return;
    }

    try {
      await _controller.start();
      _cameraRunning = true;
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Failed to start camera.');
    }
  }

  Future<void> _stopScanner() async {
    if (!_cameraRunning) {
      return;
    }

    try {
      await _controller.stop();
    } catch (_) {
      // Keep UI stable even if stop fails.
    } finally {
      _cameraRunning = false;
    }
  }

  Future<void> _handleDetectedValue(String rawValue) async {
    final parser = context.read<QrContentParser>();
    final historyRepository = context.read<HistoryRepository>();
    final historyCubit = context.read<HistoryCubit>();
    final scanCubit = context.read<ScanCubit>();
    final navigator = Navigator.of(context);

    await _stopScanner();

    final parsed = parser.parse(rawValue);

    try {
      final historyItem = HistoryItem(
        id: const Uuid().v4(),
        source: HistorySource.scanned,
        inputType: mapParsedTypeToInputType(parsed.type),
        rawValue: rawValue,
        displayValue: parsed.displayValue,
        createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      );

      await historyRepository.upsert(historyItem);
      if (!mounted) {
        return;
      }
      await historyCubit.load();
      if (!mounted) {
        return;
      }

      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(rawValue: rawValue),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Scan handling failed: $error');
    } finally {
      if (mounted) {
        scanCubit.resetDetectionLock();
        await _startScanner();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PermissionStateView extends StatelessWidget {
  const _PermissionStateView({
    required this.isPermanentlyDenied,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  final bool isPermanentlyDenied;
  final VoidCallback onRequestPermission;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.camera_alt_outlined, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Camera permission is required to scan QR codes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRequestPermission,
              child: const Text('Grant Camera Permission'),
            ),
            if (isPermanentlyDenied) ...<Widget>[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => onOpenSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
