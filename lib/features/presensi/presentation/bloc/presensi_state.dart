import 'package:equatable/equatable.dart';

import '../../data/models/today_attendance_model.dart';

enum PresensiStatus {
  initial,
  loading,
  loaded,
  locationChecking,
  error,
  submitting,
  submitSuccess,
}

class _Unset {
  const _Unset();
}

const _unset = _Unset();

class PresensiState extends Equatable {
  final PresensiStatus status;
  final TodayAttendanceModel? attendanceData;
  final double? userLatitude;
  final double? userLongitude;
  final double? userAccuracy;
  final bool isDalamRadius;
  final int jarakMeter;
  final String? errorMessage;
  final String? successMessage;
  final String? uuidPresensi;

  const PresensiState({
    this.status = PresensiStatus.initial,
    this.attendanceData,
    this.userLatitude,
    this.userLongitude,
    this.userAccuracy,
    this.isDalamRadius = false,
    this.jarakMeter = 0,
    this.errorMessage,
    this.successMessage,
    this.uuidPresensi,
  });

  PresensiState copyWith({
    PresensiStatus? status,
    TodayAttendanceModel? attendanceData,
    double? userLatitude,
    double? userLongitude,
    double? userAccuracy,
    bool? isDalamRadius,
    int? jarakMeter,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    String? uuidPresensi,
  }) {
    return PresensiState(
      status: status ?? this.status,
      attendanceData: attendanceData ?? this.attendanceData,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      userAccuracy: userAccuracy ?? this.userAccuracy,
      isDalamRadius: isDalamRadius ?? this.isDalamRadius,
      jarakMeter: jarakMeter ?? this.jarakMeter,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: successMessage == _unset
          ? this.successMessage
          : successMessage as String?,
      uuidPresensi: uuidPresensi ?? this.uuidPresensi,
    );
  }

  @override
  List<Object?> get props => [
    status,
    attendanceData,
    userLatitude,
    userLongitude,
    userAccuracy,
    isDalamRadius,
    jarakMeter,
    errorMessage,
    successMessage,
    uuidPresensi,
  ];
}
