import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/core/services/history_repository.dart';
import 'package:qr_scanner_generator/features/history/cubit/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required HistoryRepository repository})
    : _repository = repository,
      super(const HistoryState());

  final HistoryRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: HistoryStatus.loading, clearError: true));
    try {
      final items = await _repository.fetchAll();
      emit(
        state.copyWith(
          status: HistoryStatus.success,
          items: items,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> deleteById(String id) async {
    await _repository.deleteById(id);
    await load();
  }

  Future<void> setFavorite(String id, bool isFavorite) async {
    await _repository.setFavorite(id, isFavorite);
    await load();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    await load();
  }
}
