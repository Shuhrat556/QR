import 'package:equatable/equatable.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';

class ParsedResult extends Equatable {
  const ParsedResult({
    required this.type,
    required this.rawValue,
    required this.displayValue,
    this.primaryActionUri,
  });

  final ParsedContentType type;
  final String rawValue;
  final String displayValue;
  final Uri? primaryActionUri;

  @override
  List<Object?> get props => <Object?>[type, rawValue, displayValue, primaryActionUri];
}
