class CutiModel {
  final int id;
  final String jenis;
  final String jenisLabel;
  final String status;
  final String statusLabel;
  final String submittedAt;
  final String? purpose;
  final String startDate;
  final String endDate;

  CutiModel({
    required this.id,
    required this.jenis,
    required this.jenisLabel,
    required this.status,
    required this.statusLabel,
    required this.submittedAt,
    this.purpose,
    required this.startDate,
    required this.endDate,
  });

  factory CutiModel.fromJson(Map<String, dynamic> json) {
    // Mengekstrak object 'detail' jika ada (seperti di log terbarumu)
    final detail = json['detail'] as Map<String, dynamic>? ?? {};

    return CutiModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      jenis: json['jenis']?.toString() ?? '',
      jenisLabel: json['jenis_label']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      submittedAt: json['submitted_at']?.toString() ?? '',
      // Ambil dari 'detail' dulu. Jika tidak ada, coba cari di luar (fallback ke struktur lama)
      purpose: detail['purpose']?.toString() ?? json['purpose']?.toString(),
      startDate: detail['start_date']?.toString() ?? json['start_date']?.toString() ?? '',
      endDate: detail['end_date']?.toString() ?? json['end_date']?.toString() ?? '',
    );
  }
}