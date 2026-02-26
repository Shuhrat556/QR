import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_scanner_generator/core/models/enums.dart';
import 'package:qr_scanner_generator/core/models/history_item.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_cubit.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_state.dart';
import 'package:qr_scanner_generator/features/result/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'History',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: state.items.isEmpty
                          ? null
                          : () => _confirmClearAll(context),
                      tooltip: 'Clear all history',
                      icon: const Icon(Icons.delete_sweep_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildContent(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HistoryState state) {
    if (state.status == HistoryStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HistoryStatus.failure && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Failed to load history.'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.read<HistoryCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(child: Text('No history yet.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<HistoryCubit>().load(),
      child: ListView.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = state.items[index];
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
            onDismissed: (_) => context.read<HistoryCubit>().deleteById(item.id),
            child: _HistoryTile(item: item),
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear history?'),
          content: const Text('This will remove all generated and scanned entries.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
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
    final dateText = DateFormat('yyyy-MM-dd HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(item.createdAtEpochMs),
    );

    return Card(
      child: ListTile(
        leading: Icon(item.source == HistorySource.generated ? Icons.edit : Icons.qr_code_scanner),
        title: Text(item.displayValue.isEmpty ? item.rawValue : item.displayValue),
        subtitle: Text('${item.source.label} • $dateText'),
        trailing: const Icon(Icons.chevron_right),
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
