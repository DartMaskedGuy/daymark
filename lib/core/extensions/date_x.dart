import 'package:intl/intl.dart';

/// Human-friendly date formatting so raw DateTime values never reach the UI.
extension DateX on DateTime {
  String get relativeOrFormatted {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(year, month, day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return '$diff days ago';
    if (diff >= 7 && diff < 14) return '1 week ago';
    if (diff >= 14 && diff < 30) return '${(diff / 7).floor()} weeks ago';
    return DateFormat('MMM d, y').format(this);
  }

  String get long => DateFormat('MMMM d, y').format(this);

  String get monthYear => DateFormat('MMMM y').format(this);
}
