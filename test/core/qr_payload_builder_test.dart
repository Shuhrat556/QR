import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/utils/qr_payload_builder.dart';

void main() {
  String? build({
    required QrInputType type,
    String text = '',
    String url = '',
    String phone = '',
    String email = '',
    String emailSubject = '',
    String emailBody = '',
    String wifiSsid = '',
    String wifiPassword = '',
    String wifiSecurity = 'WPA',
  }) {
    return QrPayloadBuilder.buildPayload(
      type: type,
      text: text,
      url: url,
      phone: phone,
      email: email,
      emailSubject: emailSubject,
      emailBody: emailBody,
      wifiSsid: wifiSsid,
      wifiPassword: wifiPassword,
      wifiSecurity: wifiSecurity,
    );
  }

  group('QrPayloadBuilder', () {
    test('builds text payload', () {
      expect(build(type: QrInputType.text, text: 'Hello'), 'Hello');
    });

    test('builds url payload', () {
      expect(build(type: QrInputType.url, url: 'https://example.com'), 'https://example.com');
    });

    test('builds tel payload', () {
      expect(build(type: QrInputType.phone, phone: '+1 202 555 1111'), 'tel:+12025551111');
    });

    test('builds mailto payload with query params', () {
      expect(
        build(
          type: QrInputType.email,
          email: 'user@example.com',
          emailSubject: 'Subject',
          emailBody: 'Body',
        ),
        'mailto:user@example.com?subject=Subject&body=Body',
      );
    });

    test('builds wifi payload', () {
      expect(
        build(
          type: QrInputType.wifi,
          wifiSsid: 'OfficeWiFi',
          wifiPassword: 'secret123',
          wifiSecurity: 'WPA',
        ),
        'WIFI:T:WPA;S:OfficeWiFi;P:secret123;;',
      );
    });
  });
}
