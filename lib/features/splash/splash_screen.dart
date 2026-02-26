import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/my_qr_profile_repository.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final historyRepository = context.read<HistoryRepository>();
    final myQrRepository = context.read<MyQrProfileRepository>();
    final historyCubit = context.read<HistoryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final startedAt = DateTime.now();

    try {
      await historyRepository.init();
      await myQrRepository.init();
      await historyCubit.load();
    } catch (_) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      messenger.showSnackBar(SnackBar(content: Text(l10n.failedLoadHistory)));
    }

    final elapsed = DateTime.now().difference(startedAt);
    const splashDuration = Duration(seconds: 1);
    if (elapsed < splashDuration) {
      await Future.delayed(splashDuration - elapsed);
    }

    if (!mounted) {
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.qr_code_2_rounded, size: 88),
            SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(l10n.taglineCreateScanShare),
          ],
        ),
      ),
    );
  }
}
