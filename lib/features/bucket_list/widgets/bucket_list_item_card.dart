// import 'package:flutter/material.dart';
// import '../../../app/theme/app_colors.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../data/database/app_database.dart';

// /// Compact card for one bucket-list item. The item's chosen color is used
// /// only as a subtle accent (leading bar + icon background), never as a
// /// full-card fill.
// class BucketListItemCard extends StatelessWidget {
//   const BucketListItemCard({
//     super.key,
//     required this.item,
//     required this.onTap,
//     required this.onToggleCompleted,
//   });

//   final BucketListItem item;
//   final VoidCallback onTap;
//   final VoidCallback onToggleCompleted;

//   @override
//   Widget build(BuildContext context) {
//     final accent = AppColors.fromKey(item.color);
//     final theme = Theme.of(context);
//     final location = [item.city, item.country]
//         .where((s) => s != null && s.isNotEmpty)
//         .join(', ');

//     return Card(
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Container(width: 4, color: accent),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(AppSpacing.md),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: accent.withValues(alpha: 0.15),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(_iconFor(item.category), color: accent, size: 20),
//                       ),
//                       const SizedBox(width: AppSpacing.md),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item.title,
//                               style: theme.textTheme.titleMedium,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             if (location.isNotEmpty) ...[
//                               const SizedBox(height: 2),
//                               Text(
//                                 location,
//                                 style: theme.textTheme.bodyMedium,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                             const SizedBox(height: AppSpacing.sm),
//                             Text(
//                               '${item.category} • ${item.priority} Priority',
//                               style: theme.textTheme.labelSmall,
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: onToggleCompleted,
//                         icon: Icon(
//                           item.isCompleted
//                               ? Icons.check_circle
//                               : Icons.radio_button_unchecked,
//                           color: item.isCompleted
//                               ? Theme.of(context).colorScheme.primary
//                               : Theme.of(context).textTheme.bodyMedium?.color,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _iconFor(String category) => switch (category) {
//         'Travel' => Icons.flight_takeoff,
//         'Experience' => Icons.auto_awesome,
//         'Personal' => Icons.person_outline,
//         'Career' => Icons.work_outline,
//         'Education' => Icons.school_outlined,
//         'Adventure' => Icons.terrain,
//         _ => Icons.star_outline,
//       };
// }

import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/database/app_database.dart';

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
    final theme = Theme.of(context);
    final accent = AppColors.fromKey(item.color);
    final location = [
      item.city,
      item.country,
    ].where((s) => s != null && s.isNotEmpty).join(', ');
    final done = item.isCompleted;
    final mutedColor = theme.textTheme.bodyMedium?.color;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: done ? 0.66 : 1,
      child: Card(
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent.withValues(alpha: 0.32),
                                accent.withValues(alpha: 0.10),
                              ],
                            ),
                          ),
                          child: Icon(
                            _iconFor(item.category),
                            color: accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: done ? mutedColor : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (location.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place_outlined,
                                      size: 13,
                                      color: mutedColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _CategoryChip(
                                    label: item.category,
                                    color: accent,
                                  ),
                                  _PriorityDot(priority: item.priority),
                                  if (item.targetDate != null)
                                    _MetaChip(
                                      icon: Icons.event_outlined,
                                      label:
                                          '${item.targetDate!.month}/${item.targetDate!.year}',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _CompletionToggle(
                          completed: done,
                          accent: accent,
                          onTap: onToggleCompleted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: muted),
        const SizedBox(width: 3),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

/// A small urgency dot, deliberately independent of the item's own accent
/// color — see the class doc above.
class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});

  final String priority;

  Color get _color => switch (priority) {
    'High' => const Color(0xFFEF4444),
    'Medium' => const Color(0xFFEAB308),
    _ => const Color(0xFF9CA3AF),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(priority, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _CompletionToggle extends StatelessWidget {
  const _CompletionToggle({
    required this.completed,
    required this.accent,
    required this.onTap,
  });

  final bool completed;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? accent : Colors.transparent,
          border: Border.all(
            color: completed ? accent : theme.colorScheme.outline,
            width: 1.6,
          ),
        ),
        child: completed
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
