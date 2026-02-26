import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final parser = context.read<QrContentParser>();
    final parsed = parser.parse(rawValue);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
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
                    const Text('Content', style: TextStyle(fontWeight: FontWeight.bold)),
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
                label: Text(_primaryActionLabel(parsed.type)),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _copyToClipboard(context, parsed.rawValue),
              icon: const Icon(Icons.copy),
              label: const Text('Copy Content'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _shareText(context, parsed.rawValue),
              icon: const Icon(Icons.share),
              label: const Text('Share Content'),
            ),
          ],
        ),
      ),
    );
  }

  String _primaryActionLabel(ParsedContentType type) {
    return switch (type) {
      ParsedContentType.url => 'Open Link',
      ParsedContentType.phone => 'Call Number',
      ParsedContentType.email => 'Send Email',
      ParsedContentType.wifi => 'Open',
      ParsedContentType.plainText => 'Open',
      ParsedContentType.unknown => 'Open',
    };
  }

  Future<void> _launchPrimaryAction(BuildContext context, ParsedResult parsed) async {
    final launcher = context.read<ActionLauncherService>();
    try {
      await launcher.launchPrimaryAction(parsed);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $error')),
      );
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard.')),
    );
  }

  Future<void> _shareText(BuildContext context, String value) async {
    try {
      await SharePlus.instance.share(ShareParams(text: value));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $error')),
      );
    }
  }
}
