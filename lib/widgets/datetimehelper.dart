import 'package:intl/intl.dart';

class DateTimeHelper {
  static final _istOffset = const Duration(hours: 5, minutes: 30);

  /// Converts any DateTime to IST (+5:30) explicitly.
  /// If the DateTime has no timezone info (isUtc == false), it's treated as UTC.
  static DateTime _toIST(DateTime? dateTime) {
    if (dateTime == null) return DateTime.now();
    final utc = dateTime.isUtc ? dateTime : dateTime.toUtc();
    return utc.add(_istOffset);
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final ist = _toIST(dateTime);

    final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
    final minute = ist.minute.toString().padLeft(2, '0');
    final period = ist.hour >= 12 ? 'PM' : 'AM';

    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final ist = _toIST(dateTime);
    return DateFormat('dd MMM yyyy').format(ist);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return "${formatDate(dateTime)} ${formatTime(dateTime)}";
  }

  static String formatDateTimeFull(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final ist = _toIST(dateTime);
    return DateFormat('dd MMM yyyy, hh:mm a').format(ist);
  }

  static String to12Hour(String timeStr) {
    if (timeStr.isEmpty) return timeStr;
    try {
      // Handle both "HH:mm:ss" and "HH:mm" formats
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '${hour12.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return timeStr; // return as-is if parsing fails
    }
  }

  static String formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return DateFormat('dd MMM yyyy').format(parsed);
  }
}
