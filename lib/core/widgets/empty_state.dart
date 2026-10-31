import 'package:flutter/material.dart';

/// Left-aligned message for an empty or failed list. Scrollable so
/// pull-to-refresh also works when there is nothing to show.
class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, this.body, this.action, super.key});

  final String title;
  final String? body;

  /// Usually a [TextButton]; shifted left so its text lines up with [title].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 120, 32, 0),
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall!.copyWith(
            color: scheme.onSurface,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                body!,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Transform.translate(
              offset: const Offset(-12, 0),
              child: action,
            ),
          ),
        ],
      ],
    );
  }
}
