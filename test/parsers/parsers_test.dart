import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/data/models/news_category.dart';
import 'package:news_bucket/data/models/source_config.dart';
import 'package:news_bucket/data/parsers/feed_parser.dart';
import 'package:news_bucket/data/parsers/json_parsers.dart';
import 'package:news_bucket/data/sources/source_fetcher.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

SourceConfig source(SourceType type, {List<String> keywords = const []}) {
  return SourceConfig(
    id: 'test',
    name: 'Test',
    category: NewsCategory.ai,
    type: type,
    url: 'https://example.com',
    limit: 10,
    keywords: keywords,
  );
}

void main() {
  final now = DateTime.utc(2026, 10, 28);

  group('RSS 2.0', () {
    final articles = parseFeed(
      fixture('rss.xml'),
      source(SourceType.feed),
      fetchedAt: now,
    );

    test('skips items without title or link, keeps permalink guids', () {
      expect(articles.map((a) => a.title), [
        'Claude & friends: a test',
        'Guid only',
      ]);
    });

    test('maps fields and normalizes the id', () {
      final article = articles.first;
      expect(article.id, 'https://example.com/post-1?id=7');
      expect(article.url, startsWith('https://Example.com/post-1/'));
      expect(article.publishedAt, DateTime.utc(2026, 10, 27, 10));
      expect(article.author, 'Jane Doe');
      expect(article.imageUrl, 'https://example.com/img.png');
      expect(article.commentsUrl, 'https://example.com/post-1#comments');
      expect(article.snippet, 'Hello world, this is a snippet.');
    });

    test('falls back to fetch time when there is no date', () {
      expect(articles.last.publishedAt, now);
    });
  });

  group('Atom', () {
    final articles = parseFeed(
      fixture('atom.xml'),
      source(SourceType.feed),
      fetchedAt: now,
    );

    test('uses the alternate link, title, updated date and author', () {
      final release = articles.first;
      expect(
        release.url,
        'https://github.com/anthropics/claude-code/releases/tag/v2.0.1',
      );
      expect(release.title, 'v2.0.1');
      expect(release.publishedAt, DateTime.utc(2026, 10, 26, 10, 30));
      expect(release.author, 'octocat');
      expect(release.snippet, 'Fixed a bug Faster startup');
    });

    test('ignores rel=self links and prefers published over updated', () {
      final second = articles.last;
      expect(second.url, 'https://example.com/second');
      expect(second.publishedAt, DateTime.utc(2026, 10, 25, 8));
      expect(second.snippet, 'Short summary');
    });
  });

  test('RSS 1.0 (RDF) items are siblings of channel', () {
    final articles = parseFeed(
      fixture('rdf.xml'),
      source(SourceType.feed),
      fetchedAt: now,
    );
    expect(articles, hasLength(1));
    expect(articles.single.title, 'RDF item');
    expect(articles.single.publishedAt, DateTime.utc(2026, 10, 24, 6));
  });

  group('Hacker News (Algolia)', () {
    final articles = parseHnAlgolia(
      fixture('hn_algolia.json'),
      source(SourceType.hnAlgolia),
    );

    test('skips hits without a title', () {
      expect(articles, hasLength(2));
    });

    test('maps points, comments and the discussion link', () {
      final first = articles.first;
      expect(first.id, 'https://example.com/thing');
      expect(first.score, 250);
      expect(first.commentCount, 42);
      expect(first.commentsUrl, 'https://news.ycombinator.com/item?id=111');
      expect(
        first.publishedAt,
        DateTime.fromMillisecondsSinceEpoch(1793000000 * 1000, isUtc: true),
      );
    });

    test('text posts link to the HN thread', () {
      final ask = articles.last;
      expect(ask.url, 'https://news.ycombinator.com/item?id=222');
      expect(ask.snippet, 'What do you think?');
    });
  });

  test('DEV.to articles', () {
    final articles = parseDevTo(
      fixture('devto.json'),
      source(SourceType.devto),
    );
    expect(articles, hasLength(1));
    final article = articles.single;
    expect(article.title, 'Learning Dart');
    expect(article.score, 77);
    expect(article.commentCount, 5);
    expect(article.author, 'Dev User');
    expect(article.imageUrl, 'https://dev.to/cover.png');
    expect(article.publishedAt, DateTime.utc(2026, 10, 27, 9, 15));
  });

  group('parseSource', () {
    test('sorts newest first and applies the limit', () {
      const limited = SourceConfig(
        id: 't',
        name: 'T',
        category: NewsCategory.ai,
        type: SourceType.feed,
        url: 'https://example.com',
        limit: 1,
      );
      final articles = parseSource(
        fixture('atom.xml'),
        limited,
        fetchedAt: now,
      );
      expect(articles.single.title, 'v2.0.1');
    });

    test('keeps only items matching a keyword (case-insensitive)', () {
      final articles = parseSource(
        fixture('atom.xml'),
        source(SourceType.feed, keywords: ['STARTUP']),
        fetchedAt: now,
      );
      expect(articles.map((a) => a.title), ['v2.0.1']);
    });
  });
}
