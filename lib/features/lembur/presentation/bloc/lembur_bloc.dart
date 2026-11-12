import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../repositories/lembur_repositories.dart';
import 'lembur_event.dart';
import 'lembur_state.dart';

class LemburBloc extends Bloc<LemburEvent, LemburState> {
  final LemburRepository repository;

  LemburBloc({required this.repository}) : super(const LemburState()) {
    on<FetchRiwayatLembur>(_onFetchRiwayatLembur);
    on<SubmitLembur>(_onSubmitLembur);
  }

  Future<void> _onFetchRiwayatLembur(FetchRiwayatLembur event, Emitter<LemburState> emit) async {
    emit(state.copyWith(status: LemburStatus.loading, errorMessage: null));

    try {
      final data = await repository.getRiwayatLembur();
      emit(state.copyWith(
        status: LemburStatus.loaded,
        riwayatLembur: data,
      ));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint('LemburBloc Fetch Error: ${e.message}');
      }
      emit(state.copyWith(status: LemburStatus.error, errorMessage: e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LemburBloc Fetch Error (Unknown): $e');
      }
      emit(state.copyWith(status: LemburStatus.error, errorMessage: 'Gagal mengambil riwayat lembur.'));
    }
  }

  Future<void> _onSubmitLembur(SubmitLembur event, Emitter<LemburState> emit) async {
    emit(state.copyWith(status: LemburStatus.submitting, errorMessage: null, successMessage: null));

    try {
      final successMessage = await repository.submitLembur(
        uuidPengajuan: event.uuidPengajuan,
        tanggalLembur: event.tanggalLembur,
        jamMulai: event.jamMulai,
        jamSelesai: event.jamSelesai,
        alasanLembur: event.alasanLembur,
      );

      emit(state.copyWith(
        status: LemburStatus.success,
        successMessage: successMessage,
      ));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint('LemburBloc Error: ${e.message}');
      }
      emit(state.copyWith(status: LemburStatus.error, errorMessage: e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LemburBloc Error (Unknown): $e');
      }
      emit(state.copyWith(status: LemburStatus.error, errorMessage: 'Gagal mengirim pengajuan lembur.'));
    }
  }
}