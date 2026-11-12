import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../repositories/cuti_repository.dart';
import 'cuti_event.dart';
import 'cuti_state.dart';

class CutiBloc extends Bloc<CutiEvent, CutiState> {
  final CutiRepository repository;

  CutiBloc({required this.repository}) : super(const CutiState()) {
    on<SubmitCuti>(_onSubmitCuti);
    on<FetchRiwayatCuti>(_onFetchRiwayatCuti);
  }

  Future<void> _onFetchRiwayatCuti(FetchRiwayatCuti event, Emitter<CutiState> emit) async {
    emit(state.copyWith(status: CutiStatus.loading, errorMessage: null));

    try {
      final data = await repository.getRiwayatCuti();
      emit(state.copyWith(
        status: CutiStatus.loaded,
        riwayatCuti: data,
      ));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint('CutiBloc Fetch Error (AppException): ${e.message}');
      }
      emit(state.copyWith(status: CutiStatus.error, errorMessage: e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CutiBloc Fetch Error (Unknown): $e');
      }
      emit(state.copyWith(status: CutiStatus.error, errorMessage: 'Gagal mengambil data riwayat cuti.'));
    }
  }

  Future<void> _onSubmitCuti(SubmitCuti event, Emitter<CutiState> emit) async {
    emit(state.copyWith(status: CutiStatus.submitting, errorMessage: null, successMessage: null));

    try {
      // Mengirimkan event.tanggalMulai (DateTime) ke repository yang juga meminta DateTime
      final successMessage = await repository.submitCuti(
        uuidPengajuan: event.uuidPengajuan,
        jenisCuti: event.jenisCuti,
        tanggalMulai: event.tanggalMulai,
        tanggalSelesai: event.tanggalSelesai,
        keterangan: event.keterangan,
      );

      emit(state.copyWith(
        status: CutiStatus.success,
        successMessage: successMessage,
      ));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint('CutiBloc Error (AppException): ${e.message}');
      }
      emit(state.copyWith(status: CutiStatus.error, errorMessage: e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CutiBloc Error (Unknown): $e');
      }
      emit(state.copyWith(status: CutiStatus.error, errorMessage: 'Gagal mengirim pengajuan cuti.'));
    }
  }
}