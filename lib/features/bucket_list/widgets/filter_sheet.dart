// import 'package:flutter/material.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../core/constants/item_categories.dart';
// import '../bloc/bucket_list_cubit.dart';

// /// Bottom sheet for choosing category and priority filters. Country/state
// /// filtering is intentionally left for a later pass once real location
// /// data is flowing through the app.
// class FilterSheet extends StatefulWidget {
//   const FilterSheet({super.key, required this.initial});

//   final BucketListFilters initial;

//   @override
//   State<FilterSheet> createState() => _FilterSheetState();
// }

// class _FilterSheetState extends State<FilterSheet> {
//   late ItemCategory? _category = widget.initial.category;
//   late ItemPriority? _priority = widget.initial.priority;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return SafeArea(
//       top: false,
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: AppSpacing.lg,
//           right: AppSpacing.lg,
//           top: AppSpacing.lg,
//           bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Filters', style: theme.textTheme.headlineSmall),
//                 TextButton(
//                   onPressed: () => setState(() {
//                     _category = null;
//                     _priority = null;
//                   }),
//                   child: const Text('Clear all'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSpacing.md),
//             Text('Category', style: theme.textTheme.titleMedium),
//             const SizedBox(height: AppSpacing.sm),
//             Wrap(
//               spacing: AppSpacing.sm,
//               children: ItemCategory.values.map((c) {
//                 return ChoiceChip(
//                   label: Text(c.label),
//                   selected: _category == c,
//                   onSelected: (_) =>
//                       setState(() => _category = _category == c ? null : c),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: AppSpacing.lg),
//             Text('Priority', style: theme.textTheme.titleMedium),
//             const SizedBox(height: AppSpacing.sm),
//             Wrap(
//               spacing: AppSpacing.sm,
//               children: ItemPriority.values.map((p) {
//                 return ChoiceChip(
//                   label: Text(p.label),
//                   selected: _priority == p,
//                   onSelected: (_) =>
//                       setState(() => _priority = _priority == p ? null : p),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: AppSpacing.lg),
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton(
//                 onPressed: () => Navigator.of(context).pop(
//                   BucketListFilters(category: _category, priority: _priority),
//                 ),
//                 child: const Text('Apply filters'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/item_categories.dart';
import '../bloc/bucket_list_cubit.dart';
import 'bucket_list_item_card.dart'
    show categoryIconFor, priorityColorFor, priorityIconFor;

/// Bottom sheet for choosing category and priority filters. Country/state
/// filtering is intentionally left for a later pass once real location
/// data is flowing through the app.
///
/// The sheet paints its own rounded surface, so open it with a transparent
/// `backgroundColor` in `showModalBottomSheet`.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final BucketListFilters initial;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ItemCategory? _category = widget.initial.category;
  late ItemPriority? _priority = widget.initial.priority;

  int get _activeCount =>
      (_category != null ? 1 : 0) + (_priority != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = scheme.primary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Container(
        color: scheme.surface,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primary.withValues(alpha: 0.16),
                        primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  10,
                  AppSpacing.lg,
                  MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filters',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Refine what you see',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _activeCount == 0 ? 0 : 1,
                          child: IgnorePointer(
                            ignoring: _activeCount == 0,
                            child: TextButton.icon(
                              onPressed: () => setState(() {
                                _category = null;
                                _priority = null;
                              }),
                              icon: const Icon(
                                Icons.restart_alt_rounded,
                                size: 18,
                              ),
                              label: const Text('Clear all'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label(
                              icon: Icons.category_rounded,
                              text: 'Category',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final c in ItemCategory.values)
                                  _PillChoice(
                                    label: c.label,
                                    icon: categoryIconFor(c.label),
                                    selected: _category == c,
                                    onTap: () => setState(
                                      () =>
                                          _category = _category == c ? null : c,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _Label(icon: Icons.flag_rounded, text: 'Priority'),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                for (
                                  var i = 0;
                                  i < ItemPriority.values.length;
                                  i++
                                ) ...[
                                  if (i > 0)
                                    const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: _PriorityTile(
                                      label: ItemPriority.values[i].label,
                                      selected:
                                          _priority == ItemPriority.values[i],
                                      onTap: () => setState(() {
                                        final p = ItemPriority.values[i];
                                        _priority = _priority == p ? null : p;
                                      }),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ApplyButton(
                      label: _activeCount == 0
                          ? 'Show everything'
                          : 'Apply $_activeCount filter${_activeCount == 1 ? '' : 's'}',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(
                          BucketListFilters(
                            category: _category,
                            priority: _priority,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _PillChoice extends StatelessWidget {
  const _PillChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? Colors.white : scheme.onSurface;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 7),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = priorityColorFor(label);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : color.withValues(alpha: 0.16),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                priorityIconFor(label),
                size: 20,
                color: selected ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primary, Color.lerp(primary, Colors.black, 0.35) ?? primary],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    label,
                    key: ValueKey(label),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
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
