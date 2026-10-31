import 'package:xml/xml.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../core/utils/url_utils.dart';
import '../models/article.dart';
import '../models/source_config.dart';

/// Parses RSS 2.0, RSS 1.0 (RDF) and Atom documents.
///
/// Elements are matched by local name, so namespace prefixes (`dc:`,
/// `content:`, `media:`, `atom:`) don't matter. Items without a title or a
/// link are skipped. Items without a date get [fetchedAt].
List<Article> parseFeed(
  String body,
  SourceConfig source, {
  required DateTime fetchedAt,
}) {
  final root = XmlDocument.parse(body).rootElement;
  final isAtom = root.localName == 'feed';

  final entries = isAtom
      ? _children(root, 'entry')
      : root.localName == 'rss'
      ? _children(_child(root, 'channel') ?? root, 'item')
      : _children(root, 'item'); // RDF: items are siblings of channel

  final articles = <Article>[];
  for (final entry in entries) {
    final article = isAtom
        ? _parseAtomEntry(entry, source, fetchedAt)
        : _parseRssItem(entry, source, fetchedAt);
    if (article != null) articles.add(article);
  }
  return articles;
}

Article? _parseRssItem(XmlElement item, SourceConfig source, DateTime now) {
  final title = _text(item, 'title');
  final link = _text(item, 'link') ?? _permalinkGuid(item);
  if (title == null || link == null) return null;

  return Article(
    id: normalizeUrl(link),
    sourceId: source.id,
    category: source.category,
    title: htmlToText(title),
    url: link,
    publishedAt:
        parseFeedDate(_text(item, 'pubDate')) ??
        parseFeedDate(_text(item, 'date')) ??
        now,
    snippet: makeSnippet(_text(item, 'description') ?? _text(item, 'encoded')),
    imageUrl: _imageUrl(item),
    author: _text(item, 'creator') ?? _text(item, 'author'),
    commentsUrl: _text(item, 'comments'),
  );
}

Article? _parseAtomEntry(XmlElement entry, SourceConfig source, DateTime now) {
  final title = _text(entry, 'title');
  final link = _atomLink(entry);
  if (title == null || link == null) return null;

  final author = _child(entry, 'author');
  return Article(
    id: normalizeUrl(link),
    sourceId: source.id,
    category: source.category,
    title: htmlToText(title),
    url: link,
    publishedAt:
        parseFeedDate(_text(entry, 'published')) ??
        parseFeedDate(_text(entry, 'updated')) ??
        now,
    snippet: makeSnippet(_text(entry, 'summary') ?? _text(entry, 'content')),
    imageUrl: _imageUrl(entry),
    author: author == null ? null : _text(author, 'name'),
  );
}

String? _atomLink(XmlElement entry) {
  final links = _children(entry, 'link').toList();
  for (final link in links) {
    final rel = link.getAttribute('rel');
    if (rel == null || rel == 'alternate') {
      final href = link.getAttribute('href');
      if (href != null && href.isNotEmpty) return href.trim();
    }
  }
  return links.isEmpty ? null : links.first.getAttribute('href')?.trim();
}

String? _permalinkGuid(XmlElement item) {
  final guid = _child(item, 'guid');
  if (guid == null || guid.getAttribute('isPermaLink') == 'false') return null;
  final value = guid.innerText.trim();
  return value.startsWith('http') ? value : null;
}

/// Author avatars (GitHub release feeds, Gravatar) are not article images.
final _avatarHost = RegExp(
  r'(^|\.)(avatars\.githubusercontent|gravatar)\.com$',
);

String? _imageUrl(XmlElement item) {
  for (final element in item.childElements) {
    final name = element.localName;
    final url = element.getAttribute('url');
    if (url == null || url.isEmpty) continue;
    if (_avatarHost.hasMatch(Uri.tryParse(url)?.host ?? '')) continue;
    if (name == 'thumbnail') return url;
    if (name == 'content' || name == 'enclosure') {
      final type = element.getAttribute('type') ?? '';
      final medium = element.getAttribute('medium') ?? '';
      if (type.startsWith('image/') || medium == 'image') return url;
    }
  }
  return null;
}

XmlElement? _child(XmlElement parent, String localName) {
  for (final element in parent.childElements) {
    if (element.localName == localName) return element;
  }
  return null;
}

Iterable<XmlElement> _children(XmlElement parent, String localName) =>
    parent.childElements.where((element) => element.localName == localName);

/// First non-empty text among children named [localName]. Scans all of them
/// because e.g. an empty `<atom:link/>` can precede the real `<link>`.
String? _text(XmlElement parent, String localName) {
  for (final element in _children(parent, localName)) {
    final value = element.innerText.trim();
    if (value.isNotEmpty) return value;
  }
  return null;
}
