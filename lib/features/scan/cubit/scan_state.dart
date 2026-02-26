import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanState extends Equatable {
  const ScanState({
    required this.permissionStatus,
    required this.torchEnabled,
    this.lastRawValue,
    this.lastScanEpochMs = 0,
  });

  final PermissionStatus permissionStatus;
  final bool torchEnabled;
  final String? lastRawValue;
  final int lastScanEpochMs;

  bool get hasPermission => permissionStatus.isGranted;

  bool get isPermanentlyDenied => permissionStatus.isPermanentlyDenied;

  ScanState copyWith({
    PermissionStatus? permissionStatus,
    bool? torchEnabled,
    String? lastRawValue,
    int? lastScanEpochMs,
    bool clearLastRawValue = false,
  }) {
    return ScanState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      torchEnabled: torchEnabled ?? this.torchEnabled,
      lastRawValue: clearLastRawValue ? null : (lastRawValue ?? this.lastRawValue),
      lastScanEpochMs: lastScanEpochMs ?? this.lastScanEpochMs,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    permissionStatus,
    torchEnabled,
    lastRawValue,
    lastScanEpochMs,
  ];
}
