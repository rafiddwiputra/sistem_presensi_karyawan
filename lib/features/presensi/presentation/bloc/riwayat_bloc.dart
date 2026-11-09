import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
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
      final responseData = await repository.getRiwayat(event.date);

      emit(
        RiwayatLoaded(
          currentDate: event.date,
          summary: responseData.summary,
          riwayatList: responseData.riwayatList,
        ),
      );
    } on AppException catch (e) {
      emit(RiwayatError(e.message, event.date));
    } catch (e) {
      emit(RiwayatError('Terjadi kesalahan yang tidak terduga.', event.date));
    }
  }
}
