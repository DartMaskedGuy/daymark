// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import '../../../app/theme/app_colors.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../core/constants/item_categories.dart';
// import '../../../data/repositories/bucket_list_repository.dart';
// import '../bloc/add_item_cubit.dart';

// class AddItemPage extends StatelessWidget {
//   const AddItemPage({super.key, this.itemId});

//   final String? itemId;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AddItemCubit(
//         context.read<BucketListRepository>(),
//         existingId: itemId,
//       ),
//       child: _AddItemView(isEditing: itemId != null),
//     );
//   }
// }

// class _AddItemView extends StatelessWidget {
//   const _AddItemView({required this.isEditing});

//   final bool isEditing;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(isEditing ? 'Edit item' : 'Add to your list')),
//       body: BlocConsumer<AddItemCubit, AddItemState>(
//         listenWhen: (a, b) => a.status != b.status,
//         listener: (context, state) {
//           if (state.status == AddItemStatus.saved) {
//             context.pop();
//           } else if (state.status == AddItemStatus.error) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage ?? 'Something went wrong.')),
//             );
//           }
//         },
//         builder: (context, state) {
//           final cubit = context.read<AddItemCubit>();
//           return ListView(
//             padding: const EdgeInsets.fromLTRB(
//               AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl,
//             ),
//             children: [
//               TextFormField(
//                 initialValue: state.title,
//                 onChanged: cubit.titleChanged,
//                 decoration: const InputDecoration(labelText: 'Title'),
//                 textCapitalization: TextCapitalization.sentences,
//               ),
//               const SizedBox(height: AppSpacing.md),
//               TextFormField(
//                 initialValue: state.description,
//                 onChanged: cubit.descriptionChanged,
//                 decoration: const InputDecoration(labelText: 'Description (optional)'),
//                 minLines: 2,
//                 maxLines: 5,
//                 textCapitalization: TextCapitalization.sentences,
//               ),
//               const SizedBox(height: AppSpacing.lg),
//               Text('Category', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: AppSpacing.sm),
//               Wrap(
//                 spacing: AppSpacing.sm,
//                 children: ItemCategory.values.map((c) {
//                   return ChoiceChip(
//                     label: Text(c.label),
//                     selected: state.category == c,
//                     onSelected: (_) => cubit.categoryChanged(c),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: AppSpacing.lg),
//               Text('Priority', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: AppSpacing.sm),
//               Wrap(
//                 spacing: AppSpacing.sm,
//                 children: ItemPriority.values.map((p) {
//                   return ChoiceChip(
//                     label: Text(p.label),
//                     selected: state.priority == p,
//                     onSelected: (_) => cubit.priorityChanged(p),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: AppSpacing.lg),
//               Text('Color', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: AppSpacing.sm),
//               Wrap(
//                 spacing: AppSpacing.sm,
//                 runSpacing: AppSpacing.sm,
//                 children: AppColors.itemPalette.entries.map((entry) {
//                   final selected = state.color == entry.key;
//                   return GestureDetector(
//                     onTap: () => cubit.colorChanged(entry.key),
//                     child: Container(
//                       width: 36,
//                       height: 36,
//                       decoration: BoxDecoration(
//                         color: entry.value,
//                         shape: BoxShape.circle,
//                         border: selected
//                             ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
//                             : null,
//                       ),
//                       child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: AppSpacing.lg),
//               Text('Location (optional)', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: AppSpacing.sm),
//               TextFormField(
//                 initialValue: state.country,
//                 onChanged: cubit.countryChanged,
//                 decoration: const InputDecoration(labelText: 'Country'),
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               TextFormField(
//                 initialValue: state.state,
//                 onChanged: cubit.stateChanged,
//                 decoration: const InputDecoration(labelText: 'State / region'),
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               TextFormField(
//                 initialValue: state.city,
//                 onChanged: cubit.cityChanged,
//                 decoration: const InputDecoration(labelText: 'City'),
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               TextFormField(
//                 initialValue: state.place,
//                 onChanged: cubit.placeChanged,
//                 decoration: const InputDecoration(labelText: 'Specific place'),
//               ),
//               const SizedBox(height: AppSpacing.lg),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: Text(state.targetDate == null
//                     ? 'Target date (optional)'
//                     : DateFormat('MMMM d, y').format(state.targetDate!)),
//                 trailing: state.targetDate != null
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () => cubit.targetDateChanged(null),
//                       )
//                     : const Icon(Icons.calendar_today_outlined),
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: state.targetDate ?? DateTime.now(),
//                     firstDate: DateTime(1950),
//                     lastDate: DateTime(2100),
//                   );
//                   if (picked != null) cubit.targetDateChanged(picked);
//                 },
//               ),
//               const SizedBox(height: AppSpacing.xl),
//               FilledButton(
//                 onPressed: state.canSave && state.status != AddItemStatus.saving
//                     ? cubit.save
//                     : null,
//                 child: state.status == AddItemStatus.saving
//                     ? const SizedBox(
//                         width: 20, height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : Text(isEditing ? 'Save changes' : 'Add to bucket list'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/item_categories.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../bloc/add_item_cubit.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key, this.itemId});

  final String? itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddItemCubit(
        context.read<BucketListRepository>(),
        context.read<MediaRepository>(),
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
        listenWhen: (a, b) =>
            a.status != b.status || a.errorMessage != b.errorMessage,
        listener: (context, state) {
          if (state.status == AddItemStatus.saved) {
            context.pop();
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<AddItemCubit>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
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
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
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
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 2,
                              )
                            : null,
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Photos (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PhotosGrid(state: state, cubit: cubit),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Location (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                title: Text(
                  state.targetDate == null
                      ? 'Target date (optional)'
                      : DateFormat('MMMM d, y').format(state.targetDate!),
                ),
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
                        width: 20,
                        height: 20,
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

/// Thumbnail grid for the item's photos: already-saved media first (when
/// editing), then any picked-but-not-yet-saved images (when creating a new
/// item), plus a trailing tile to pick more.
class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid({required this.state, required this.cubit});

  final AddItemState state;
  final AddItemCubit cubit;

  static const double _tileSize = 84;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final media in state.existingMedia)
          _Thumbnail(
            path: media.path,
            onRemove: () => cubit.removeExistingMedia(media.id),
          ),
        for (final path in state.pendingImagePaths)
          _Thumbnail(
            path: path,
            onRemove: () => cubit.removePendingImage(path),
          ),
        GestureDetector(
          onTap: cubit.pickImages,
          child: Container(
            width: _tileSize,
            height: _tileSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _PhotosGrid._tileSize,
      height: _PhotosGrid._tileSize,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
