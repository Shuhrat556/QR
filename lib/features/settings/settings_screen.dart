import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner_generator/core/services/action_launcher_service.dart';
import 'package:qr_scanner_generator/core/services/permission_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PermissionStatus? _cameraStatus;

  @override
  void initState() {
    super.initState();
    _loadCameraStatus();
  }

  Future<void> _loadCameraStatus() async {
    final permissionService = context.read<PermissionService>();
    final status = await permissionService.cameraStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _buildVersionCard(),
          const SizedBox(height: 12),
          _buildPrivacyCard(context),
          const SizedBox(height: 12),
          _buildPermissionCard(context),
        ],
      ),
    );
  }

  Widget _buildVersionCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('App Version'),
        subtitle: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading...');
            }
            final info = snapshot.data!;
            return Text('${info.version}+${info.buildNumber}');
          },
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Privacy',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('All QR data is stored locally. Nothing is uploaded to servers.'),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _openPrivacyPolicy(context),
              child: const Text('Open Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context) {
    final statusText = _cameraStatus == null
        ? 'Loading...'
        : (_cameraStatus!.isGranted
              ? 'Granted'
              : (_cameraStatus!.isPermanentlyDenied ? 'Permanently denied' : 'Denied'));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Camera Permission',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Current status: $statusText'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: _requestPermission,
                  child: const Text('Request Permission'),
                ),
                OutlinedButton(
                  onPressed: _openSettings,
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: _loadCameraStatus,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final launcher = context.read<ActionLauncherService>();
    try {
      await launcher.openPrivacyPolicy();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open privacy policy: $error')),
      );
    }
  }

  Future<void> _requestPermission() async {
    final permissionService = context.read<PermissionService>();
    await permissionService.requestCamera();
    await _loadCameraStatus();
  }

  Future<void> _openSettings() async {
    final permissionService = context.read<PermissionService>();
    await permissionService.openSettings();
    await _loadCameraStatus();
  }
}
