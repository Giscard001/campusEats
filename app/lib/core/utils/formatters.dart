import 'package:intl/intl.dart';

abstract final class Fmt {
  static String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static DateTime parseApiDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed.toUtc();
    return DateTime.now().toUtc();
  }

  static String shortDate(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'fr_FR').format(date);

  static String fullDate(DateTime date) =>
      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);

  static String dayMonth(DateTime date) =>
      DateFormat('EEE d MMM', 'fr_FR').format(date);

  static String time(DateTime date) =>
      DateFormat('HH:mm', 'fr_FR').format(date);

  static String dateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);

  static String weekdayShort(DateTime date) =>
      DateFormat('EEE d', 'fr_FR').format(date);
}
