import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner_generator/core/models/my_qr_profile.dart';
import 'package:qr_scanner_generator/core/services/my_qr_profile_repository.dart';
import 'package:qr_scanner_generator/core/services/qr_image_service.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final repo = context.read<MyQrProfileRepository>();
    final profile = await repo.read();
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _birthDateController.text = profile.birthDate;
    _phoneController.text = profile.phone;
    _emailController.text = profile.email;
    _addressController.text = profile.address;
    _companyController.text = profile.company;
    _jobTitleController.text = profile.jobTitle;
    _websiteController.text = profile.website;
    _notesController.text = profile.notes;
    if (!mounted) {
      return;
    }
    setState(() {
      _loaded = true;
    });
  }

  MyQrProfile _currentProfile() {
    return MyQrProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      birthDate: _birthDateController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      company: _companyController.text,
      jobTitle: _jobTitleController.text,
      website: _websiteController.text,
      notes: _notesController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = _currentProfile();
    final payload = profile.isEmpty ? null : profile.toVCard();

    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    l10n.myQrProfile,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _firstNameController,
              label: l10n.firstName,
            ),
            const SizedBox(height: 8),
            _buildField(controller: _lastNameController, label: l10n.lastName),
            const SizedBox(height: 8),
            _buildBirthDateField(context),
            const SizedBox(height: 8),
            _buildField(
              controller: _phoneController,
              label: l10n.phoneNumber,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            _buildField(
              controller: _emailController,
              label: l10n.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            _buildField(controller: _addressController, label: l10n.address),
            const SizedBox(height: 8),
            _buildField(controller: _companyController, label: l10n.company),
            const SizedBox(height: 8),
            _buildField(controller: _jobTitleController, label: l10n.jobTitle),
            const SizedBox(height: 8),
            _buildField(controller: _websiteController, label: l10n.website),
            const SizedBox(height: 8),
            _buildField(
              controller: _notesController,
              label: l10n.notes,
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: Text(l10n.saveProfile),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.vcardPreview,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
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
                  ? Text(l10n.profileEmpty)
                  : QrImageView(
                      data: payload,
                      size: 220,
                      version: QrVersions.auto,
                      gapless: true,
                    ),
            ),
            const SizedBox(height: 8),
            SelectableText(payload ?? ''),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: payload == null
                  ? null
                  : () => _savePng(context, payload),
              icon: const Icon(Icons.save_alt_rounded),
              label: Text(l10n.savePng),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: payload == null
                  ? null
                  : () => _sharePng(context, payload),
              icon: const Icon(Icons.share_rounded),
              label: Text(l10n.sharePng),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDateField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _birthDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: l10n.birthDate,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _pickBirthDate(context),
        ),
      ),
      onTap: () => _pickBirthDate(context),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected == null || !mounted) {
      return;
    }

    final text =
        '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';

    setState(() {
      _birthDateController.text = text;
    });
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = context.read<MyQrProfileRepository>();
    await repo.save(_currentProfile());
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
  }

  Future<void> _savePng(BuildContext context, String payload) async {
    final l10n = AppLocalizations.of(context)!;
    final fileName = 'my_qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final imageService = context.read<QrImageService>();

    try {
      final bytes = await imageService.renderPng(payload);
      await imageService.saveToGallery(bytes, fileName);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.savedPng)));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.saveFailed}: $error')));
    }
  }

  Future<void> _sharePng(BuildContext context, String payload) async {
    final l10n = AppLocalizations.of(context)!;
    final fileName = 'my_qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final imageService = context.read<QrImageService>();

    try {
      final bytes = await imageService.renderPng(payload);
      await imageService.sharePng(bytes, fileName, text: payload);
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
