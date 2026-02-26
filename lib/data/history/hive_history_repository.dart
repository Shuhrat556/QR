import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';

class HiveHistoryRepository implements HistoryRepository {
  HiveHistoryRepository({
    Future<void> Function()? initializer,
    Future<Box<dynamic>> Function(String boxName)? boxOpener,
  }) : _initializer = initializer ?? Hive.initFlutter,
       _boxOpener = boxOpener ?? ((boxName) => Hive.openBox<dynamic>(boxName));

  final Future<void> Function() _initializer;
  final Future<Box<dynamic>> Function(String boxName) _boxOpener;
  Box<dynamic>? _box;

  @override
  Future<void> init() async {
    await _initializer();
    _box ??= await _boxOpener(AppConstants.historyBoxName);
  }

  Box<dynamic> get _historyBox {
    final box = _box;
    if (box == null) {
      throw StateError('History repository is not initialized.');
    }
    return box;
  }

  @override
  Future<List<HistoryItem>> fetchAll() async {
    final items = _historyBox.values
        .whereType<Map>()
        .map((value) => HistoryItem.fromMap(value))
        .toList();

    items.sort((a, b) => b.createdAtEpochMs.compareTo(a.createdAtEpochMs));
    return items;
  }

  @override
  Future<void> upsert(HistoryItem item) async {
    await _historyBox.put(item.id, item.toMap());
  }

  @override
  Future<void> setFavorite(String id, bool isFavorite) async {
    final existing = _historyBox.get(id);
    if (existing is! Map) {
      return;
    }
    final item = HistoryItem.fromMap(existing).copyWith(isFavorite: isFavorite);
    await _historyBox.put(id, item.toMap());
  }

  @override
  Future<void> deleteById(String id) async {
    await _historyBox.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _historyBox.clear();
  }
}
