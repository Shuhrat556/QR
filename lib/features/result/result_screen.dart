import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/parsed_result.dart';
import 'package:qr_scanner_generator/core/services/action_launcher_service.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.rawValue});

  final String rawValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parser = context.read<QrContentParser>();
    final parsed = parser.parse(rawValue);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanResult)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Chip(label: Text(parsed.type.label)),
                    const SizedBox(height: 8),
                    Text(
                      l10n.content,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(parsed.rawValue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (parsed.primaryActionUri != null)
              FilledButton.icon(
                onPressed: () => _launchPrimaryAction(context, parsed),
                icon: const Icon(Icons.open_in_new),
                label: Text(_primaryActionLabel(l10n, parsed.type)),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _copyToClipboard(context, parsed.rawValue),
              icon: const Icon(Icons.copy),
              label: Text(l10n.copyContent),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _shareText(context, parsed.rawValue),
              icon: const Icon(Icons.share),
              label: Text(l10n.shareContent),
            ),
          ],
        ),
      ),
    );
  }

  String _primaryActionLabel(AppLocalizations l10n, ParsedContentType type) {
    return switch (type) {
      ParsedContentType.url => l10n.openLink,
      ParsedContentType.phone => l10n.callNumber,
      ParsedContentType.email => l10n.sendEmail,
      ParsedContentType.sms => l10n.sms,
      ParsedContentType.geo => l10n.open,
      ParsedContentType.calendar => l10n.open,
      ParsedContentType.contact => l10n.open,
      ParsedContentType.wifi => l10n.open,
      ParsedContentType.plainText => l10n.open,
      ParsedContentType.unknown => l10n.open,
    };
  }

  Future<void> _launchPrimaryAction(
    BuildContext context,
    ParsedResult parsed,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final launcher = context.read<ActionLauncherService>();
    try {
      await launcher.launchPrimaryAction(parsed);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.actionFailed}: $error')));
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
  }

  Future<void> _shareText(BuildContext context, String value) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await SharePlus.instance.share(ShareParams(text: value));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.shareFailed}: $error')));
    }
  }
}
