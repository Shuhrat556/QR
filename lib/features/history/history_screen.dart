import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_state.dart';
import 'package:qr_scanner_generator/features/result/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    this.onlyFavorites = false,
    this.onOpenDrawer,
  });

  final bool onlyFavorites;
  final VoidCallback? onOpenDrawer;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            final filtered = widget.onlyFavorites
                ? state.items.where((item) => item.isFavorite).toList()
                : state.items;

            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (widget.onOpenDrawer != null)
                      IconButton(
                        onPressed: widget.onOpenDrawer,
                        icon: const Icon(Icons.menu),
                        tooltip: l10n.menu,
                      ),
                    Expanded(
                      child: Text(
                        widget.onlyFavorites ? l10n.favorites : l10n.history,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!widget.onlyFavorites)
                      IconButton(
                        onPressed: filtered.isEmpty
                            ? null
                            : () => _confirmClearAll(context),
                        tooltip: l10n.clearAll,
                        icon: const Icon(Icons.delete_sweep_outlined),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildContent(context, state, filtered)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    HistoryState state,
    List<HistoryItem> items,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (state.status == HistoryStatus.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HistoryStatus.failure && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.failedLoadHistory),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.read<HistoryCubit>().load(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          widget.onlyFavorites ? l10n.noFavoritesYet : l10n.noHistoryYet,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<HistoryCubit>().load(),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Dismissible(
            key: ValueKey<String>(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) =>
                context.read<HistoryCubit>().deleteById(item.id),
            child: _HistoryTile(item: item),
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.clearHistoryTitle),
          content: Text(l10n.clearHistoryBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.clear),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !context.mounted) {
      return;
    }

    await context.read<HistoryCubit>().clearAll();
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateText = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(item.createdAtEpochMs));

    final sourceLabel = item.source == HistorySource.generated
        ? l10n.generated
        : l10n.scanned;

    return Card(
      child: ListTile(
        leading: Icon(
          item.source == HistorySource.generated
              ? Icons.edit
              : Icons.qr_code_scanner,
        ),
        title: Text(
          item.displayValue.isEmpty ? item.rawValue : item.displayValue,
        ),
        subtitle: Text('$sourceLabel • $dateText'),
        trailing: Wrap(
          spacing: 0,
          children: <Widget>[
            IconButton(
              icon: Icon(item.isFavorite ? Icons.star : Icons.star_border),
              onPressed: () {
                context.read<HistoryCubit>().setFavorite(
                  item.id,
                  !item.isFavorite,
                );
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ResultScreen(rawValue: item.rawValue),
            ),
          );
        },
      ),
    );
  }
}
