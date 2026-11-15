class NotifikasiModel {
  final String id;
  final String kategori;
  final String tipe;
  final String judul;
  final String pesan;
  final Map<String, Object?> referensi;
  final bool dibaca;
  final DateTime? dibacaPada;
  final DateTime dibuatPada;

  const NotifikasiModel({
    required this.id,
    required this.kategori,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.referensi,
    required this.dibaca,
    this.dibacaPada,
    required this.dibuatPada,
  });

  bool get isUnread => !dibaca;

  bool get isToday {
    final now = DateTime.now();
    return dibuatPada.year == now.year &&
        dibuatPada.month == now.month &&
        dibuatPada.day == now.day;
  }

  NotifikasiModel copyWith({
    String? id,
    String? kategori,
    String? tipe,
    String? judul,
    String? pesan,
    Map<String, Object?>? referensi,
    bool? dibaca,
    DateTime? dibacaPada,
    DateTime? dibuatPada,
  }) {
    return NotifikasiModel(
      id: id ?? this.id,
      kategori: kategori ?? this.kategori,
      tipe: tipe ?? this.tipe,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      referensi: referensi ?? this.referensi,
      dibaca: dibaca ?? this.dibaca,
      dibacaPada: dibacaPada ?? this.dibacaPada,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    final rawReferensi = json['referensi'];
    final parsedReferensi = rawReferensi is Map<String, dynamic>
        ? Map<String, Object?>.from(rawReferensi)
        : <String, Object?>{};

    final rawDibaca = json['dibaca'];
    final bool isRead = rawDibaca is bool
        ? rawDibaca
        : (rawDibaca is num ? rawDibaca == 1 : false);

    return NotifikasiModel(
      id: json['id']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'umum',
      tipe: json['tipe']?.toString() ?? '',
      judul: json['judul']?.toString() ?? 'Notifikasi',
      pesan: json['pesan']?.toString() ?? '',
      referensi: parsedReferensi,
      dibaca: isRead,
      dibacaPada: json['dibaca_pada'] != null
          ? DateTime.tryParse(json['dibaca_pada'].toString())?.toLocal()
          : null,
      dibuatPada: json['dibuat_pada'] != null
          ? (DateTime.tryParse(json['dibuat_pada'].toString())?.toLocal() ??
          DateTime.now())
          : DateTime.now(),
    );
  }
}

class NotifikasiListResponse {
  final List<NotifikasiModel> items;
  final String? nextCursor;
  final int perPage;

  const NotifikasiListResponse({
    required this.items,
    this.nextCursor,
    required this.perPage,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  factory NotifikasiListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! List) {
      throw const FormatException('Format daftar notifikasi tidak sesuai.');
    }

    final items = <NotifikasiModel>[];
    for (final entry in rawData) {
      if (entry is Map<String, dynamic>) {
        items.add(NotifikasiModel.fromJson(entry));
      }
    }

    final rawMeta = json['meta'];
    final meta = rawMeta is Map<String, dynamic>
        ? rawMeta
        : const <String, dynamic>{};

    return NotifikasiListResponse(
      items: items,
      nextCursor: meta['next_cursor']?.toString(),
      perPage: (meta['per_page'] as num?)?.toInt() ?? 20,
    );
  }
}