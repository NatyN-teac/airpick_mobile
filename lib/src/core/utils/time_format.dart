import 'package:intl/intl.dart';

/// Time formatting helpers shared across the app.
///
/// The backend returns ISO-8601 timestamps in UTC. Some of those timestamps
/// arrive without an explicit `Z`/offset suffix, which `DateTime.parse` would
/// otherwise interpret as *local* time — throwing the "x ago" math off by the
/// device's UTC offset. [parseServerTime] normalizes every timestamp to a
/// local [DateTime] so relative labels are correct regardless of timezone.
class TimeFormat {
  const TimeFormat._();

  /// Parses a server ISO timestamp into local time.
  ///
  /// Timestamps without a timezone designator are assumed to be UTC (the
  /// backend's storage timezone) and then converted to local. Returns `null`
  /// for empty or unparseable input.
  static DateTime? parseServerTime(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final trimmed = iso.trim();
    var dt = DateTime.tryParse(trimmed);
    if (dt == null) return null;
    // If the string carried no timezone info, `tryParse` produced a
    // non-UTC DateTime that actually represents a UTC instant. Re-tag it.
    if (!dt.isUtc && !_hasTimezone(trimmed)) {
      dt = DateTime.utc(
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
        dt.millisecond,
        dt.microsecond,
      );
    }
    return dt.toLocal();
  }

  static bool _hasTimezone(String iso) {
    // Matches a trailing `Z` or a `+hh:mm` / `-hh:mm` offset after the time.
    return RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(iso);
  }

  /// Short relative label, e.g. `just now`, `5m ago`, `3h ago`, `2d ago`,
  /// `4w ago`, `6mo ago`, `2y ago`. Returns '' when [iso] is empty/invalid.
  static String relative(String? iso) {
    final dt = parseServerTime(iso);
    if (dt == null) return '';
    return relativeFromDate(dt);
  }

  /// Relative label from an already-parsed local [DateTime].
  static String relativeFromDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    // Future or clock-skew: treat as "just now" rather than a negative value.
    if (diff.isNegative || diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Verbose relative label, e.g. `just now`, `5 minutes ago`, `1 hour ago`.
  static String relativeLong(String? iso) {
    final dt = parseServerTime(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m minute${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d day${d == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w week${w == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 365) {
      final mo = (diff.inDays / 30).floor();
      return '$mo month${mo == 1 ? '' : 's'} ago';
    }
    final y = (diff.inDays / 365).floor();
    return '$y year${y == 1 ? '' : 's'} ago';
  }

  /// Short absolute date, e.g. `Jan 5`.
  static String shortDate(String? iso) {
    final dt = parseServerTime(iso);
    if (dt == null) return '';
    return DateFormat('MMM d').format(dt);
  }
}
