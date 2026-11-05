import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/riwayat_repository.dart';
import 'riwayat_event.dart';
import 'riwayat_state.dart';

class RiwayatBloc extends Bloc<RiwayatEvent, RiwayatState> {
  final RiwayatRepository repository;

  RiwayatBloc({required this.repository}) : super(RiwayatInitial()) {
    on<LoadRiwayatRequested>(_onLoadRiwayatRequested);
  }

  Future<void> _onLoadRiwayatRequested(
      LoadRiwayatRequested event,
      Emitter<RiwayatState> emit,
      ) async {
    emit(RiwayatLoading(event.date));

    try {
      final data = await repository.getRiwayat(event.date);

      final ringkasan = data['ringkasan'] as Map<String, dynamic>? ??
          {'hadir': 0, 'lembur': 0, 'izin': 0, 'cuti': 0, 'tidak_hadir': 0};

      final rawRiwayat = data['riwayat'] as List<dynamic>? ?? [];

      final riwayatList = rawRiwayat.map((item) {
        final isLembur = item['is_lembur'] == true;
        return {
          'tanggal': item['tanggal'] ?? '-',
          'status': item['status'] ?? '-',
          'subtitle': isLembur ? 'Lembur' : null,
          'jam_masuk': item['waktu_masuk'] ?? '--:--',
          'jam_keluar': item['waktu_keluar'] ?? '--:--',
        };
      }).toList();

      emit(RiwayatLoaded(
        currentDate: event.date,
        summary: ringkasan,
        riwayatList: riwayatList,
      ));
    } catch (e) {
      emit(RiwayatError('Gagal memuat riwayat presensi dari server', event.date));
    }
  }
}