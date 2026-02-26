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
