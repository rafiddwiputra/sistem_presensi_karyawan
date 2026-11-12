import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Pastikan path import ini sesuai dengan lokasi file app_exception.dart di proyekmu
import '../../../../core/errors/app_exception.dart';
import '../../repositories/izin_repository.dart';
import 'izin_event.dart';
import 'izin_state.dart';

class IzinBloc extends Bloc<IzinEvent, IzinState> {
  final IzinRepository repository;

  IzinBloc({required this.repository}) : super(const IzinState()) {
    on<SubmitIzin>(_onSubmitIzin);
    on<FetchIzinHistory>(_onFetchIzinHistory);
  }

  Future<void> _onSubmitIzin(SubmitIzin event, Emitter<IzinState> emit) async {
    emit(
      state.copyWith(
        status: IzinStatus.submitting,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final result = await repository.submitIzin(
        uuidPengajuan: event.uuidPengajuan,
        jenisIzin: event.jenisIzin,
        tanggalMulai: event.tanggalMulai,
        tanggalSelesai: event.tanggalSelesai,
        keterangan: event.keterangan,
        lampiran: event.lampiran,
      );

      emit(
        state.copyWith(
          status: IzinStatus.success,
          successMessage: result.message,
        ),
      );
    } on AppException catch (e) {
      if (kDebugMode) debugPrint('IzinBloc Error (AppException): ${e.message}');
      emit(state.copyWith(status: IzinStatus.error, errorMessage: e.message));
    } catch (e) {
      if (kDebugMode) debugPrint('IzinBloc Error (Unknown): $e');
      emit(
        state.copyWith(
          status: IzinStatus.error,
          errorMessage: 'Gagal mengirim pengajuan izin.',
        ),
      );
    }
  }

  Future<void> _onFetchIzinHistory(
    FetchIzinHistory event,
    Emitter<IzinState> emit,
  ) async {
    emit(state.copyWith(isLoadingHistory: true, errorMessage: null));
    try {
      final history = await repository.getIzinHistory();
      emit(state.copyWith(isLoadingHistory: false, historyList: history));
    } on AppException catch (e) {
      emit(state.copyWith(isLoadingHistory: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingHistory: false,
          errorMessage: 'Gagal memuat riwayat izin.',
        ),
      );
    }
  }
}
