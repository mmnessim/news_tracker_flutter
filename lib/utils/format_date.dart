import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  return DateFormat('MMMM d, yyyy').format(date);
}
