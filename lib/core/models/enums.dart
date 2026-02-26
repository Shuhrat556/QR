enum QrInputType {
  clipboard,
  text,
  url,
  contact,
  email,
  sms,
  geo,
  phone,
  calendar,
  wifi,
  myQr,
  other,
}

enum HistorySource { generated, scanned }

enum ParsedContentType {
  url,
  phone,
  email,
  sms,
  geo,
  calendar,
  contact,
  wifi,
  plainText,
  unknown,
}

enum AppSection { scan, favorites, history, myQr, createQr, settings }

extension QrInputTypeX on QrInputType {
  String get label => switch (this) {
    QrInputType.clipboard => 'Clipboard',
    QrInputType.text => 'Text',
    QrInputType.url => 'URL',
    QrInputType.contact => 'Contact',
    QrInputType.phone => 'Phone',
    QrInputType.email => 'Email',
    QrInputType.sms => 'SMS',
    QrInputType.geo => 'Geo',
    QrInputType.calendar => 'Calendar',
    QrInputType.wifi => 'WiFi',
    QrInputType.myQr => 'My QR',
    QrInputType.other => 'Other',
  };
}

extension HistorySourceX on HistorySource {
  String get label => switch (this) {
    HistorySource.generated => 'Generated',
    HistorySource.scanned => 'Scanned',
  };
}

extension ParsedContentTypeX on ParsedContentType {
  String get label => switch (this) {
    ParsedContentType.url => 'URL',
    ParsedContentType.phone => 'Phone',
    ParsedContentType.email => 'Email',
    ParsedContentType.sms => 'SMS',
    ParsedContentType.geo => 'Geo',
    ParsedContentType.calendar => 'Calendar',
    ParsedContentType.contact => 'Contact',
    ParsedContentType.wifi => 'WiFi',
    ParsedContentType.plainText => 'Text',
    ParsedContentType.unknown => 'Unknown',
  };
}
