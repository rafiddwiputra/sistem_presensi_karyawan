import '../../data/models/notifikasi_model.dart';

abstract class NotifikasiState {
  const NotifikasiState();
}

class NotifikasiInitial extends NotifikasiState {
  const NotifikasiInitial();
}

class NotifikasiLoading extends NotifikasiState {
  final String? selectedKategori;
  final bool unreadOnly;

  const NotifikasiLoading({
    this.selectedKategori,
    this.unreadOnly = false,
  });
}

class NotifikasiLoaded extends NotifikasiState {
  final List<NotifikasiModel> items;
  final String? nextCursor;
  final String? selectedKategori;
  final bool unreadOnly;
  final bool isLoadingMore;
  final bool isMarkingAll;
  final String? actionMessage;

  const NotifikasiLoaded({
    required this.items,
    this.nextCursor,
    this.selectedKategori,
    this.unreadOnly = false,
    this.isLoadingMore = false,
    this.isMarkingAll = false,
    this.actionMessage,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  int get unreadCount => items.where((item) => item.isUnread).length;

  List<NotifikasiModel> get todayItems =>
      items.where((item) => item.isToday).toList();

  List<NotifikasiModel> get earlierItems =>
      items.where((item) => !item.isToday).toList();

  NotifikasiLoaded copyWith({
    List<NotifikasiModel>? items,
    String? Function()? nextCursor,
    String? Function()? selectedKategori,
    bool? unreadOnly,
    bool? isLoadingMore,
    bool? isMarkingAll,
    String? Function()? actionMessage,
  }) {
    return NotifikasiLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
      selectedKategori:
      selectedKategori != null ? selectedKategori() : this.selectedKategori,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMarkingAll: isMarkingAll ?? this.isMarkingAll,
      actionMessage:
      actionMessage != null ? actionMessage() : this.actionMessage,
    );
  }
}

class NotifikasiError extends NotifikasiState {
  final String message;
  final String? selectedKategori;
  final bool unreadOnly;

  const NotifikasiError({
    required this.message,
    this.selectedKategori,
    this.unreadOnly = false,
  });
}