import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/article.dart';
import '../../data/providers.dart';

/// Opens [url] in a Custom Tab, falling back to the external browser.
Future<void> openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) return;
  } catch (_) {
    // fall through to the external browser
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openArticle(WidgetRef ref, Article article) async {
  await ref.read(newsRepositoryProvider).markRead(article.id);
  await openUrl(article.url);
}

Future<void> shareArticle(Article article) {
  return SharePlus.instance.share(
    ShareParams(text: '${article.title}\n${article.url}'),
  );
}

Future<void> toggleSaved(WidgetRef ref, Article article) {
  return ref
      .read(newsRepositoryProvider)
      .setSaved(article.id, saved: !article.isSaved);
}
