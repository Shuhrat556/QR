import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/services/permission_service.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit({required PermissionService permissionService})
    : _permissionService = permissionService,
      super(
        const ScanState(
          permissionStatus: PermissionStatus.denied,
          torchEnabled: false,
        ),
      );

  final PermissionService _permissionService;

  Future<void> refreshPermission() async {
    final status = await _permissionService.cameraStatus();
    emit(state.copyWith(permissionStatus: status));
  }

  Future<void> ensurePermissionOnStartup() async {
    if (state.startupChecked) {
      return;
    }

    final status = await _permissionService.cameraStatus();
    if (status.isDenied) {
      final requestedStatus = await _permissionService.requestCamera();
      emit(
        state.copyWith(permissionStatus: requestedStatus, startupChecked: true),
      );
      return;
    }

    emit(state.copyWith(permissionStatus: status, startupChecked: true));
  }

  Future<void> requestPermission() async {
    final status = await _permissionService.requestCamera();
    emit(state.copyWith(permissionStatus: status));
  }

  Future<bool> openSettings() {
    return _permissionService.openSettings();
  }

  void setTorchEnabled(bool enabled) {
    emit(state.copyWith(torchEnabled: enabled));
  }

  bool canProcessValue(String rawValue, int nowEpochMs) {
    final normalized = rawValue.trim();
    if (normalized.isEmpty) {
      return false;
    }

    final isDuplicate =
        state.lastRawValue == normalized &&
        nowEpochMs - state.lastScanEpochMs < AppConstants.duplicateScanWindowMs;

    if (isDuplicate) {
      return false;
    }

    emit(state.copyWith(lastRawValue: normalized, lastScanEpochMs: nowEpochMs));
    return true;
  }

  void resetDetectionLock() {
    emit(state.copyWith(clearLastRawValue: true, lastScanEpochMs: 0));
  }
}
