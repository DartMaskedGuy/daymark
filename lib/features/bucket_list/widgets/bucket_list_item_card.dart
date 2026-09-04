import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/database/app_database.dart';

/// Compact card for one bucket-list item. The item's chosen color is used
/// only as a subtle accent (leading bar + icon background), never as a
/// full-card fill.
class BucketListItemCard extends StatelessWidget {
  const BucketListItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleCompleted,
  });

  final BucketListItem item;
  final VoidCallback onTap;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromKey(item.color);
    final theme = Theme.of(context);
    final location = [item.city, item.country]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_iconFor(item.category), color: accent, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (location.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                location,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${item.category} • ${item.priority} Priority',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onToggleCompleted,
                        icon: Icon(
                          item.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: item.isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String category) => switch (category) {
        'Travel' => Icons.flight_takeoff,
        'Experience' => Icons.auto_awesome,
        'Personal' => Icons.person_outline,
        'Career' => Icons.work_outline,
        'Education' => Icons.school_outlined,
        'Adventure' => Icons.terrain,
        _ => Icons.star_outline,
      };
}
