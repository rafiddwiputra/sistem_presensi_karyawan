class StoreIzinResult {
  final String message;
  final Map<String, dynamic> data;

  const StoreIzinResult({required this.message, required this.data});

  factory StoreIzinResult.fromJson(Map<String, dynamic> json) {
    return StoreIzinResult(
      message: json['message'] as String? ?? 'Pengajuan izin berhasil.',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
