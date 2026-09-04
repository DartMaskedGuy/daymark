import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

/// The hero "YOUR JOURNEY" card on Home showing lived vs. remaining items.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR JOURNEY', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              total == 0 ? 'Start your list' : '$completed of $total lived',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : progress,
                minHeight: 8,
                backgroundColor: primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              total == 0
                  ? 'Add your first bucket-list item to begin.'
                  : '${(progress * 100).round()}% of your bucket list lived',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
