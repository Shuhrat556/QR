import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner_generator/core/services/permission_service.dart';
import 'package:qr_scanner_generator/features/scan/cubit/scan_cubit.dart';
import 'package:qr_scanner_generator/features/scan/scan_screen.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';

class _FakePermissionService implements PermissionService {
  _FakePermissionService(this.status);

  final PermissionStatus status;

  @override
  Future<PermissionStatus> cameraStatus() async => status;

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<PermissionStatus> requestCamera() async => status;
}

void main() {
  testWidgets('shows recovery action when permission is permanently denied', (
    tester,
  ) async {
    final cubit = ScanCubit(
      permissionService: _FakePermissionService(
        PermissionStatus.permanentlyDenied,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<ScanCubit>.value(
          value: cubit,
          child: const Scaffold(body: ScanScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Camera permission is required to scan QR codes.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Open Settings'),
      findsOneWidget,
    );
  });
}
