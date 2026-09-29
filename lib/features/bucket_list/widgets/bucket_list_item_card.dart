// import 'package:flutter/material.dart';
// import '../../../app/theme/app_colors.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../data/database/app_database.dart';

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
//     final theme = Theme.of(context);
//     final accent = AppColors.fromKey(item.color);
//     final location = [
//       item.city,
//       item.country,
//     ].where((s) => s != null && s.isNotEmpty).join(', ');
//     final done = item.isCompleted;
//     final mutedColor = theme.textTheme.bodyMedium?.color;

//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 250),
//       opacity: done ? 0.66 : 1,
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: onTap,
//           child: IntrinsicHeight(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Container(width: 4, color: accent),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(AppSpacing.md),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 44,
//                           height: 44,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 accent.withValues(alpha: 0.32),
//                                 accent.withValues(alpha: 0.10),
//                               ],
//                             ),
//                           ),
//                           child: Icon(
//                             _iconFor(item.category),
//                             color: accent,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: AppSpacing.md),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.title,
//                                 style: theme.textTheme.titleMedium?.copyWith(
//                                   decoration: done
//                                       ? TextDecoration.lineThrough
//                                       : null,
//                                   color: done ? mutedColor : null,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               if (location.isNotEmpty) ...[
//                                 const SizedBox(height: 3),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.place_outlined,
//                                       size: 13,
//                                       color: mutedColor,
//                                     ),
//                                     const SizedBox(width: 3),
//                                     Expanded(
//                                       child: Text(
//                                         location,
//                                         style: theme.textTheme.bodyMedium,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                               const SizedBox(height: AppSpacing.sm),
//                               Wrap(
//                                 spacing: 8,
//                                 runSpacing: 4,
//                                 crossAxisAlignment: WrapCrossAlignment.center,
//                                 children: [
//                                   _CategoryChip(
//                                     label: item.category,
//                                     color: accent,
//                                   ),
//                                   _PriorityDot(priority: item.priority),
//                                   if (item.targetDate != null)
//                                     _MetaChip(
//                                       icon: Icons.event_outlined,
//                                       label:
//                                           '${item.targetDate!.month}/${item.targetDate!.year}',
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: AppSpacing.sm),
//                         _CompletionToggle(
//                           completed: done,
//                           accent: accent,
//                           onTap: onToggleCompleted,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _iconFor(String category) => switch (category) {
//     'Travel' => Icons.flight_takeoff,
//     'Experience' => Icons.auto_awesome,
//     'Personal' => Icons.person_outline,
//     'Career' => Icons.work_outline,
//     'Education' => Icons.school_outlined,
//     'Adventure' => Icons.terrain,
//     _ => Icons.star_outline,
//   };
// }

// class _CategoryChip extends StatelessWidget {
//   const _CategoryChip({required this.label, required this.color});

//   final String label;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.14),
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         label,
//         style: Theme.of(context).textTheme.labelSmall?.copyWith(
//           color: color,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }

// class _MetaChip extends StatelessWidget {
//   const _MetaChip({required this.icon, required this.label});

//   final IconData icon;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     final muted = Theme.of(context).textTheme.bodyMedium?.color;
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 12, color: muted),
//         const SizedBox(width: 3),
//         Text(label, style: Theme.of(context).textTheme.labelSmall),
//       ],
//     );
//   }
// }

// /// A small urgency dot, deliberately independent of the item's own accent
// /// color — see the class doc above.
// class _PriorityDot extends StatelessWidget {
//   const _PriorityDot({required this.priority});

//   final String priority;

//   Color get _color => switch (priority) {
//     'High' => const Color(0xFFEF4444),
//     'Medium' => const Color(0xFFEAB308),
//     _ => const Color(0xFF9CA3AF),
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 6,
//           height: 6,
//           decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 4),
//         Text(priority, style: Theme.of(context).textTheme.labelSmall),
//       ],
//     );
//   }
// }

// class _CompletionToggle extends StatelessWidget {
//   const _CompletionToggle({
//     required this.completed,
//     required this.accent,
//     required this.onTap,
//   });

//   final bool completed;
//   final Color accent;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOutBack,
//         width: 28,
//         height: 28,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: completed ? accent : Colors.transparent,
//           border: Border.all(
//             color: completed ? accent : theme.colorScheme.outline,
//             width: 1.6,
//           ),
//         ),
//         child: completed
//             ? const Icon(Icons.check, size: 16, color: Colors.white)
//             : null,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/database/app_database.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers (also used by filter_sheet.dart)
// ─────────────────────────────────────────────────────────────────────────────

IconData categoryIconFor(String category) => switch (category) {
  'Travel' => Icons.flight_takeoff_rounded,
  'Experience' => Icons.auto_awesome_rounded,
  'Personal' => Icons.person_rounded,
  'Career' => Icons.work_rounded,
  'Education' => Icons.school_rounded,
  'Adventure' => Icons.terrain_rounded,
  _ => Icons.star_rounded,
};

Color priorityColorFor(String priority) => switch (priority) {
  'High' => const Color(0xFFEF4444),
  'Medium' => const Color(0xFFEAB308),
  _ => const Color(0xFF9CA3AF),
};

IconData priorityIconFor(String priority) => switch (priority) {
  'High' => Icons.local_fire_department_rounded,
  'Medium' => Icons.bolt_rounded,
  _ => Icons.spa_rounded,
};

Color _darken(Color c, [double amount = 0.3]) =>
    Color.lerp(c, Colors.black, amount) ?? c;

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class BucketListItemCard extends StatefulWidget {
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
  State<BucketListItemCard> createState() => _BucketListItemCardState();
}

class _BucketListItemCardState extends State<BucketListItemCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = AppColors.fromKey(item.color);
    final done = item.isCompleted;
    final muted = theme.textTheme.bodyMedium?.color;
    final location = [
      item.city,
      item.country,
    ].where((s) => s != null && s.isNotEmpty).join(', ');
    final date = item.targetDate;
    final overdue = date != null && !done && date.isBefore(DateTime.now());

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: done ? 0.66 : 1,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // Soft accent glow in the top-left corner.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.1,
                          colors: [
                            accent.withValues(alpha: 0.16),
                            accent.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onHighlightChanged: (v) => setState(() => _pressed = v),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IconTile(
                            icon: categoryIconFor(item.category),
                            accent: accent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.1,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: done ? muted : null,
                                  ),
                                ),
                                if (location.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.place_rounded,
                                        size: 14,
                                        color: accent,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _Tag(label: item.category, color: accent),
                                    _Tag(
                                      label: item.priority,
                                      color: priorityColorFor(item.priority),
                                      icon: priorityIconFor(item.priority),
                                    ),
                                    if (date != null)
                                      _Tag(
                                        label: DateFormat('MMM y').format(date),
                                        color: overdue
                                            ? scheme.error
                                            : scheme.onSurfaceVariant,
                                        icon: overdue
                                            ? Icons.schedule_rounded
                                            : Icons.event_rounded,
                                        subtle: !overdue,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _CompletionToggle(
                            completed: done,
                            accent: accent,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              widget.onToggleCompleted();
                            },
                          ),
                        ],
                      ),
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
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, _darken(accent, 0.3)],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    this.icon,
    this.subtle = false,
  });

  final String label;
  final Color color;
  final IconData? icon;

  /// Neutral styling for informational tags (e.g. a future target date).
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: subtle
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: completed
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, _darken(accent, 0.3)],
                  )
                : null,
            border: Border.all(
              color: completed ? Colors.transparent : scheme.outline,
              width: 1.8,
            ),
            boxShadow: completed
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: completed
                ? const Icon(
                    Icons.check_rounded,
                    key: ValueKey('done'),
                    size: 18,
                    color: Colors.white,
                  )
                : const SizedBox.shrink(key: ValueKey('todo')),
          ),
        ),
      ),
    );
  }
}
