import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

final _whitespace = RegExp(r'\s+');

const _blockSelector =
    'p, li, br, div, h1, h2, h3, h4, h5, h6, tr, blockquote, pre';

/// Collapses runs of whitespace (including newlines) into single spaces.
String collapseWhitespace(String text) =>
    text.replaceAll(_whitespace, ' ').trim();

/// Turns an HTML fragment into plain text: strips tags, decodes entities and
/// collapses whitespace.
String htmlToText(String input) {
  if (!input.contains('<') && !input.contains('&')) {
    return collapseWhitespace(input);
  }
  final fragment = html.parseFragment(input);
  // Drop elements whose text is never useful in a snippet.
  fragment
      .querySelectorAll('script, style, img, figure')
      .forEach((element) => element.remove());
  // Without this, adjacent blocks ("<li>a</li><li>b</li>", "a<p>b") would
  // glue together as "ab" once the tags are gone.
  for (final element in fragment.querySelectorAll(_blockSelector)) {
    final siblings = element.parentNode?.nodes;
    if (siblings == null) continue;
    final index = siblings.indexOf(element);
    siblings
      ..insert(index + 1, dom.Text(' '))
      ..insert(index, dom.Text(' '));
  }
  return collapseWhitespace(fragment.text ?? '');
}

/// Descriptions that are only a link label (Lobsters link posts) carry no
/// information.
const _boilerplateSnippets = {'comments'};

/// Builds a short plain-text snippet, cut at a word boundary.
String? makeSnippet(String? input, {int maxLength = 300}) {
  if (input == null) return null;
  final text = htmlToText(input);
  if (text.isEmpty || _boilerplateSnippets.contains(text.toLowerCase())) {
    return null;
  }
  if (text.length <= maxLength) return text;
  final cut = text.substring(0, maxLength);
  final lastSpace = cut.lastIndexOf(' ');
  final base = lastSpace > maxLength * 0.6 ? cut.substring(0, lastSpace) : cut;
  return '${base.trimRight()}…';
}
