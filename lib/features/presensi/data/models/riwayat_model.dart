class RiwayatSummary {
  final int hadir;
  final int lembur;
  final int izin;
  final int cuti;
  final int tidakHadir;

  const RiwayatSummary({
    required this.hadir,
    required this.lembur,
    required this.izin,
    required this.cuti,
    required this.tidakHadir,
  });

  factory RiwayatSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RiwayatSummary(hadir: 0, lembur: 0, izin: 0, cuti: 0, tidakHadir: 0);
    }
    return RiwayatSummary(
      hadir: json['hadir'] as int? ?? 0,
      lembur: json['lembur'] as int? ?? 0,
      izin: json['izin'] as int? ?? 0,
      cuti: json['cuti'] as int? ?? 0,
      tidakHadir: json['tidak_hadir'] as int? ?? 0,
    );
  }
}

class RiwayatItem {
  final DateTime tanggal;
  final String status;
  final bool isLembur;
  final String waktuMasuk;
  final String waktuKeluar;

  const RiwayatItem({
    required this.tanggal,
    required this.status,
    required this.isLembur,
    required this.waktuMasuk,
    required this.waktuKeluar,
  });

  factory RiwayatItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['tanggal'] as String? ?? DateTime.now().toIso8601String());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return RiwayatItem(
      tanggal: parsedDate,
      status: json['status'] as String? ?? '-',
      isLembur: json['is_lembur'] as bool? ?? false,
      waktuMasuk: json['waktu_masuk'] as String? ?? '--:--',
      waktuKeluar: json['waktu_keluar'] as String? ?? '--:--',
    );
  }

  String get subtitle => isLembur ? 'Lembur' : '';
}

class RiwayatResponse {
  final RiwayatSummary summary;
  final List<RiwayatItem> riwayatList;

  const RiwayatResponse({
    required this.summary,
    required this.riwayatList,
  });

  factory RiwayatResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['riwayat'] as List<dynamic>? ?? [];
    return RiwayatResponse(
      summary: RiwayatSummary.fromJson(json['ringkasan'] as Map<String, dynamic>?),
      riwayatList: rawList.map((item) => RiwayatItem.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}