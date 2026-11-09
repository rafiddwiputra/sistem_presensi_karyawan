class IzinHistoryItem {
  final int id;
  final String jenis;
  final String jenisLabel;
  final String status;
  final String statusLabel;
  final String submittedAt;
  final String purpose;
  final String startDate;
  final String endDate;

  IzinHistoryItem({
    required this.id,
    required this.jenis,
    required this.jenisLabel,
    required this.status,
    required this.statusLabel,
    required this.submittedAt,
    required this.purpose,
    required this.startDate,
    required this.endDate,
  });

  factory IzinHistoryItem.fromJson(Map<String, dynamic> json) {
    return IzinHistoryItem(
      id: json['id'] as int? ?? 0,
      jenis: json['jenis'] as String? ?? '',
      jenisLabel: json['jenis_label'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      submittedAt: json['submitted_at'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '-',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
    );
  }
}
