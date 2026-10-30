import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/source_config.dart';

const sourcesAsset = 'assets/sources.json';

List<SourceConfig> parseSourceCatalog(String json) {
  final sources = (jsonDecode(json) as Map<String, dynamic>)['sources'] as List;
  return sources
      .cast<Map<String, dynamic>>()
      .map(SourceConfig.fromJson)
      .toList(growable: false);
}

Future<List<SourceConfig>> loadSourceCatalog([AssetBundle? bundle]) async {
  final json = await (bundle ?? rootBundle).loadString(sourcesAsset);
  return parseSourceCatalog(json);
}
