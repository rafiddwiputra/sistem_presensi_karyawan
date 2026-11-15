abstract class NotifikasiEvent {
  const NotifikasiEvent();
}

class LoadNotifikasiRequested extends NotifikasiEvent {
  final String? kategori;
  final bool unreadOnly;

  const LoadNotifikasiRequested({
    this.kategori,
    this.unreadOnly = false,
  });
}

class LoadMoreNotifikasiRequested extends NotifikasiEvent {
  const LoadMoreNotifikasiRequested();
}

class MarkNotifikasiReadRequested extends NotifikasiEvent {
  final String id;

  const MarkNotifikasiReadRequested(this.id);
}

class MarkAllNotifikasiReadRequested extends NotifikasiEvent {
  const MarkAllNotifikasiReadRequested();
}