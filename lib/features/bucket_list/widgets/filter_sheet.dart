import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/item_categories.dart';
import '../bloc/bucket_list_cubit.dart';

/// Bottom sheet for choosing category and priority filters. Country/state
/// filtering is intentionally left for a later pass once real location
/// data is flowing through the app.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final BucketListFilters initial;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ItemCategory? _category = widget.initial.category;
  late ItemPriority? _priority = widget.initial.priority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.headlineSmall),
              TextButton(
                onPressed: () => setState(() {
                  _category = null;
                  _priority = null;
                }),
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Category', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: ItemCategory.values.map((c) {
              return ChoiceChip(
                label: Text(c.label),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = _category == c ? null : c),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Priority', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: ItemPriority.values.map((p) {
              return ChoiceChip(
                label: Text(p.label),
                selected: _priority == p,
                onSelected: (_) => setState(() => _priority = _priority == p ? null : p),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(
                BucketListFilters(category: _category, priority: _priority),
              ),
              child: const Text('Apply filters'),
            ),
          ),
        ],
      ),
    );
  }
}
