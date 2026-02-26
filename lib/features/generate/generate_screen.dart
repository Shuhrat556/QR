import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/core/services/qr_image_service.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_cubit.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_state.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:uuid/uuid.dart';

class GenerateScreen extends StatelessWidget {
  const GenerateScreen({super.key});

  static const List<String> _wifiSecurityOptions = <String>['WPA', 'WEP', 'NONE'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenerateCubit, GenerateState>(
      builder: (context, state) {
        final payload = state.qrPayload;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<QrInputType>(
                initialValue: state.selectedType,
                decoration: const InputDecoration(
                  labelText: 'QR Content Type',
                  border: OutlineInputBorder(),
                ),
                items: QrInputType.values
                    .map(
                      (type) => DropdownMenuItem<QrInputType>(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type != null) {
                    context.read<GenerateCubit>().setType(type);
                  }
                },
              ),
              const SizedBox(height: 16),
              ..._buildFormFields(context, state),
              const SizedBox(height: 20),
              Container(
                height: 260,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: payload == null
                    ? const Text('Fill required fields for live preview')
                    : QrImageView(
                        data: payload,
                        size: 220,
                        version: QrVersions.auto,
                        gapless: true,
                      ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                payload ?? 'No payload yet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: state.isValid ? () => _savePng(context, state) : null,
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('Save PNG'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: state.isValid ? () => _sharePng(context, state) : null,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share PNG'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: state.isValid ? () => _saveToHistory(context, state) : null,
                icon: const Icon(Icons.history),
                label: const Text('Save to History'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFormFields(BuildContext context, GenerateState state) {
    switch (state.selectedType) {
      case QrInputType.text:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('text_field'),
            initialValue: state.text,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Text',
              hintText: 'Enter text',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setText,
          ),
        ];
      case QrInputType.url:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('url_field'),
            initialValue: state.url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://example.com',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setUrl,
          ),
        ];
      case QrInputType.phone:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('phone_field'),
            initialValue: state.phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+123456789',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setPhone,
          ),
        ];
      case QrInputType.email:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('email_field'),
            initialValue: state.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'user@example.com',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setEmail,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey<String>('email_subject_field'),
            initialValue: state.emailSubject,
            decoration: const InputDecoration(
              labelText: 'Subject (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setEmailSubject,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey<String>('email_body_field'),
            initialValue: state.emailBody,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Body (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setEmailBody,
          ),
        ];
      case QrInputType.wifi:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('wifi_ssid_field'),
            initialValue: state.wifiSsid,
            decoration: const InputDecoration(
              labelText: 'WiFi SSID',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setWifiSsid,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey<String>('wifi_password_field'),
            initialValue: state.wifiPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'WiFi Password',
              border: OutlineInputBorder(),
            ),
            onChanged: context.read<GenerateCubit>().setWifiPassword,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: const ValueKey<String>('wifi_security_field'),
            initialValue: state.wifiSecurity,
            decoration: const InputDecoration(
              labelText: 'Security',
              border: OutlineInputBorder(),
            ),
            items: _wifiSecurityOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<GenerateCubit>().setWifiSecurity(value);
              }
            },
          ),
        ];
    }
  }

  Future<void> _savePng(BuildContext context, GenerateState state) async {
    final payload = state.qrPayload;
    if (payload == null) {
      return;
    }

    final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final imageService = context.read<QrImageService>();

    try {
      final bytes = await imageService.renderPng(payload);
      await imageService.saveToGallery(bytes, fileName);
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, 'Saved PNG to gallery.');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, 'Save failed: $error');
    }
  }

  Future<void> _sharePng(BuildContext context, GenerateState state) async {
    final payload = state.qrPayload;
    if (payload == null) {
      return;
    }

    final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final imageService = context.read<QrImageService>();

    try {
      final bytes = await imageService.renderPng(payload);
      await imageService.sharePng(bytes, fileName, text: payload);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, 'Share failed: $error');
    }
  }

  Future<void> _saveToHistory(BuildContext context, GenerateState state) async {
    final payload = state.qrPayload;
    if (payload == null) {
      return;
    }

    final historyRepository = context.read<HistoryRepository>();
    final parser = context.read<QrContentParser>();
    final parsed = parser.parse(payload);

    final item = HistoryItem(
      id: const Uuid().v4(),
      source: HistorySource.generated,
      inputType: state.selectedType,
      rawValue: payload,
      displayValue: parsed.displayValue,
      createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await historyRepository.upsert(item);
      if (!context.mounted) {
        return;
      }
      await context.read<HistoryCubit>().load();
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, 'Saved to history.');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, 'History save failed: $error');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
