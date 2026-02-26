import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner_generator/core/services/action_launcher_service.dart';
import 'package:qr_scanner_generator/core/services/permission_service.dart';
import 'package:qr_scanner_generator/features/preferences/cubit/app_preferences_cubit.dart';
import 'package:qr_scanner_generator/features/preferences/cubit/app_preferences_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

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
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              if (widget.onOpenDrawer != null)
                IconButton(
                  onPressed: widget.onOpenDrawer,
                  icon: const Icon(Icons.menu),
                  tooltip: l10n.menu,
                ),
              Text(
                l10n.settings,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAppearanceCard(context),
          const SizedBox(height: 12),
          _buildVersionCard(context),
          const SizedBox(height: 12),
          _buildPrivacyCard(context),
          const SizedBox(height: 12),
          _buildPermissionCard(context),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.appearance,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: state.themeMode,
                  decoration: InputDecoration(
                    labelText: l10n.themeMode,
                    border: const OutlineInputBorder(),
                  ),
                  items: <DropdownMenuItem<ThemeMode>>[
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.themeDark),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      context.read<AppPreferencesCubit>().setThemeMode(mode);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Locale>(
                  initialValue: state.locale,
                  decoration: InputDecoration(
                    labelText: l10n.language,
                    border: const OutlineInputBorder(),
                  ),
                  items: <DropdownMenuItem<Locale>>[
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l10n.langEnglish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('ru'),
                      child: Text(l10n.langRussian),
                    ),
                    DropdownMenuItem(
                      value: const Locale('tg'),
                      child: Text(l10n.langTajik),
                    ),
                    DropdownMenuItem(
                      value: const Locale('uz'),
                      child: Text(l10n.langUzbek),
                    ),
                  ],
                  onChanged: (locale) {
                    if (locale != null) {
                      context.read<AppPreferencesCubit>().setLocale(locale);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(l10n.appVersion),
        subtitle: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text(l10n.loading);
            }
            final info = snapshot.data!;
            return Text('${info.version}+${info.buildNumber}');
          },
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.privacy,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(l10n.privacyDescription),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _openPrivacyPolicy(context),
              child: Text(l10n.openPrivacyPolicy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final statusText = _cameraStatus == null
        ? l10n.loading
        : (_cameraStatus!.isGranted
              ? l10n.granted
              : (_cameraStatus!.isPermanentlyDenied
                    ? l10n.permanentlyDenied
                    : l10n.denied));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.cameraPermission,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('${l10n.currentStatus}: $statusText'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: _requestPermission,
                  child: Text(l10n.requestPermission),
                ),
                OutlinedButton(
                  onPressed: _openSettings,
                  child: Text(l10n.openSettings),
                ),
                TextButton(
                  onPressed: _loadCameraStatus,
                  child: Text(l10n.refresh),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final launcher = context.read<ActionLauncherService>();
    try {
      await launcher.openPrivacyPolicy();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.launchFailed}: $error')));
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
