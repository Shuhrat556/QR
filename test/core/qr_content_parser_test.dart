import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/services/qr_content_parser.dart';

void main() {
  group('DefaultQrContentParser', () {
    final parser = DefaultQrContentParser();

    test('parses URL and provides action URI', () {
      final result = parser.parse('https://example.com');

      expect(result.type, ParsedContentType.url);
      expect(result.primaryActionUri, Uri.parse('https://example.com'));
    });

    test('parses phone numbers and creates tel URI', () {
      final result = parser.parse('+1 202 555 0000');

      expect(result.type, ParsedContentType.phone);
      expect(result.primaryActionUri, Uri.parse('tel:+12025550000'));
    });

    test('parses email strings and creates mailto URI', () {
      final result = parser.parse('user@example.com');

      expect(result.type, ParsedContentType.email);
      expect(result.primaryActionUri, Uri.parse('mailto:user@example.com'));
    });

    test('parses wifi payload and keeps manual actions only', () {
      final result = parser.parse('WIFI:T:WPA;S:Office WiFi;P:secret123;;');

      expect(result.type, ParsedContentType.wifi);
      expect(result.primaryActionUri, isNull);
      expect(result.displayValue, contains('Office WiFi'));
    });

    test('falls back to plain text', () {
      final result = parser.parse('hello world');

      expect(result.type, ParsedContentType.plainText);
      expect(result.primaryActionUri, isNull);
    });
  });
}
