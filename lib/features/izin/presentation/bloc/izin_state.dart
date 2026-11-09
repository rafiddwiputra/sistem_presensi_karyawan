import 'package:equatable/equatable.dart';

import '../../data/models/izin_history_model.dart';

enum IzinStatus { initial, submitting, success, error }

class IzinState extends Equatable {
  final IzinStatus status;
  final List<IzinHistoryItem> historyList;
  final bool isLoadingHistory;
  final String? errorMessage;
  final String? successMessage;

  const IzinState({
    this.status = IzinStatus.initial,
    this.historyList = const [],
    this.isLoadingHistory = false,
    this.errorMessage,
    this.successMessage,
  });

  IzinState copyWith({
    IzinStatus? status,
    List<IzinHistoryItem>? historyList,
    bool? isLoadingHistory,
    String? errorMessage,
    String? successMessage,
  }) {
    return IzinState(
      status: status ?? this.status,
      historyList: historyList ?? this.historyList,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    historyList,
    isLoadingHistory,
    errorMessage,
    successMessage,
  ];
}
