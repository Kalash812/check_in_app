import 'package:intl/intl.dart';

class DateFormatter {
  static final _date = DateFormat('MMM d');
  static final _dateTime = DateFormat('MMM d, h:mma');

  static String short(DateTime date) => _date.format(date);

  static String withTime(DateTime date) => _dateTime.format(date);
}
