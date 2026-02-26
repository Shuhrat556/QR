import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/data/history/hive_history_repository.dart';

void main() {
  late Directory tempDir;
  late HiveHistoryRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qr_tools_hive_test_');
    repository = HiveHistoryRepository(
      initializer: () async {
        Hive.init(tempDir.path);
      },
      boxOpener: (boxName) => Hive.openBox<dynamic>(boxName),
    );
    await repository.init();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('upsert, fetch, delete and clear operations work with descending order', () async {
    final older = HistoryItem(
      id: '1',
      source: HistorySource.generated,
      inputType: QrInputType.url,
      rawValue: 'https://old.example',
      displayValue: 'old',
      createdAtEpochMs: 100,
    );
    final newer = HistoryItem(
      id: '2',
      source: HistorySource.scanned,
      inputType: QrInputType.text,
      rawValue: 'new',
      displayValue: 'new',
      createdAtEpochMs: 200,
    );

    await repository.upsert(older);
    await repository.upsert(newer);

    final items = await repository.fetchAll();
    expect(items.map((item) => item.id).toList(), <String>['2', '1']);

    await repository.deleteById('2');
    final afterDelete = await repository.fetchAll();
    expect(afterDelete.map((item) => item.id).toList(), <String>['1']);

    await repository.clearAll();
    final afterClear = await repository.fetchAll();
    expect(afterClear, isEmpty);
  });
}
