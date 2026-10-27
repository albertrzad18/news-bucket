import 'package:flutter/material.dart';

import '../../data/models/news_category.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News Bucket')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final category in NewsCategory.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(category.label),
                      selected: false,
                      onSelected: null,
                    ),
                  ),
              ],
            ),
          ),
          const Expanded(
            child: Center(child: Text('Articles will appear here.')),
          ),
        ],
      ),
    );
  }
}
