import 'package:intl/intl.dart';

class DateFormatter {
  static String formatIndonesianDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return rawDate;
    }
  }

  static String formatIndonesianDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime) + ' WIB';
    } catch (_) {
      return rawDate;
    }
  }

  static String getRelativeTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final inputDate = DateTime.parse(rawDate);
      final now = DateTime.now();
      final difference = now.difference(inputDate);

      if (difference.inSeconds < 60) return 'Baru saja';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m yang lalu';
      if (difference.inHours < 24) return '${difference.inHours}j yang lalu';
      if (difference.inDays < 7) return '${difference.inDays}h yang lalu';

      return DateFormat('d MMM yyyy', 'id_ID').format(inputDate);
    } catch (_) {
      return rawDate;
    }
  }
}
