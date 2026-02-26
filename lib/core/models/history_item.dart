import 'package:equatable/equatable.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';

class HistoryItem extends Equatable {
  const HistoryItem({
    required this.id,
    required this.source,
    required this.inputType,
    required this.rawValue,
    required this.displayValue,
    required this.createdAtEpochMs,
    this.isFavorite = false,
  });

  final String id;
  final HistorySource source;
  final QrInputType inputType;
  final String rawValue;
  final String displayValue;
  final int createdAtEpochMs;
  final bool isFavorite;

  HistoryItem copyWith({
    String? id,
    HistorySource? source,
    QrInputType? inputType,
    String? rawValue,
    String? displayValue,
    int? createdAtEpochMs,
    bool? isFavorite,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      source: source ?? this.source,
      inputType: inputType ?? this.inputType,
      rawValue: rawValue ?? this.rawValue,
      displayValue: displayValue ?? this.displayValue,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'source': source.name,
      'inputType': inputType.name,
      'rawValue': rawValue,
      'displayValue': displayValue,
      'createdAtEpochMs': createdAtEpochMs,
      'isFavorite': isFavorite,
    };
  }

  factory HistoryItem.fromMap(Map<dynamic, dynamic> map) {
    final sourceName = map['source'] as String?;
    final inputTypeName = map['inputType'] as String?;

    return HistoryItem(
      id: map['id'] as String? ?? '',
      source: HistorySource.values.firstWhere(
        (value) => value.name == sourceName,
        orElse: () => HistorySource.generated,
      ),
      inputType: QrInputType.values.firstWhere(
        (value) => value.name == inputTypeName,
        orElse: () => QrInputType.text,
      ),
      rawValue: map['rawValue'] as String? ?? '',
      displayValue: map['displayValue'] as String? ?? '',
      createdAtEpochMs: (map['createdAtEpochMs'] as num?)?.toInt() ?? 0,
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    source,
    inputType,
    rawValue,
    displayValue,
    createdAtEpochMs,
    isFavorite,
  ];
}
