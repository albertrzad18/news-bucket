const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, //
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

const _zones = {
  'UT': 0, 'UTC': 0, 'GMT': 0, 'Z': 0, //
  'EST': -5, 'EDT': -4, 'CST': -6, 'CDT': -5,
  'MST': -7, 'MDT': -6, 'PST': -8, 'PDT': -7,
  'CET': 1, 'CEST': 2,
};

// e.g. "Tue, 27 Oct 2026 12:00:00 +0000", "27 Oct 2026 12:00 GMT"
final _rfc822 = RegExp(
  r'^(?:[A-Za-z]{3},?\s+)?(\d{1,2})\s+([A-Za-z]{3})[a-z]*\s+(\d{2,4})\s+'
  r'(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([+-]\d{4}|[A-Za-z]{1,4})?$',
);

/// Parses the date formats found in RSS (RFC 822) and Atom/JSON (ISO 8601).
/// Returns a UTC [DateTime], or null when the input is not recognized.
DateTime? parseFeedDate(String? input) {
  if (input == null) return null;
  final text = input.trim();
  if (text.isEmpty) return null;

  final iso = DateTime.tryParse(text);
  if (iso != null) return iso.toUtc();

  final match = _rfc822.firstMatch(text);
  if (match == null) return null;

  final month = _months[match.group(2)!.toLowerCase()];
  if (month == null) return null;
  var year = int.parse(match.group(3)!);
  if (year < 100) year += 2000;

  final utc = DateTime.utc(
    year,
    month,
    int.parse(match.group(1)!),
    int.parse(match.group(4)!),
    int.parse(match.group(5)!),
    int.parse(match.group(6) ?? '0'),
  );
  return utc.subtract(_zoneOffset(match.group(7)));
}

Duration _zoneOffset(String? zone) {
  if (zone == null) return Duration.zero;
  if (zone.startsWith('+') || zone.startsWith('-')) {
    final sign = zone.startsWith('-') ? -1 : 1;
    final hours = int.parse(zone.substring(1, 3));
    final minutes = int.parse(zone.substring(3, 5));
    return Duration(minutes: sign * (hours * 60 + minutes));
  }
  return Duration(hours: _zones[zone.toUpperCase()] ?? 0);
}
