class LemburModel {
  final int id;
  final String jenis;
  final String jenisLabel;
  final String status;
  final String statusLabel;
  final String submittedAt;
  final String? rejectionReason;

  final String tanggalLembur;
  final String jamMulai;
  final String jamSelesai;
  final String alasanLembur;

  LemburModel({
    required this.id,
    required this.jenis,
    required this.jenisLabel,
    required this.status,
    required this.statusLabel,
    required this.submittedAt,
    this.rejectionReason,
    required this.tanggalLembur,
    required this.jamMulai,
    required this.jamSelesai,
    required this.alasanLembur,
  });

  factory LemburModel.fromJson(Map<String, dynamic> json) {
    // Mengambil objek 'detail' dari respons server
    final detail = json['detail'] as Map<String, dynamic>? ?? {};

    // Mengambil data dengan aman, mendahulukan key dari objek 'detail'
    final String tgl = (detail['date'] ?? json['start_date'] ?? detail['tanggal_lembur'] ?? '').toString();
    final String alasan = (detail['reason'] ?? json['purpose'] ?? detail['alasan_lembur'] ?? '').toString();
    final String mulai = (detail['start_time'] ?? detail['jam_mulai'] ?? '').toString();
    final String selesai = (detail['end_time'] ?? detail['jam_selesai'] ?? '').toString();

    return LemburModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      jenis: json['jenis']?.toString() ?? '',
      jenisLabel: json['jenis_label']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      submittedAt: json['submitted_at']?.toString() ?? '',
      rejectionReason: json['rejection_reason']?.toString(),
      tanggalLembur: tgl,
      jamMulai: mulai,
      jamSelesai: selesai,
      alasanLembur: alasan,
    );
  }
}