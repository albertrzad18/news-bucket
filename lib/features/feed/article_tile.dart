import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/time_utils.dart';
import '../../core/widgets/category_marker.dart';
import '../../data/models/article.dart';
import '../../data/providers.dart';
import 'article_actions.dart';
import 'feed_providers.dart';

/// Article card ("paper on a desk"), text only. Flat Card from CardTheme
/// (white on the darker page, radius 8, elevation 0, margin 12/0/12/8).
/// Inside: meta line, serif title (max 3 lines), optional snippet (max 2
/// lines), 48dp action row.
class ArticleTile extends ConsumerWidget {
  const ArticleTile({required this.article, super.key});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final nb = context.nb;
    final meta = context.nbText.meta;
    final read = article.isRead;

    final sourceName =
        ref.watch(sourceNamesProvider).value?[article.sourceId] ??
        article.sourceId;
    final category = ref
        .watch(sourceCatalogProvider)
        .value
        ?.where((c) => c.id == article.sourceId)
        .firstOrNull
        ?.category;

    final metaStyle = meta.copyWith(color: read ? nb.read : s.onSurfaceVariant);
    final tail = [
      timeAgo(article.publishedAt),
      if (article.score != null) '▲ ${article.score}',
    ].join(' · ');

    return Card(
      child: InkWell(
        onTap: () => openArticle(ref, article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  if (category != null) ...[
                    CategoryMarker(category),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      sourceName,
                      style: metaStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(' · $tail', style: metaStyle, maxLines: 1),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: theme.textTheme.titleLarge!
                        .withWeight(read ? FontWeight.w400 : FontWeight.w500)
                        .copyWith(color: read ? nb.read : s.onSurface),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.snippet != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      article.snippet!,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: read ? nb.read : s.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Action row, 48dp. Outer padding 4 so the comment button's 12dp
            // inner padding puts its icon on the 16dp text edge.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  if (article.commentsUrl != null &&
                      article.commentCount != null)
                    TextButton.icon(
                      onPressed: () => openUrl(article.commentsUrl!),
                      style: TextButton.styleFrom(
                        foregroundColor: s.onSurfaceVariant,
                        textStyle: meta,
                      ),
                      icon: const Icon(Icons.mode_comment_outlined, size: 18),
                      label: Text(
                        article.commentCount == 1
                            ? '1 comment'
                            : '${article.commentCount} comments',
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: read ? 'Mark as unread' : 'Mark as read',
                    iconSize: 20,
                    color: s.outline,
                    icon: Icon(
                      read
                          ? Icons.mark_email_unread_outlined
                          : Icons.drafts_outlined,
                    ),
                    onPressed: () => toggleRead(ref, article),
                  ),
                  IconButton(
                    tooltip: 'Share',
                    iconSize: 20,
                    color: s.outline,
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => shareArticle(article),
                  ),
                  IconButton(
                    tooltip: article.isSaved ? 'Remove from saved' : 'Save',
                    iconSize: 20,
                    color: article.isSaved ? s.primary : s.outline,
                    icon: Icon(
                      article.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    onPressed: () => toggleSaved(ref, article),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
