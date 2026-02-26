import 'dart:core';

import 'package:qr_scanner_generator/core/models/enums.dart';

class QrPayloadBuilder {
  const QrPayloadBuilder._();

  static String? buildPayload({
    required QrInputType type,
    required String text,
    required String url,
    required String phone,
    required String email,
    required String emailSubject,
    required String emailBody,
    required String wifiSsid,
    required String wifiPassword,
    required String wifiSecurity,
  }) {
    return switch (type) {
      QrInputType.text => _buildText(text),
      QrInputType.url => _buildUrl(url),
      QrInputType.phone => _buildPhone(phone),
      QrInputType.email => _buildEmail(email, emailSubject, emailBody),
      QrInputType.wifi => _buildWifi(wifiSsid, wifiPassword, wifiSecurity),
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
}
