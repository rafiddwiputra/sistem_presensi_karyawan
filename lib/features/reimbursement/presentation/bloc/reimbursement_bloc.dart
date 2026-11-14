import 'package:flutter_bloc/flutter_bloc.dart';
import 'reimbursement_event.dart';
import 'reimbursement_state.dart';
import '../../repositories/reimbursement_repository.dart';

class ReimbursementBloc extends Bloc<ReimbursementEvent, ReimbursementState> {
  final ReimbursementRepository repository;

  ReimbursementBloc({required this.repository}) : super(const ReimbursementState()) {
    on<LoadRiwayatReimbursement>(_onLoadRiwayat);
    on<SubmitReimbursement>(_onSubmit);
  }

  Future<void> _onLoadRiwayat(
      LoadRiwayatReimbursement event,
      Emitter<ReimbursementState> emit,
      ) async {
    emit(state.copyWith(status: ReimbursementStatus.loading));
    try {
      final data = await repository.getRiwayatReimbursement();
      emit(state.copyWith(
        status: ReimbursementStatus.success,
        riwayat: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReimbursementStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSubmit(
      SubmitReimbursement event,
      Emitter<ReimbursementState> emit,
      ) async {
    emit(state.copyWith(status: ReimbursementStatus.loading));
    try {
      final message = await repository.submitReimbursement(
        tanggal: event.tanggal,
        keperluan: event.keperluan,
        nominal: event.nominal,
        lampiran: event.lampiran,
      );

      // PERBAIKAN: Masukkan juga data form ke state agar halaman berhasil bisa membacanya
      emit(state.copyWith(
        status: ReimbursementStatus.submitSuccess,
        successMessage: message,
        tanggal: event.tanggal,
        keperluan: event.keperluan,
        nominal: event.nominal,
        lampiran: event.lampiran,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReimbursementStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}