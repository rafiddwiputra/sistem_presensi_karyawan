import 'package:intl/intl.dart';

class DateFormatter {
  static String formatWithDay(String? rawDate, {String pattern = 'EEEE, d MMMM yyyy'}) {
    if (rawDate == null) return '-';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat(pattern, 'id_ID').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  static String currentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }
}