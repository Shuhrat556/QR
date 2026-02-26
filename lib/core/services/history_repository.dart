import 'package:qr_scanner_generator/core/models/history_item.dart';

abstract class HistoryRepository {
  Future<void> init();

  Future<List<HistoryItem>> fetchAll();

  Future<void> upsert(HistoryItem item);

  Future<void> setFavorite(String id, bool isFavorite);

  Future<void> deleteById(String id);

  Future<void> clearAll();
}
