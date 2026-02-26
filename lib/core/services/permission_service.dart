import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<PermissionStatus> cameraStatus();

  Future<PermissionStatus> requestCamera();

  Future<bool> openSettings();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<PermissionStatus> cameraStatus() {
    return Permission.camera.status;
  }

  @override
  Future<PermissionStatus> requestCamera() {
    return Permission.camera.request();
  }

  @override
  Future<bool> openSettings() {
    return openAppSettings();
  }
}
