import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/notifikasi_repository.dart';
import 'notifikasi_event.dart';
import 'notifikasi_state.dart';

class NotifikasiBloc extends Bloc<NotifikasiEvent, NotifikasiState> {
  final NotifikasiRepository _repository;

  NotifikasiBloc({required this._repository})
      : super(const NotifikasiInitial()) {
    on<LoadNotifikasiRequested>(_onLoadRequested);
    on<LoadMoreNotifikasiRequested>(_onLoadMoreRequested);
    on<MarkNotifikasiReadRequested>(_onMarkReadRequested);
    on<MarkAllNotifikasiReadRequested>(_onMarkAllReadRequested);
  }

  Future<void> _onLoadRequested(
      LoadNotifikasiRequested event,
      Emitter<NotifikasiState> emit,
      ) async {
    emit(
      NotifikasiLoading(
        selectedKategori: event.kategori,
        unreadOnly: event.unreadOnly,
      ),
    );

    try {
      final result = await _repository.getNotifications(
        kategori: event.kategori,
        unreadOnly: event.unreadOnly,
      );

      emit(
        NotifikasiLoaded(
          items: result.items,
          nextCursor: result.nextCursor,
          selectedKategori: event.kategori,
          unreadOnly: event.unreadOnly,
        ),
      );
    } catch (e) {
      emit(
        NotifikasiError(
          message: _extractErrorMessage(e),
          selectedKategori: event.kategori,
          unreadOnly: event.unreadOnly,
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
      LoadMoreNotifikasiRequested event,
      Emitter<NotifikasiState> emit,
      ) async {
    final currentState = state;
    if (currentState is! NotifikasiLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true, actionMessage: () => null));

    try {
      final result = await _repository.getNotifications(
        kategori: currentState.selectedKategori,
        unreadOnly: currentState.unreadOnly,
        cursor: currentState.nextCursor,
      );

      emit(
        currentState.copyWith(
          items: [...currentState.items, ...result.items],
          nextCursor: () => result.nextCursor,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          actionMessage: () => _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onMarkReadRequested(
      MarkNotifikasiReadRequested event,
      Emitter<NotifikasiState> emit,
      ) async {
    final currentState = state;
    if (currentState is! NotifikasiLoaded) return;

    final targetIndex = currentState.items.indexWhere((e) => e.id == event.id);
    if (targetIndex == -1 || !currentState.items[targetIndex].isUnread) {
      return;
    }

    final previousItems = currentState.items;
    final updatedItems = List.of(previousItems);
    updatedItems[targetIndex] = updatedItems[targetIndex].copyWith(
      dibaca: true,
      dibacaPada: DateTime.now(),
    );

    emit(
      currentState.copyWith(
        items: updatedItems,
        actionMessage: () => null,
      ),
    );

    try {
      await _repository.markAsRead(event.id);
    } catch (e) {
      emit(
        currentState.copyWith(
          items: previousItems,
          actionMessage: () => _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onMarkAllReadRequested(
      MarkAllNotifikasiReadRequested event,
      Emitter<NotifikasiState> emit,
      ) async {
    final currentState = state;
    if (currentState is! NotifikasiLoaded ||
        currentState.unreadCount == 0 ||
        currentState.isMarkingAll) {
      return;
    }

    final previousItems = currentState.items;
    final now = DateTime.now();
    final updatedItems = previousItems
        .map(
          (item) => item.isUnread
          ? item.copyWith(dibaca: true, dibacaPada: now)
          : item,
    )
        .toList();

    emit(
      currentState.copyWith(
        items: updatedItems,
        isMarkingAll: true,
        actionMessage: () => null,
      ),
    );

    try {
      await _repository.markAllAsRead();
      emit(
        currentState.copyWith(
          isMarkingAll: false,
          actionMessage: () => 'Semua notifikasi ditandai sudah dibaca',
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          items: previousItems,
          isMarkingAll: false,
          actionMessage: () => _extractErrorMessage(e),
        ),
      );
    }
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    return raw.startsWith('Exception: ') ? raw.substring(11) : raw;
  }
}