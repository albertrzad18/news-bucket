import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/time_utils.dart';
import '../../data/models/article.dart';
import 'article_actions.dart';
import 'feed_providers.dart';

class ArticleTile extends ConsumerWidget {
  const ArticleTile({required this.article, super.key});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sourceName =
        ref.watch(sourceNamesProvider).value?[article.sourceId] ??
        article.sourceId;

    final meta = [
      sourceName,
      timeAgo(article.publishedAt),
      if (article.score != null) '▲ ${article.score}',
    ].join(' · ');

    final titleColor = article.isRead
        ? scheme.onSurfaceVariant
        : scheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openArticle(ref, article),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                // The card's right padding is narrow for the icon buttons;
                // text gets the same 16 as on the left.
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: titleColor,
                        fontWeight: article.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.snippet != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.snippet!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (article.commentsUrl != null &&
                      article.commentCount != null)
                    TextButton.icon(
                      onPressed: () => openUrl(article.commentsUrl!),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: Text('${article.commentCount}'),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: article.isRead ? 'Mark as unread' : 'Mark as read',
                    icon: Icon(
                      article.isRead
                          ? Icons.mark_email_unread_outlined
                          : Icons.drafts_outlined,
                    ),
                    onPressed: () => toggleRead(ref, article),
                  ),
                  IconButton(
                    tooltip: 'Share',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => shareArticle(article),
                  ),
                  IconButton(
                    tooltip: article.isSaved ? 'Remove from saved' : 'Save',
                    icon: Icon(
                      article.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: article.isSaved ? scheme.primary : null,
                    ),
                    onPressed: () => toggleSaved(ref, article),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
