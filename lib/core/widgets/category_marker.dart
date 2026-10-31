import 'package:flutter/material.dart';

import '../../data/models/news_category.dart';
import '../theme/app_theme.dart';

/// 6×6 square in the category's colour, shown next to its name.
class CategoryMarker extends StatelessWidget {
  const CategoryMarker(this.category, {super.key});

  final NewsCategory category;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.nb.category(category.id),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
