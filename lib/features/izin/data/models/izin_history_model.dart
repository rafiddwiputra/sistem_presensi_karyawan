import 'package:flutter/foundation.dart';

class IzinHistoryItem {
  final int id;
  final String jenis;
  final String jenisLabel;
  final String status;
  final String statusLabel;
  final String submittedAt;
  final String purpose;
  final String keterangan;
  final String catatanAdmin;
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
    this.keterangan = '',
    this.catatanAdmin = '',
    required this.startDate,
    required this.endDate,
  });

  factory IzinHistoryItem.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('IZIN_JSON_ITEM: $json');
    }

    final detail = json['detail'] is Map<String, dynamic>
        ? json['detail'] as Map<String, dynamic>
        : (json['izin'] is Map<String, dynamic>
        ? json['izin'] as Map<String, dynamic>
        : const <String, dynamic>{});

    String readString(List<String> keys, {bool ignoreZero = false}) {
      for (final key in keys) {
        final val = json[key] ?? detail[key];
        if (val != null) {
          final text = val.toString().trim();
          if (text.isNotEmpty && (!ignoreZero || text != '0')) {
            return text;
          }
        }
      }
      return '';
    }

    final parsedPurpose = readString(['purpose', 'jenis_izin', 'judul']);
    final parsedKeterangan = readString([
      'keterangan',
      'description',
      'alasan',
      'detail_keterangan',
      'notes',
    ]);

    return IzinHistoryItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      jenis: readString(['jenis']),
      jenisLabel: readString(['jenis_label']),
      status: readString(['status']),
      statusLabel: readString(['status_label']),
      submittedAt: readString(['submitted_at', 'created_at']),
      purpose: parsedPurpose,
      keterangan:
      parsedKeterangan != parsedPurpose ? parsedKeterangan : '',
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