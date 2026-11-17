import 'package:flutter/foundation.dart';

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

  String? get catatanAdmin => rejectionReason;

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
    debugPrint('LEMBUR_JSON_ITEM: $json');

    final detail = json['detail'] is Map<String, dynamic>
        ? json['detail'] as Map<String, dynamic>
        : (json['lembur'] is Map<String, dynamic>
        ? json['lembur'] as Map<String, dynamic>
        : const <String, dynamic>{});

    String readString(List<String> keys, {bool ignoreZero = false}) {
      for (final key in keys) {
        for (final source in [detail[key], json[key]]) {
          if (source != null) {
            final text = source.toString().trim();
            if (text.isNotEmpty &&
                text != 'null' &&
                (!ignoreZero || text != '0')) {
              return text;
            }
          }
        }
      }
      return '';
    }

    String extractTimeFromDateTime(String raw) {
      if (raw.isEmpty || (!raw.contains(':') && !raw.contains('T'))) {
        return '';
      }
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return '';
      final local = raw.endsWith('Z') ? parsed.toLocal() : parsed;
      if (local.hour == 0 && local.minute == 0 && local.second == 0) {
        return '';
      }
      final hh = local.hour.toString().padLeft(2, '0');
      final mm = local.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    final String tgl = readString([
      'date',
      'tanggal_lembur',
      'tanggal',
      'start_date',
    ]);

    final String alasan = readString([
      'reason',
      'alasan_lembur',
      'alasan',
      'keterangan',
      'description',
      'purpose',
      'notes',
    ]);

    String mulai = readString([
      'start_time',
      'jam_mulai',
      'waktu_mulai',
      'time_start',
      'mulai',
      'jam_awal',
    ]);

    String selesai = readString([
      'end_time',
      'jam_selesai',
      'waktu_selesai',
      'time_end',
      'selesai',
      'jam_akhir',
    ]);

    // Cadangan jika backend mengirim format gabungan seperti "17:00 - 19:00"
    if (mulai.isEmpty || selesai.isEmpty) {
      final range = readString(['jam', 'waktu', 'jam_lembur', 'waktu_lembur']);
      if (range.contains('-')) {
        final parts = range.split('-');
        if (parts.length >= 2) {
          if (mulai.isEmpty) mulai = parts[0].replaceAll('WIB', '').trim();
          if (selesai.isEmpty) selesai = parts[1].replaceAll('WIB', '').trim();
        }
      }
    }

    // Cadangan jika jam tergabung di dalam timestamp start_date / end_date
    if (mulai.isEmpty) {
      mulai = extractTimeFromDateTime(readString(['start_date', 'mulai_at']));
    }
    if (selesai.isEmpty) {
      selesai = extractTimeFromDateTime(readString(['end_date', 'selesai_at']));
    }

    final String parsedRejection = readString(
      [
        'rejection_reason',
        'catatan_admin',
        'alasan_ditolak',
        'catatan',
        'admin_note',
      ],
      ignoreZero: true,
    );

    return LemburModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      jenis: readString(['jenis']),
      jenisLabel: readString(['jenis_label']),
      status: readString(['status']),
      statusLabel: readString(['status_label']),
      submittedAt: readString(['submitted_at', 'created_at']),
      rejectionReason: parsedRejection.isNotEmpty ? parsedRejection : null,
      tanggalLembur: tgl,
      jamMulai: mulai,
      jamSelesai: selesai,
      alasanLembur: alasan,
    );
  }
}