class ReimbursementModel {
  final int id;
  final String tanggal;
  final String keperluan;
  final int nominal;
  final String? amountLabel;
  final String status;
  final String? statusLabel;
  final String? catatanAdmin;
  final String? lampiranName;
  final String? lampiranUrl;

  ReimbursementModel({
    required this.id,
    required this.tanggal,
    required this.keperluan,
    required this.nominal,
    this.amountLabel,
    required this.status,
    this.statusLabel,
    this.catatanAdmin,
    this.lampiranName,
    this.lampiranUrl,
  });

  factory ReimbursementModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> detail = json['detail'] is Map
        ? Map<String, dynamic>.from(json['detail'] as Map)
        : json;

    final Map<String, dynamic>? receipt = detail['receipt'] is Map
        ? Map<String, dynamic>.from(detail['receipt'] as Map)
        : null;

    final dynamic rawAmount = detail['amount'] ?? json['nominal'];
    int parsedNominal = 0;
    if (rawAmount is num) {
      parsedNominal = rawAmount.toInt();
    } else if (rawAmount != null) {
      parsedNominal =
          num.tryParse(rawAmount.toString().replaceAll('.', ''))?.toInt() ?? 0;
    }

    final dynamic rawNote =
        json['rejection_reason'] ?? detail['note'] ?? json['catatan_admin'];

    return ReimbursementModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tanggal: (detail['expense_date'] ??
          json['tanggal'] ??
          json['submitted_at'] ??
          '')
          .toString(),
      keperluan: (detail['purpose'] ??
          json['keterangan'] ??
          json['keperluan'] ??
          '')
          .toString(),
      nominal: parsedNominal,
      amountLabel: detail['amount_label']?.toString(),
      status: (json['status'] ?? 'menunggu').toString(),
      statusLabel: json['status_label']?.toString(),
      catatanAdmin: (rawNote != null && rawNote.toString().trim().isNotEmpty)
          ? rawNote.toString()
          : null,
      lampiranName: (receipt?['name'] ?? json['lampiran_name'])?.toString(),
      lampiranUrl: (receipt?['url'] ?? json['lampiran_url'])?.toString(),
    );
  }
}