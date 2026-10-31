import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../feed/article_tile.dart';
import '../feed/feed_providers.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedArticlesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: saved.when(
        data: (items) => items.isEmpty
            ? const EmptyState(
                title: 'Nothing saved yet.',
                body: 'Tap the bookmark on an article to keep it here.',
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: items.length,
                itemBuilder: (_, i) =>
                    ArticleTile(key: ValueKey(items[i].id), article: items[i]),
              ),
        // Local database only, so there is nothing worth a spinner.
        loading: () => const SizedBox.shrink(),
        error: (error, _) =>
            EmptyState(title: "Couldn't load saved articles.", body: '$error'),
      ),
    );
  }
}
