import 'package:intl/intl.dart';

String xTimeAgo(DateTime dt) {
  Duration difference = DateTime.now().difference(dt);
  if (difference.inMinutes < 2) {
    return "just now";
  }

  if (difference.inMinutes < 60) {
    return "${difference.inMinutes} min ago";
  }

  if (difference.inHours < 24) {
    return "${difference.inHours} hrs ago";
  }

  if (difference.inDays == 1) {
    return "yesterday";
  }

  if (difference.inDays < 7) {
    return "${difference.inDays} days ago";
  }

  return DateFormat('dd MMM, yyyy').format(dt);
}

ddMMMyyyy(DateTime d) {
  return DateFormat('dd MMM, yyyy').format(d);
}
