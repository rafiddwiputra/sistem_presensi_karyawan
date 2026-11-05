import 'package:flutter_bloc/flutter_bloc.dart';
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
      ));

      // Setelah data awal (jadwal & titik kantor) didapat, langsung cari lokasi HP
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
    // Gunakan locationChecking agar UI bisa memunculkan indikator loading kecil di area peta
    emit(state.copyWith(status: PresensiStatus.locationChecking));

    try {
      // 1. Cek apakah GPS menyala
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const FormatException('GPS belum diaktifkan. Silakan nyalakan lokasi perangkat Anda.');
      }

      // 2. Cek Izin Aplikasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const FormatException('Izin lokasi ditolak. Aplikasi butuh akses GPS untuk absensi.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw const FormatException('Izin lokasi ditolak permanen. Buka pengaturan HP untuk mengizinkan.');
      }

      // 3. Tarik Koordinat Presisi Tinggi
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 4. Validasi Radius ke Backend Laravel
      final locationCheck = await repository.checkLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      final isDalamRadius = locationCheck['data']['di_dalam_radius'] ?? false;
      final jarakMeter = (locationCheck['data']['jarak_meter'] as num?)?.toInt() ?? 0;

      emit(state.copyWith(
        status: PresensiStatus.loaded,
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        userAccuracy: position.accuracy,
        isDalamRadius: isDalamRadius,
        jarakMeter: jarakMeter,
        errorMessage: null, // Bersihkan error sebelumnya jika ada
      ));
    } on FormatException catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: e.message));
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

    emit(state.copyWith(status: PresensiStatus.submitting));

    try {
      await repository.storeAttendance(
        uuidPresensi: event.uuidPresensi,
        latitude: state.userLatitude!,
        longitude: state.userLongitude!,
        accuracy: state.userAccuracy ?? 0.0,
      );

      emit(state.copyWith(status: PresensiStatus.submitSuccess));
    } on AppException catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: PresensiStatus.error, errorMessage: 'Gagal memproses presensi.'));
    }
  }
}