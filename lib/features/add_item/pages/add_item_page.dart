import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/item_categories.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../bloc/add_item_cubit.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key, this.itemId});

  final String? itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddItemCubit(
        context.read<BucketListRepository>(),
        existingId: itemId,
      ),
      child: _AddItemView(isEditing: itemId != null),
    );
  }
}

class _AddItemView extends StatelessWidget {
  const _AddItemView({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit item' : 'Add to your list')),
      body: BlocConsumer<AddItemCubit, AddItemState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.status == AddItemStatus.saved) {
            context.pop();
          } else if (state.status == AddItemStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Something went wrong.')),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AddItemCubit>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl,
            ),
            children: [
              TextFormField(
                initialValue: state.title,
                onChanged: cubit.titleChanged,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                initialValue: state.description,
                onChanged: cubit.descriptionChanged,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: ItemCategory.values.map((c) {
                  return ChoiceChip(
                    label: Text(c.label),
                    selected: state.category == c,
                    onSelected: (_) => cubit.categoryChanged(c),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Priority', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: ItemPriority.values.map((p) {
                  return ChoiceChip(
                    label: Text(p.label),
                    selected: state.priority == p,
                    onSelected: (_) => cubit.priorityChanged(p),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: AppColors.itemPalette.entries.map((entry) {
                  final selected = state.color == entry.key;
                  return GestureDetector(
                    onTap: () => cubit.colorChanged(entry.key),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                            : null,
                      ),
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Location (optional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: state.country,
                onChanged: cubit.countryChanged,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: state.state,
                onChanged: cubit.stateChanged,
                decoration: const InputDecoration(labelText: 'State / region'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: state.city,
                onChanged: cubit.cityChanged,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: state.place,
                onChanged: cubit.placeChanged,
                decoration: const InputDecoration(labelText: 'Specific place'),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(state.targetDate == null
                    ? 'Target date (optional)'
                    : DateFormat('MMMM d, y').format(state.targetDate!)),
                trailing: state.targetDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => cubit.targetDateChanged(null),
                      )
                    : const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.targetDate ?? DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) cubit.targetDateChanged(picked);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: state.canSave && state.status != AddItemStatus.saving
                    ? cubit.save
                    : null,
                child: state.status == AddItemStatus.saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Save changes' : 'Add to bucket list'),
              ),
            ],
          );
        },
      ),
    );
  }
}
