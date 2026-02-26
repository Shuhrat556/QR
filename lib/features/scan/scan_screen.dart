import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/core/services/scan_image_service.dart';
import 'package:qr_scanner_generator/core/utils/type_mapper.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/result/result_screen.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_cubit.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_state.dart';
import 'package:uuid/uuid.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final MobileScannerController _controller;
  bool _cameraRunning = false;
  double _zoomScale = 1;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: false,
      formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );
    unawaited(context.read<ScanCubit>().ensurePermissionOnStartup());
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              onRequestPermission: () =>
                  context.read<ScanCubit>().requestPermission(),
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
                  if (!context.read<ScanCubit>().canProcessValue(
                    rawValue,
                    now,
                  )) {
                    return;
                  }

                  unawaited(_handleDetectedValue(rawValue));
                },
              ),
              Positioned(
                top: 16,
                left: 16,
                child: _RoundButton(
                  icon: Icons.menu,
                  onPressed: widget.onOpenDrawer,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  children: <Widget>[
                    _RoundButton(
                      icon: Icons.photo_library,
                      onPressed: _scanFromImage,
                    ),
                    const SizedBox(width: 8),
                    _RoundButton(
                      icon: state.torchEnabled
                          ? Icons.flash_on
                          : Icons.flash_off,
                      onPressed: () async {
                        final scanCubit = context.read<ScanCubit>();
                        await _controller.toggleTorch();
                        if (!mounted) {
                          return;
                        }
                        scanCubit.setTorchEnabled(!state.torchEnabled);
                      },
                    ),
                    const SizedBox(width: 8),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            l10n.scanHint,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.zoom_in, color: Colors.white),
                              Expanded(
                                child: Slider(
                                  value: _zoomScale,
                                  min: 0,
                                  max: 1,
                                  onChanged: (value) {
                                    setState(() {
                                      _zoomScale = value;
                                    });
                                    _controller.setZoomScale(value);
                                  },
                                ),
                              ),
                              const Icon(Icons.zoom_out, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
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
      await _controller.setZoomScale(_zoomScale);
    } catch (_) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.failedStartCamera);
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

  Future<void> _scanFromImage() async {
    final l10n = AppLocalizations.of(context)!;
    final scanImageService = context.read<ScanImageService>();

    await _stopScanner();

    try {
      final rawValue = await scanImageService.pickAndScanQr();
      if (!mounted) {
        return;
      }

      if (rawValue == null || rawValue.isEmpty) {
        _showSnackBar(l10n.noQrFoundInImage);
        await _startScanner();
        return;
      }

      await _handleDetectedValue(rawValue);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(l10n.failedReadImage);
      await _startScanner();
    }
  }

  Future<void> _handleDetectedValue(String rawValue) async {
    final l10n = AppLocalizations.of(context)!;
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
      _showSnackBar('${l10n.scanHandlingFailed}: $error');
    } finally {
      if (mounted) {
        scanCubit.resetDetectionLock();
        await _startScanner();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.camera_alt_outlined, size: 56),
            const SizedBox(height: 12),
            Text(l10n.cameraPermissionRequired, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRequestPermission,
              child: Text(l10n.grantCameraPermission),
            ),
            if (isPermanentlyDenied) ...<Widget>[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => onOpenSettings(),
                child: Text(l10n.openSettings),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

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
