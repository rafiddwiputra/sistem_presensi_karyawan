class CutiModel {
  final int id;
  final String jenis;
  final String jenisLabel;
  final String status;
  final String statusLabel;
  final String submittedAt;
  final String? purpose;
  final String keterangan;
  final String catatanAdmin;
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
    this.keterangan = '',
    this.catatanAdmin = '',
    required this.startDate,
    required this.endDate,
  });

  factory CutiModel.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'] is Map<String, dynamic>
        ? json['detail'] as Map<String, dynamic>
        : (json['cuti'] is Map<String, dynamic>
        ? json['cuti'] as Map<String, dynamic>
        : const <String, dynamic>{});

    String readString(List<String> keys, {bool ignoreZero = false}) {
      for (final key in keys) {
        for (final source in [detail[key], json[key]]) {
          if (source != null) {
            final text = source.toString().trim();
            if (text.isNotEmpty && (!ignoreZero || text != '0')) {
              return text;
            }
          }
        }
      }
      return '';
    }

    final parsedPurpose = readString(['purpose', 'jenis_cuti', 'judul']);

    return CutiModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      jenis: readString(['jenis']),
      jenisLabel: readString(['jenis_label']),
      status: readString(['status']),
      statusLabel: readString(['status_label']),
      submittedAt: readString(['submitted_at', 'created_at']),
      purpose: parsedPurpose.isNotEmpty ? parsedPurpose : null,
      keterangan: readString([
        'keterangan',
        'alasan',
        'alasan_cuti',
        'description',
        'detail_keterangan',
        'notes',
      ]),
      catatanAdmin: readString(
        [
          'rejection_reason',
          'catatan_admin',
          'alasan_ditolak',
          'catatan',
          'admin_note',
        ],
        ignoreZero: true,
      ),
      startDate: readString(['start_date', 'tanggal_mulai']),
      endDate: readString(['end_date', 'tanggal_selesai']),
    );
  }
}