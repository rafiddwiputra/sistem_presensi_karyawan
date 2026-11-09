class TodayAttendanceModel {
  final String tanggal;
  final String nama;
  final JadwalModel jadwal;
  final KantorModel? kantor;
  final PresensiStatusModel presensi;
  final String? aksiBerikutnya;
  final bool presensiSelesai;

  const TodayAttendanceModel({
    required this.tanggal,
    required this.nama,
    required this.jadwal,
    this.kantor,
    required this.presensi,
    this.aksiBerikutnya,
    required this.presensiSelesai,
  });

  factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TodayAttendanceModel(
      tanggal: json['tanggal'] as String,
      nama: json['nama'] as String,
      jadwal: JadwalModel.fromJson(json['jadwal'] as Map<String, dynamic>),
      kantor: json['kantor'] != null
          ? KantorModel.fromJson(json['kantor'] as Map<String, dynamic>)
          : null,
      presensi: PresensiStatusModel.fromJson(
        json['presensi'] as Map<String, dynamic>,
      ),
      aksiBerikutnya: json['aksi_berikutnya'] as String?,
      presensiSelesai: json['presensi_selesai'] as bool? ?? false,
    );
  }
}

class JadwalModel {
  final int id;
  final String nama;
  final String jamMasuk;
  final String jamPulang;
  final int toleransiTerlambat;

  const JadwalModel({
    required this.id,
    required this.nama,
    required this.jamMasuk,
    required this.jamPulang,
    required this.toleransiTerlambat,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      jamMasuk: json['jam_masuk'] as String,
      jamPulang: json['jam_pulang'] as String,
      toleransiTerlambat: json['toleransi_terlambat'] as int? ?? 0,
    );
  }
}

class KantorModel {
  final int id;
  final String nama;
  final double latitude;
  final double longitude;
  final int radiusMeter;

  const KantorModel({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.radiusMeter,
  });

  factory KantorModel.fromJson(Map<String, dynamic> json) {
    return KantorModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeter: json['radius_meter'] as int,
    );
  }
}

class PresensiStatusModel {
  final bool sudahMasuk;
  final bool sudahKeluar;
  final String? waktuMasuk;
  final String? waktuKeluar;
  final int menitTerlambat;
  final String? statusKehadiran;

  const PresensiStatusModel({
    required this.sudahMasuk,
    required this.sudahKeluar,
    this.waktuMasuk,
    this.waktuKeluar,
    required this.menitTerlambat,
    this.statusKehadiran,
  });

  factory PresensiStatusModel.fromJson(Map<String, dynamic> json) {
    return PresensiStatusModel(
      sudahMasuk: json['sudah_masuk'] as bool? ?? false,
      sudahKeluar: json['sudah_keluar'] as bool? ?? false,
      waktuMasuk: json['waktu_masuk'] as String?,
      waktuKeluar: json['waktu_keluar'] as String?,
      menitTerlambat: json['menit_terlambat'] as int? ?? 0,
      statusKehadiran: json['status_kehadiran'] as String?,
    );
  }
}
