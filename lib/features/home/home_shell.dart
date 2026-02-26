import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/core/services/action_launcher_service.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/core/services/scan_image_service.dart';
import 'package:qr_scanner_generator/core/utils/type_mapper.dart';
import 'package:qr_scanner_generator/features/generate/generate_screen.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/history/history_screen.dart';
import 'package:qr_scanner_generator/features/home/cubit/navigation_cubit.dart';
import 'package:qr_scanner_generator/features/my_qr/my_qr_screen.dart';
import 'package:qr_scanner_generator/features/result/result_screen.dart';
import 'package:qr_scanner_generator/features/scan/scan_screen.dart';
import 'package:qr_scanner_generator/features/settings/settings_screen.dart';
import 'package:uuid/uuid.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<NavigationCubit, AppSection>(
      builder: (context, section) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.taglineCreateScanShare),
                    ],
                  ),
                ),
                _drawerSectionItem(
                  icon: Icons.qr_code_scanner,
                  label: l10n.scan,
                  isSelected: section == AppSection.scan,
                  onTap: () => _selectSection(AppSection.scan),
                ),
                _drawerActionItem(
                  icon: Icons.photo_library,
                  label: l10n.scanImage,
                  onTap: _scanFromImage,
                ),
                _drawerSectionItem(
                  icon: Icons.star,
                  label: l10n.favorites,
                  isSelected: section == AppSection.favorites,
                  onTap: () => _selectSection(AppSection.favorites),
                ),
                _drawerSectionItem(
                  icon: Icons.history,
                  label: l10n.history,
                  isSelected: section == AppSection.history,
                  onTap: () => _selectSection(AppSection.history),
                ),
                _drawerSectionItem(
                  icon: Icons.badge,
                  label: l10n.myQr,
                  isSelected: section == AppSection.myQr,
                  onTap: () => _selectSection(AppSection.myQr),
                ),
                _drawerSectionItem(
                  icon: Icons.qr_code_2,
                  label: l10n.createQr,
                  isSelected: section == AppSection.createQr,
                  onTap: () => _selectSection(AppSection.createQr),
                ),
                _drawerSectionItem(
                  icon: Icons.settings,
                  label: l10n.settings,
                  isSelected: section == AppSection.settings,
                  onTap: () => _selectSection(AppSection.settings),
                ),
                const Divider(),
                _drawerActionItem(
                  icon: Icons.share,
                  label: l10n.share,
                  onTap: _shareApp,
                ),
                _drawerActionItem(
                  icon: Icons.apps,
                  label: l10n.ourApps,
                  onTap: _openOurApps,
                ),
                _drawerActionItem(
                  icon: Icons.workspace_premium,
                  label: l10n.removeAds,
                  onTap: _showRemoveAdsPlaceholder,
                ),
              ],
            ),
          ),
          body: _buildSection(section),
        );
      },
    );
  }

  Widget _buildSection(AppSection section) {
    return switch (section) {
      AppSection.scan => ScanScreen(onOpenDrawer: _openDrawer),
      AppSection.favorites => HistoryScreen(
        onlyFavorites: true,
        onOpenDrawer: _openDrawer,
      ),
      AppSection.history => HistoryScreen(onOpenDrawer: _openDrawer),
      AppSection.myQr => MyQrScreen(onOpenDrawer: _openDrawer),
      AppSection.createQr => GenerateScreen(onOpenDrawer: _openDrawer),
      AppSection.settings => SettingsScreen(onOpenDrawer: _openDrawer),
    };
  }

  Widget _drawerSectionItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      selected: isSelected,
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _drawerActionItem({
    required IconData icon,
    required String label,
    required Future<void> Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  void _selectSection(AppSection section) {
    context.read<NavigationCubit>().setSection(section);
    if (section == AppSection.history || section == AppSection.favorites) {
      context.read<HistoryCubit>().load();
    }
    Navigator.of(context).pop();
  }

  Future<void> _scanFromImage() async {
    final l10n = AppLocalizations.of(context)!;
    final scanImageService = context.read<ScanImageService>();

    try {
      final rawValue = await scanImageService.pickAndScanQr();
      if (!mounted) {
        return;
      }
      if (rawValue == null || rawValue.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noQrFoundInImage)));
        return;
      }

      final parser = context.read<QrContentParser>();
      final historyRepository = context.read<HistoryRepository>();
      final historyCubit = context.read<HistoryCubit>();
      final parsed = parser.parse(rawValue);

      await historyRepository.upsert(
        HistoryItem(
          id: const Uuid().v4(),
          source: HistorySource.scanned,
          inputType: mapParsedTypeToInputType(parsed.type),
          rawValue: rawValue,
          displayValue: parsed.displayValue,
          createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      if (!mounted) {
        return;
      }
      await historyCubit.load();
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(rawValue: rawValue),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.failedReadImage)));
    }
  }

  Future<void> _shareApp() async {
    final l10n = AppLocalizations.of(context)!;
    final launcher = context.read<ActionLauncherService>();

    try {
      await launcher.shareApp(
        text: '${l10n.shareAppText} ${AppConstants.shareAppUrl}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.shareFailed}: $error')));
    }
  }

  Future<void> _openOurApps() async {
    final l10n = AppLocalizations.of(context)!;
    final launcher = context.read<ActionLauncherService>();

    try {
      await launcher.openOurApps();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.launchFailed}: $error')));
    }
  }

  Future<void> _showRemoveAdsPlaceholder() async {
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.removeAdsPlaceholder)));
  }
}
