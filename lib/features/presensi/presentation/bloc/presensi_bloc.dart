import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/app_exception.dart';
import '../../repositories/presensi_repository.dart';
import 'presensi_event.dart';
import 'presensi_state.dart';

class PresensiBloc extends Bloc<PresensiEvent, PresensiState> {
  final PresensiRepository repository;

  PresensiBloc({required this.repository}) : super(const PresensiState()) {
    on<LoadPresensiData>(_onLoadPresensiData);
    on<RefreshLokasi>(_onRefreshLokasi);
    on<SubmitPresensi>(_onSubmitPresensi);
  }

  Future<void> _onLoadPresensiData(
      LoadPresensiData event,
      Emitter<PresensiState> emit,
      ) async {
    emit(state.copyWith(status: PresensiStatus.loading));
    try {
      final attendanceData = await repository.getTodayAttendance();
      emit(state.copyWith(
        status: PresensiStatus.loaded,
        attendanceData: attendanceData,
        uuidPresensi: const Uuid().v4(),
      ));
      add(RefreshLokasi());
    } on AppException catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: 'Terjadi kesalahan sistem.'));
    }
  }

  Future<void> _onRefreshLokasi(
      RefreshLokasi event,
      Emitter<PresensiState> emit,
      ) async {
    emit(state.copyWith(status: PresensiStatus.locationChecking));

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw const LocationException('GPS belum diaktifkan. Silakan nyalakan lokasi perangkat Anda.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw const LocationException('Izin lokasi ditolak. Aplikasi butuh akses GPS.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException('Izin lokasi ditolak permanen. Buka pengaturan HP untuk mengizinkan.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final locationCheck = await repository.checkLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      emit(state.copyWith(
        status: PresensiStatus.loaded,
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        userAccuracy: position.accuracy,
        isDalamRadius: locationCheck.isDalamRadius,
        jarakMeter: locationCheck.jarakMeter,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: 'Gagal mendeteksi lokasi.'));
    }
  }

  Future<void> _onSubmitPresensi(
      SubmitPresensi event,
      Emitter<PresensiState> emit,
      ) async {
    if (state.userLatitude == null || state.userLongitude == null) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: 'Lokasi belum ditemukan. Silakan refresh.'));
      return;
    }

    emit(state.copyWith(status: PresensiStatus.submitting, errorMessage: null, successMessage: null));

    try {
      final result = await repository.storeAttendance(
        uuidPresensi: event.uuidPresensi,
        jenisPresensi: event.jenisPresensi,
        latitude: state.userLatitude!,
        longitude: state.userLongitude!,
        accuracy: state.userAccuracy ?? 0.0,
      );

      emit(state.copyWith(
        status: PresensiStatus.submitSuccess,
        successMessage: result.message,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: 'Gagal memproses presensi.'));
    }
  }
}