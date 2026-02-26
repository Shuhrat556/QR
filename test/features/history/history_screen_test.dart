import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/history/history_screen.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository(List<HistoryItem> initialItems)
    : _items = List<HistoryItem>.from(initialItems);

  final List<HistoryItem> _items;

  @override
  Future<void> clearAll() async {
    _items.clear();
  }

  @override
  Future<void> deleteById(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<HistoryItem>> fetchAll() async {
    _items.sort((a, b) => b.createdAtEpochMs.compareTo(a.createdAtEpochMs));
    return List<HistoryItem>.from(_items);
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> upsert(HistoryItem item) async {
    _items.removeWhere((entry) => entry.id == item.id);
    _items.add(item);
  }

  @override
  Future<void> setFavorite(String id, bool isFavorite) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    _items[index] = _items[index].copyWith(isFavorite: isFavorite);
  }
}

void main() {
  testWidgets('renders history and clears all items via confirmation', (
    tester,
  ) async {
    final repository = _FakeHistoryRepository(<HistoryItem>[
      const HistoryItem(
        id: '1',
        source: HistorySource.generated,
        inputType: QrInputType.text,
        rawValue: 'hello',
        displayValue: 'hello',
        createdAtEpochMs: 100,
      ),
      const HistoryItem(
        id: '2',
        source: HistorySource.scanned,
        inputType: QrInputType.url,
        rawValue: 'https://example.com',
        displayValue: 'example.com',
        createdAtEpochMs: 200,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<HistoryCubit>(
          create: (_) => HistoryCubit(repository: repository),
          child: const Scaffold(body: HistoryScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('example.com'), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pumpAndSettle();

    expect(find.text('No history yet.'), findsOneWidget);
  });
}
