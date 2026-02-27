import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/core/services/my_qr_profile_repository.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';
import 'package:qr_scanner_generator/core/services/qr_image_service.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_cubit.dart';
import 'package:qr_scanner_generator/features/generate/cubit/generate_state.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:uuid/uuid.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  static const List<String> _wifiSecurityOptions = <String>[
    'WPA',
    'WEP',
    'NONE',
  ];
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _embeddedLogoBytes;
  String? _embeddedLogoName;

  @override
  void initState() {
    super.initState();
    _loadMyQrForGenerator();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GenerateCubit, GenerateState>(
      builder: (context, state) {
        final payload = state.qrPayload;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (widget.onOpenDrawer != null)
                      IconButton(
                        onPressed: widget.onOpenDrawer,
                        icon: const Icon(Icons.menu),
                        tooltip: l10n.menu,
                      ),
                    Expanded(
                      child: Text(
                        l10n.createQr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<QrInputType>(
                  initialValue: state.selectedType,
                  decoration: InputDecoration(
                    labelText: l10n.qrContentType,
                    border: const OutlineInputBorder(),
                  ),
                  items: QrInputType.values
                      .map(
                        (type) => DropdownMenuItem<QrInputType>(
                          value: type,
                          child: Text(_inputTypeLabel(l10n, type)),
                        ),
                      )
                      .toList(),
                  onChanged: (type) {
                    if (type != null) {
                      context.read<GenerateCubit>().setType(type);
                      if (type == QrInputType.myQr) {
                        _loadMyQrForGenerator();
                      }
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
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: payload == null
                      ? Text(l10n.fillRequired)
                      : QrImageView(
                          data: payload,
                          size: 220,
                          version: QrVersions.auto,
                          gapless: true,
                          embeddedImage: _embeddedLogoBytes == null
                              ? null
                              : MemoryImage(_embeddedLogoBytes!),
                          embeddedImageStyle: const QrEmbeddedImageStyle(
                            size: Size(42, 42),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Graphic QR (logo/image in center)',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickEmbeddedLogo,
                                icon: const Icon(Icons.image_outlined),
                                label: const Text('Pick logo/image'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: _embeddedLogoBytes == null
                                  ? null
                                  : _clearEmbeddedLogo,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remove'),
                            ),
                          ],
                        ),
                        if (_embeddedLogoName != null) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            _embeddedLogoName!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  payload ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: state.isValid
                      ? () => _savePng(context, state)
                      : null,
                  icon: const Icon(Icons.save_alt_rounded),
                  label: Text(l10n.savePng),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: state.isValid
                      ? () => _sharePng(context, state)
                      : null,
                  icon: const Icon(Icons.share_rounded),
                  label: Text(l10n.sharePng),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: state.isValid
                      ? () => _saveToHistory(context, state)
                      : null,
                  icon: const Icon(Icons.history),
                  label: Text(l10n.saveToHistory),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFormFields(BuildContext context, GenerateState state) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<GenerateCubit>();

    switch (state.selectedType) {
      case QrInputType.clipboard:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('clipboard_field'),
            initialValue: state.clipboardContent,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.clipboardData,
              border: const OutlineInputBorder(),
            ),
            onChanged: cubit.setClipboardContent,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pasteFromClipboard,
            icon: const Icon(Icons.content_paste),
            label: Text(l10n.pasteFromClipboard),
          ),
        ];
      case QrInputType.text:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('text_field'),
            initialValue: state.text,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.text,
              hintText: l10n.enterText,
              border: const OutlineInputBorder(),
            ),
            onChanged: cubit.setText,
          ),
        ];
      case QrInputType.url:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('url_field'),
            initialValue: state.url,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: l10n.url,
              hintText: l10n.urlHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: cubit.setUrl,
          ),
        ];
      case QrInputType.contact:
        return <Widget>[
          _field(
            l10n.firstName,
            state.contactFirstName,
            cubit.setContactFirstName,
          ),
          const SizedBox(height: 8),
          _field(
            l10n.lastName,
            state.contactLastName,
            cubit.setContactLastName,
          ),
          const SizedBox(height: 8),
          _field(l10n.phone, state.contactPhone, cubit.setContactPhone),
          const SizedBox(height: 8),
          _field(l10n.email, state.contactEmail, cubit.setContactEmail),
          const SizedBox(height: 8),
          _field(l10n.address, state.contactAddress, cubit.setContactAddress),
          const SizedBox(height: 8),
          _field(l10n.company, state.contactCompany, cubit.setContactCompany),
          const SizedBox(height: 8),
          _field(
            l10n.jobTitle,
            state.contactJobTitle,
            cubit.setContactJobTitle,
          ),
          const SizedBox(height: 8),
          _field(l10n.website, state.contactWebsite, cubit.setContactWebsite),
          const SizedBox(height: 8),
          _field(
            l10n.birthDate,
            state.contactBirthDate,
            cubit.setContactBirthDate,
          ),
          const SizedBox(height: 8),
          _field(
            l10n.notes,
            state.contactNotes,
            cubit.setContactNotes,
            minLines: 2,
            maxLines: 4,
          ),
        ];
      case QrInputType.email:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('email_field'),
            initialValue: state.email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: l10n.emailHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: cubit.setEmail,
          ),
          const SizedBox(height: 8),
          _field(
            l10n.subjectOptional,
            state.emailSubject,
            cubit.setEmailSubject,
          ),
          const SizedBox(height: 8),
          _field(
            l10n.bodyOptional,
            state.emailBody,
            cubit.setEmailBody,
            minLines: 2,
            maxLines: 3,
          ),
        ];
      case QrInputType.sms:
        return <Widget>[
          _field(l10n.phone, state.smsNumber, cubit.setSmsNumber),
          const SizedBox(height: 8),
          _field(
            l10n.smsMessage,
            state.smsMessage,
            cubit.setSmsMessage,
            minLines: 2,
            maxLines: 3,
          ),
        ];
      case QrInputType.geo:
        return <Widget>[
          _field(l10n.latitude, state.geoLat, cubit.setGeoLat),
          const SizedBox(height: 8),
          _field(l10n.longitude, state.geoLng, cubit.setGeoLng),
          const SizedBox(height: 8),
          _field(l10n.geoQuery, state.geoQuery, cubit.setGeoQuery),
        ];
      case QrInputType.phone:
        return <Widget>[
          TextFormField(
            key: const ValueKey<String>('phone_field'),
            initialValue: state.phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.phone,
              hintText: l10n.phoneHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: cubit.setPhone,
          ),
        ];
      case QrInputType.calendar:
        return <Widget>[
          _field(
            l10n.calendarTitle,
            state.calendarTitle,
            cubit.setCalendarTitle,
          ),
          const SizedBox(height: 8),
          _field(
            l10n.calendarStart,
            state.calendarStart,
            cubit.setCalendarStart,
          ),
          const SizedBox(height: 8),
          _field(l10n.calendarEnd, state.calendarEnd, cubit.setCalendarEnd),
          const SizedBox(height: 8),
          _field(
            l10n.calendarLocation,
            state.calendarLocation,
            cubit.setCalendarLocation,
          ),
          const SizedBox(height: 8),
          _field(
            l10n.calendarDescription,
            state.calendarDescription,
            cubit.setCalendarDescription,
            minLines: 2,
            maxLines: 3,
          ),
        ];
      case QrInputType.wifi:
        return <Widget>[
          _field(l10n.wifiSsid, state.wifiSsid, cubit.setWifiSsid),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey<String>('wifi_password_field'),
            initialValue: state.wifiPassword,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.wifiPassword,
              border: const OutlineInputBorder(),
            ),
            onChanged: cubit.setWifiPassword,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: const ValueKey<String>('wifi_security_field'),
            initialValue: state.wifiSecurity,
            decoration: InputDecoration(
              labelText: l10n.wifiSecurity,
              border: const OutlineInputBorder(),
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
                cubit.setWifiSecurity(value);
              }
            },
          ),
        ];
      case QrInputType.myQr:
        return <Widget>[
          _field(
            l10n.vcardPreview,
            state.myQrVCard,
            cubit.setMyQrVCard,
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loadMyQrForGenerator,
            icon: const Icon(Icons.sync),
            label: Text(l10n.refresh),
          ),
        ];
      case QrInputType.other:
        return <Widget>[
          _field(
            l10n.rawContent,
            state.otherRaw,
            cubit.setOtherRaw,
            minLines: 3,
            maxLines: 6,
          ),
        ];
    }
  }

  Widget _field(
    String label,
    String initialValue,
    ValueChanged<String> onChanged, {
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  String _inputTypeLabel(AppLocalizations l10n, QrInputType type) {
    return switch (type) {
      QrInputType.clipboard => l10n.fromClipboard,
      QrInputType.text => l10n.text,
      QrInputType.url => l10n.url,
      QrInputType.contact => l10n.contact,
      QrInputType.email => l10n.email,
      QrInputType.sms => l10n.sms,
      QrInputType.geo => l10n.geo,
      QrInputType.phone => l10n.phone,
      QrInputType.calendar => l10n.calendar,
      QrInputType.wifi => l10n.wifi,
      QrInputType.myQr => l10n.myQrType,
      QrInputType.other => l10n.other,
    };
  }

  Future<void> _pasteFromClipboard() async {
    final l10n = AppLocalizations.of(context)!;
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim() ?? '';
    if (!mounted) {
      return;
    }

    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.clipboardEmpty)));
      return;
    }

    context.read<GenerateCubit>().setClipboardContent(text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.clipboardLoaded)));
  }

  Future<void> _loadMyQrForGenerator() async {
    final repo = context.read<MyQrProfileRepository>();
    final profile = await repo.read();
    if (!mounted) {
      return;
    }
    context.read<GenerateCubit>().setMyQrVCard(profile.toVCard());
  }

  Future<void> _pickEmbeddedLogo() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _embeddedLogoBytes = bytes;
      _embeddedLogoName = file.name;
    });
  }

  void _clearEmbeddedLogo() {
    setState(() {
      _embeddedLogoBytes = null;
      _embeddedLogoName = null;
    });
  }

  Future<void> _savePng(BuildContext context, GenerateState state) async {
    final l10n = AppLocalizations.of(context)!;
    final payload = state.qrPayload;
    if (payload == null) {
      return;
    }

    final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final imageService = context.read<QrImageService>();

    try {
      final bytes = await imageService.renderPng(
        payload,
        embeddedImageBytes: _embeddedLogoBytes,
      );
      await imageService.saveToGallery(bytes, fileName);
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, l10n.savedPng);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, '${l10n.saveFailed}: $error');
    }
  }

  Future<void> _sharePng(BuildContext context, GenerateState state) async {
    final l10n = AppLocalizations.of(context)!;
    final payload = state.qrPayload;
    if (payload == null) {
      return;
    }

    final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final imageService = context.read<QrImageService>();

    try {
      final bytes = await imageService.renderPng(
        payload,
        embeddedImageBytes: _embeddedLogoBytes,
      );
      await imageService.sharePng(bytes, fileName, text: payload);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, '${l10n.shareFailed}: $error');
    }
  }

  Future<void> _saveToHistory(BuildContext context, GenerateState state) async {
    final l10n = AppLocalizations.of(context)!;
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
      _showSnackBar(context, l10n.savedToHistory);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, '${l10n.historySaveFailed}: $error');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
