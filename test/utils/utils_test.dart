import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/core/utils/date_utils.dart';
import 'package:news_bucket/core/utils/text_utils.dart';
import 'package:news_bucket/core/utils/url_utils.dart';

void main() {
  group('parseFeedDate', () {
    test('RFC 822 with numeric offset', () {
      expect(
        parseFeedDate('Tue, 27 Oct 2026 12:00:00 +0200'),
        DateTime.utc(2026, 10, 27, 10),
      );
      expect(
        parseFeedDate('Tue, 27 Oct 2026 12:00:00 -0530'),
        DateTime.utc(2026, 10, 27, 17, 30),
      );
    });

    test('RFC 822 with named zone, no weekday, no seconds', () {
      expect(
        parseFeedDate('27 Oct 2026 12:00 GMT'),
        DateTime.utc(2026, 10, 27, 12),
      );
      expect(
        parseFeedDate('Tue, 27 Oct 2026 08:00:00 EDT'),
        DateTime.utc(2026, 10, 27, 12),
      );
    });

    test('ISO 8601', () {
      expect(
        parseFeedDate('2026-10-27T10:00:00+02:00'),
        DateTime.utc(2026, 10, 27, 8),
      );
      expect(
        parseFeedDate('2026-10-27T10:00:00Z'),
        DateTime.utc(2026, 10, 27, 10),
      );
    });

    test('garbage and empty input return null', () {
      expect(parseFeedDate('yesterday'), isNull);
      expect(parseFeedDate('  '), isNull);
      expect(parseFeedDate(null), isNull);
    });
  });

  group('text utils', () {
    test('htmlToText strips tags, decodes entities, drops scripts', () {
      expect(
        htmlToText('<p>Tom &amp; Jerry</p><script>x()</script>\n<b>win</b>'),
        'Tom & Jerry win',
      );
    });

    test('makeSnippet cuts at a word boundary with an ellipsis', () {
      final snippet = makeSnippet('word ' * 100, maxLength: 50)!;
      expect(snippet.length, lessThanOrEqualTo(51));
      expect(snippet, endsWith('word…'));
    });

    test('makeSnippet returns null for empty content', () {
      expect(makeSnippet('<p> </p>'), isNull);
      expect(makeSnippet(null), isNull);
    });
  });

  group('normalizeUrl', () {
    test(
      'drops tracking params, fragment, trailing slash; lowercases host',
      () {
        expect(
          normalizeUrl(
            'http://Example.COM/a/b/?utm_source=x&id=1&fbclid=z#top',
          ),
          'https://example.com/a/b?id=1',
        );
      },
    );

    test('keeps meaningful query params and root path', () {
      expect(
        normalizeUrl('https://example.com/?p=5'),
        'https://example.com/?p=5',
      );
      expect(normalizeUrl('https://example.com/'), 'https://example.com/');
    });
  });
}
