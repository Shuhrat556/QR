import 'package:qr_scanner_generator/core/models/enums.dart';

QrInputType mapParsedTypeToInputType(ParsedContentType type) {
  return switch (type) {
    ParsedContentType.url => QrInputType.url,
    ParsedContentType.phone => QrInputType.phone,
    ParsedContentType.email => QrInputType.email,
    ParsedContentType.sms => QrInputType.sms,
    ParsedContentType.geo => QrInputType.geo,
    ParsedContentType.calendar => QrInputType.calendar,
    ParsedContentType.contact => QrInputType.contact,
    ParsedContentType.wifi => QrInputType.wifi,
    ParsedContentType.plainText ||
    ParsedContentType.unknown => QrInputType.text,
  };
}
