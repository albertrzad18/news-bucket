const _trackingParams = {
  'fbclid',
  'gclid',
  'mc_cid',
  'mc_eid',
  'ref',
  'ref_src',
  'source',
};

/// Normalizes an article URL so the same story from different feeds maps to
/// one id: lowercases scheme and host, drops the fragment, tracking query
/// parameters and a trailing slash.
String normalizeUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return url.trim();

  final query = Map.of(uri.queryParametersAll)
    ..removeWhere(
      (key, _) =>
          key.toLowerCase().startsWith('utm_') ||
          _trackingParams.contains(key.toLowerCase()),
    );

  var path = uri.path;
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  return Uri(
    scheme: uri.scheme.toLowerCase() == 'http' ? 'https' : uri.scheme,
    host: uri.host.toLowerCase(),
    port: uri.hasPort ? uri.port : null,
    path: path,
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}
