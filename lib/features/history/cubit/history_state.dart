import 'package:equatable/equatable.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const <HistoryItem>[],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<HistoryItem> items;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, items, errorMessage];
}
