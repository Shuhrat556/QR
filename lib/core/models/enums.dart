enum QrInputType { text, url, phone, email, wifi }

enum HistorySource { generated, scanned }

enum ParsedContentType { url, phone, email, wifi, plainText, unknown }

extension QrInputTypeX on QrInputType {
  String get label => switch (this) {
    QrInputType.text => 'Text',
    QrInputType.url => 'URL',
    QrInputType.phone => 'Phone',
    QrInputType.email => 'Email',
    QrInputType.wifi => 'WiFi',
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
    ParsedContentType.wifi => 'WiFi',
    ParsedContentType.plainText => 'Text',
    ParsedContentType.unknown => 'Unknown',
  };
}
