import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner_generator/core/services/permission_service.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_cubit.dart';

class _FakePermissionService implements PermissionService {
  _FakePermissionService({required this.status});

  final PermissionStatus status;

  @override
  Future<PermissionStatus> cameraStatus() async => status;

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<PermissionStatus> requestCamera() async => status;
}

void main() {
  test('blocks duplicate scan values within 2 seconds', () {
    final cubit = ScanCubit(
      permissionService: _FakePermissionService(
        status: PermissionStatus.granted,
      ),
    );

    final firstAccepted = cubit.canProcessValue('ABC123', 1000);
    final secondAccepted = cubit.canProcessValue('ABC123', 2500);
    final thirdAccepted = cubit.canProcessValue('ABC123', 3100);

    expect(firstAccepted, isTrue);
    expect(secondAccepted, isFalse);
    expect(thirdAccepted, isTrue);
  });
}
