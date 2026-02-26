import 'dart:core';

import 'package:intl/intl.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';

class QrPayloadBuilder {
  const QrPayloadBuilder._();

  static String? buildPayload({
    required QrInputType type,
    String clipboardContent = '',
    String text = '',
    String url = '',
    String phone = '',
    String email = '',
    String emailSubject = '',
    String emailBody = '',
    String wifiSsid = '',
    String wifiPassword = '',
    String wifiSecurity = '',
    String contactFirstName = '',
    String contactLastName = '',
    String contactPhone = '',
    String contactEmail = '',
    String contactAddress = '',
    String contactCompany = '',
    String contactJobTitle = '',
    String contactWebsite = '',
    String contactNotes = '',
    String contactBirthDate = '',
    String smsNumber = '',
    String smsMessage = '',
    String geoLat = '',
    String geoLng = '',
    String geoQuery = '',
    String calendarTitle = '',
    String calendarStart = '',
    String calendarEnd = '',
    String calendarLocation = '',
    String calendarDescription = '',
    String myQrVCard = '',
    String otherRaw = '',
  }) {
    return switch (type) {
      QrInputType.clipboard => _buildText(clipboardContent),
      QrInputType.text => _buildText(text),
      QrInputType.url => _buildUrl(url),
      QrInputType.contact => _buildContact(
        firstName: contactFirstName,
        lastName: contactLastName,
        phone: contactPhone,
        email: contactEmail,
        address: contactAddress,
        company: contactCompany,
        jobTitle: contactJobTitle,
        website: contactWebsite,
        notes: contactNotes,
        birthDate: contactBirthDate,
      ),
      QrInputType.email => _buildEmail(email, emailSubject, emailBody),
      QrInputType.sms => _buildSms(smsNumber, smsMessage),
      QrInputType.geo => _buildGeo(geoLat, geoLng, geoQuery),
      QrInputType.phone => _buildPhone(phone),
      QrInputType.calendar => _buildCalendar(
        title: calendarTitle,
        start: calendarStart,
        end: calendarEnd,
        location: calendarLocation,
        description: calendarDescription,
      ),
      QrInputType.wifi => _buildWifi(wifiSsid, wifiPassword, wifiSecurity),
      QrInputType.myQr => _buildText(myQrVCard),
      QrInputType.other => _buildText(otherRaw),
    };
  }

  static String? _buildText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String? _buildUrl(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String? _buildPhone(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final sanitized = normalized.replaceAll(' ', '');
    return 'tel:$sanitized';
  }

  static String? _buildEmail(String email, String subject, String body) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return null;
    }

    final queryParameters = <String, String>{};
    if (subject.trim().isNotEmpty) {
      queryParameters['subject'] = subject.trim();
    }
    if (body.trim().isNotEmpty) {
      queryParameters['body'] = body.trim();
    }

    return Uri(
      scheme: 'mailto',
      path: normalizedEmail,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String? _buildSms(String number, String message) {
    final normalizedNumber = number.trim();
    if (normalizedNumber.isEmpty) {
      return null;
    }
    final body = message.trim();
    if (body.isEmpty) {
      return 'SMSTO:$normalizedNumber';
    }
    return 'SMSTO:$normalizedNumber:$body';
  }

  static String? _buildGeo(String lat, String lng, String query) {
    final normalizedLat = lat.trim();
    final normalizedLng = lng.trim();
    if (normalizedLat.isEmpty || normalizedLng.isEmpty) {
      return null;
    }

    final label = query.trim();
    if (label.isEmpty) {
      return 'geo:$normalizedLat,$normalizedLng';
    }
    return 'geo:$normalizedLat,$normalizedLng?q=${Uri.encodeComponent(label)}';
  }

  static String? _buildCalendar({
    required String title,
    required String start,
    required String end,
    required String location,
    required String description,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      return null;
    }

    final startStamp = _parseCalendarDateTime(start.trim());
    final endStamp = _parseCalendarDateTime(end.trim());
    if (startStamp == null || endStamp == null) {
      return null;
    }

    final nowStamp = DateFormat(
      "yyyyMMdd'T'HHmmss'Z'",
    ).format(DateTime.now().toUtc());
    final event = <String>[
      'BEGIN:VEVENT',
      'SUMMARY:${_escapeVCard(normalizedTitle)}',
      'DTSTART:$startStamp',
      'DTEND:$endStamp',
      'DTSTAMP:$nowStamp',
      if (location.trim().isNotEmpty)
        'LOCATION:${_escapeVCard(location.trim())}',
      if (description.trim().isNotEmpty)
        'DESCRIPTION:${_escapeVCard(description.trim())}',
      'END:VEVENT',
    ].join('\n');

    return 'BEGIN:VCALENDAR\nVERSION:2.0\n$event\nEND:VCALENDAR';
  }

  static String? _parseCalendarDateTime(String value) {
    if (value.isEmpty) {
      return null;
    }

    final parser = DateFormat('yyyy-MM-dd HH:mm');
    try {
      final parsed = parser.parseStrict(value).toUtc();
      return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(parsed);
    } catch (_) {
      return null;
    }
  }

  static String? _buildContact({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String address,
    required String company,
    required String jobTitle,
    required String website,
    required String notes,
    required String birthDate,
  }) {
    final fn = [
      firstName.trim(),
      lastName.trim(),
    ].where((e) => e.isNotEmpty).join(' ');

    if (fn.isEmpty &&
        phone.trim().isEmpty &&
        email.trim().isEmpty &&
        address.trim().isEmpty &&
        company.trim().isEmpty &&
        jobTitle.trim().isEmpty &&
        website.trim().isEmpty &&
        notes.trim().isEmpty &&
        birthDate.trim().isEmpty) {
      return null;
    }

    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      if (fn.isNotEmpty) 'FN:${_escapeVCard(fn)}',
      'N:${_escapeVCard(lastName.trim())};${_escapeVCard(firstName.trim())};;;',
      if (company.trim().isNotEmpty) 'ORG:${_escapeVCard(company.trim())}',
      if (jobTitle.trim().isNotEmpty) 'TITLE:${_escapeVCard(jobTitle.trim())}',
      if (phone.trim().isNotEmpty)
        'TEL;TYPE=CELL:${_escapeVCard(phone.trim())}',
      if (email.trim().isNotEmpty) 'EMAIL:${_escapeVCard(email.trim())}',
      if (address.trim().isNotEmpty)
        'ADR:;;${_escapeVCard(address.trim())};;;;',
      if (website.trim().isNotEmpty) 'URL:${_escapeVCard(website.trim())}',
      if (birthDate.trim().isNotEmpty) 'BDAY:${_escapeVCard(birthDate.trim())}',
      if (notes.trim().isNotEmpty) 'NOTE:${_escapeVCard(notes.trim())}',
      'END:VCARD',
    ];

    return lines.join('\n');
  }

  static String? _buildWifi(String ssid, String password, String security) {
    final normalizedSsid = ssid.trim();
    final normalizedPassword = password.trim();
    final normalizedSecurity = security.trim().toUpperCase();

    if (normalizedSsid.isEmpty) {
      return null;
    }

    if (normalizedSecurity != 'NONE' && normalizedPassword.isEmpty) {
      return null;
    }

    final escapedSsid = _escapeWifiValue(normalizedSsid);
    final escapedPassword = _escapeWifiValue(normalizedPassword);

    return 'WIFI:T:$normalizedSecurity;S:$escapedSsid;P:$escapedPassword;;';
  }

  static String _escapeWifiValue(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll(':', r'\:')
        .replaceAll('"', r'\"');
  }

  static String _escapeVCard(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('\n', r'\n');
  }
}
