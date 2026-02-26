import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/parsed_result.dart';

abstract class QrContentParser {
  ParsedResult parse(String rawValue);
}

class DefaultQrContentParser implements QrContentParser {
  DefaultQrContentParser();

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9()\-\s]{5,}$');
  static final RegExp _wifiSsidRegex = RegExp(r'S:([^;]*)');
  static final RegExp _smsRegex = RegExp(r'^smsto:(.*)$', caseSensitive: false);
  static final RegExp _geoRegex = RegExp(
    r'^geo:([-0-9.]+),([-0-9.]+)(\?.*)?$',
    caseSensitive: false,
  );

  @override
  ParsedResult parse(String rawValue) {
    final value = rawValue.trim();

    if (value.isEmpty) {
      return const ParsedResult(
        type: ParsedContentType.unknown,
        rawValue: '',
        displayValue: 'No content',
      );
    }

    if (value.toUpperCase().startsWith('WIFI:')) {
      final ssidMatch = _wifiSsidRegex.firstMatch(value);
      final ssid = _unescapeWifiValue(ssidMatch?.group(1) ?? '');
      final display = ssid.isEmpty ? value : 'WiFi: $ssid';
      return ParsedResult(
        type: ParsedContentType.wifi,
        rawValue: value,
        displayValue: display,
      );
    }

    if (value.toUpperCase().startsWith('BEGIN:VCARD')) {
      final display = _extractVcardName(value) ?? value;
      return ParsedResult(
        type: ParsedContentType.contact,
        rawValue: value,
        displayValue: display,
      );
    }

    if (value.toUpperCase().startsWith('BEGIN:VEVENT')) {
      final title = _extractVeventTitle(value) ?? value;
      return ParsedResult(
        type: ParsedContentType.calendar,
        rawValue: value,
        displayValue: title,
      );
    }

    final smsMatch = _smsRegex.firstMatch(value);
    if (smsMatch != null) {
      final payload = smsMatch.group(1) ?? '';
      final parts = payload.split(':');
      final number = parts.firstOrNull?.trim() ?? '';
      final message = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      final smsUri = Uri.parse(
        'sms:$number${message.isEmpty ? '' : '?body=${Uri.encodeComponent(message)}'}',
      );
      return ParsedResult(
        type: ParsedContentType.sms,
        rawValue: value,
        displayValue: number.isEmpty ? value : number,
        primaryActionUri: smsUri,
      );
    }

    final geoMatch = _geoRegex.firstMatch(value);
    if (geoMatch != null) {
      return ParsedResult(
        type: ParsedContentType.geo,
        rawValue: value,
        displayValue: '${geoMatch.group(1)}, ${geoMatch.group(2)}',
        primaryActionUri: Uri.tryParse(value),
      );
    }

    if (value.toLowerCase().startsWith('mailto:')) {
      final uri = Uri.tryParse(value);
      final email = uri?.path ?? value.replaceFirst(RegExp('^mailto:'), '');
      return ParsedResult(
        type: ParsedContentType.email,
        rawValue: value,
        displayValue: email,
        primaryActionUri: uri,
      );
    }

    if (_emailRegex.hasMatch(value)) {
      final uri = Uri(scheme: 'mailto', path: value);
      return ParsedResult(
        type: ParsedContentType.email,
        rawValue: value,
        displayValue: value,
        primaryActionUri: uri,
      );
    }

    if (value.toLowerCase().startsWith('tel:')) {
      final uri = Uri.tryParse(value);
      final number = value.substring(4);
      return ParsedResult(
        type: ParsedContentType.phone,
        rawValue: value,
        displayValue: number,
        primaryActionUri: uri,
      );
    }

    if (_phoneRegex.hasMatch(value)) {
      final uri = Uri(scheme: 'tel', path: value.replaceAll(' ', ''));
      return ParsedResult(
        type: ParsedContentType.phone,
        rawValue: value,
        displayValue: value,
        primaryActionUri: uri,
      );
    }

    if (_looksLikeUrl(value)) {
      final uri = _normalizeUrl(value);
      return ParsedResult(
        type: ParsedContentType.url,
        rawValue: value,
        displayValue: value,
        primaryActionUri: uri,
      );
    }

    return ParsedResult(
      type: ParsedContentType.plainText,
      rawValue: value,
      displayValue: value,
    );
  }

  String? _extractVcardName(String value) {
    final lines = value.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (upper.startsWith('FN:')) {
        return line.substring(3).trim();
      }
    }
    return null;
  }

  String? _extractVeventTitle(String value) {
    final lines = value.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (upper.startsWith('SUMMARY:')) {
        return line.substring(8).trim();
      }
    }
    return null;
  }

  bool _looksLikeUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }

    if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return true;
    }

    return !value.contains(' ') && value.contains('.');
  }

  Uri _normalizeUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      return uri;
    }
    return Uri.parse('https://$value');
  }

  String _unescapeWifiValue(String value) {
    return value
        .replaceAll(r'\;', ';')
        .replaceAll(r'\,', ',')
        .replaceAll(r'\:', ':')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', '\\');
  }
}
