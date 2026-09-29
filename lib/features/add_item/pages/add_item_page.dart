// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import '../../../app/theme/app_colors.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../core/constants/item_categories.dart';
// import '../../../data/repositories/bucket_list_repository.dart';
// import '../../../data/repositories/media_repository.dart';
// import '../bloc/add_item_cubit.dart';

// class AddItemPage extends StatelessWidget {
//   const AddItemPage({super.key, this.itemId});

//   final String? itemId;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AddItemCubit(
//         context.read<BucketListRepository>(),
//         context.read<MediaRepository>(),
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
//         listenWhen: (a, b) =>
//             a.status != b.status || a.errorMessage != b.errorMessage,
//         listener: (context, state) {
//           if (state.status == AddItemStatus.saved) {
//             context.pop();
//           } else if (state.errorMessage != null) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
//           }
//         },
//         builder: (context, state) {
//           final cubit = context.read<AddItemCubit>();
//           return ListView(
//             padding: const EdgeInsets.fromLTRB(
//               AppSpacing.md,
//               AppSpacing.md,
//               AppSpacing.md,
//               AppSpacing.xxl,
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
//                 decoration: const InputDecoration(
//                   labelText: 'Description (optional)',
//                 ),
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
//                             ? Border.all(
//                                 color: Theme.of(context).colorScheme.onSurface,
//                                 width: 2,
//                               )
//                             : null,
//                       ),
//                       child: selected
//                           ? const Icon(
//                               Icons.check,
//                               color: Colors.white,
//                               size: 18,
//                             )
//                           : null,
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: AppSpacing.lg),
//               Text(
//                 'Photos (optional)',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               _PhotosGrid(state: state, cubit: cubit),
//               const SizedBox(height: AppSpacing.lg),
//               Text(
//                 'Location (optional)',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
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
//                 title: Text(
//                   state.targetDate == null
//                       ? 'Target date (optional)'
//                       : DateFormat('MMMM d, y').format(state.targetDate!),
//                 ),
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
//                         width: 20,
//                         height: 20,
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

// /// Thumbnail grid for the item's photos: already-saved media first (when
// /// editing), then any picked-but-not-yet-saved images (when creating a new
// /// item), plus a trailing tile to pick more.
// class _PhotosGrid extends StatelessWidget {
//   const _PhotosGrid({required this.state, required this.cubit});

//   final AddItemState state;
//   final AddItemCubit cubit;

//   static const double _tileSize = 84;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Wrap(
//       spacing: AppSpacing.sm,
//       runSpacing: AppSpacing.sm,
//       children: [
//         for (final media in state.existingMedia)
//           _Thumbnail(
//             path: media.path,
//             onRemove: () => cubit.removeExistingMedia(media.id),
//           ),
//         for (final path in state.pendingImagePaths)
//           _Thumbnail(
//             path: path,
//             onRemove: () => cubit.removePendingImage(path),
//           ),
//         GestureDetector(
//           onTap: cubit.pickImages,
//           child: Container(
//             width: _tileSize,
//             height: _tileSize,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: theme.colorScheme.outline.withValues(alpha: 0.4),
//               ),
//             ),
//             child: Icon(
//               Icons.add_photo_alternate_outlined,
//               color: theme.colorScheme.primary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _Thumbnail extends StatelessWidget {
//   const _Thumbnail({required this.path, required this.onRemove});

//   final String path;
//   final VoidCallback onRemove;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: _PhotosGrid._tileSize,
//       height: _PhotosGrid._tileSize,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.file(
//               File(path),
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => Container(
//                 color: Theme.of(context).colorScheme.surfaceContainerHighest,
//                 child: const Icon(Icons.broken_image_outlined),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 4,
//             right: 4,
//             child: GestureDetector(
//               onTap: onRemove,
//               child: Container(
//                 padding: const EdgeInsets.all(2),
//                 decoration: const BoxDecoration(
//                   color: Colors.black54,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.close, size: 14, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _s(Object? v) => v?.toString().trim() ?? '';

Color _accentOf(BuildContext context, AddItemState state) =>
    AppColors.itemPalette[state.color] ?? Theme.of(context).colorScheme.primary;

IconData _categoryIcon(String name) {
  final n = name.toLowerCase();
  bool has(List<String> keys) => keys.any(n.contains);
  if (has(['travel', 'adventure', 'trip', 'explore'])) {
    return Icons.flight_takeoff_rounded;
  }
  if (has(['food', 'eat', 'cook', 'dining'])) return Icons.restaurant_rounded;
  if (has(['learn', 'skill', 'educat', 'study'])) return Icons.school_rounded;
  if (has(['career', 'work', 'business'])) return Icons.work_rounded;
  if (has(['health', 'fitness', 'sport'])) return Icons.fitness_center_rounded;
  if (has(['creat', 'art', 'music'])) return Icons.palette_rounded;
  if (has(['money', 'financ', 'save'])) return Icons.savings_rounded;
  if (has(['relation', 'family', 'social', 'friend'])) {
    return Icons.favorite_rounded;
  }
  if (has(['experience', 'fun'])) return Icons.auto_awesome_rounded;
  return Icons.star_rounded;
}

const _priorityIcons = <IconData>[
  Icons.spa_rounded,
  Icons.bolt_rounded,
  Icons.local_fire_department_rounded,
];

IconData _priorityIcon(int index) =>
    _priorityIcons[index.clamp(0, _priorityIcons.length - 1)];

String _countdown(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final days = DateTime(
    date.year,
    date.month,
    date.day,
  ).difference(today).inDays;
  if (days < 0) return 'Date has passed';
  if (days == 0) return 'That\'s today!';
  if (days == 1) return 'Tomorrow';
  if (days < 60) return 'In $days days';
  if (days < 700) return 'In about ${(days / 30).round()} months';
  return 'In about ${(days / 365).toStringAsFixed(1)} years';
}

Color _darken(Color c, [double amount = 0.4]) =>
    Color.lerp(c, Colors.black, amount) ?? c;

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class _AddItemView extends StatelessWidget {
  const _AddItemView({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddItemCubit, AddItemState>(
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
        final theme = Theme.of(context);
        final accent = _accentOf(context, state);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              isEditing ? 'Edit dream' : 'New dream',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          bottomNavigationBar: _SaveBar(
            state: state,
            accent: accent,
            isEditing: isEditing,
            onSave: cubit.save,
          ),
          body: Stack(
            children: [
              // Ambient glow that follows the chosen colour.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 420,
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent.withValues(alpha: 0.28),
                          accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  children: [
                    _Reveal(
                      index: 0,
                      child: _PreviewCard(state: state, accent: accent),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Reveal(
                      index: 1,
                      child: _Section(
                        icon: Icons.edit_note_rounded,
                        title: 'The dream',
                        accent: accent,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: state.title,
                              onChanged: cubit.titleChanged,
                              textCapitalization: TextCapitalization.sentences,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: _bareDecoration(
                                context,
                                hint: 'What do you want to experience?',
                                hintStyle: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Divider(
                              height: 20,
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                            TextFormField(
                              initialValue: state.description,
                              onChanged: cubit.descriptionChanged,
                              minLines: 2,
                              maxLines: 5,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: _bareDecoration(
                                context,
                                hint: 'Paint the picture… why does it matter?',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Reveal(
                      index: 2,
                      child: _Section(
                        icon: Icons.category_rounded,
                        title: 'Category',
                        accent: accent,
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final c in ItemCategory.values)
                              _PillChoice(
                                label: c.label,
                                icon: _categoryIcon(c.name),
                                selected: state.category == c,
                                accent: accent,
                                onTap: () => cubit.categoryChanged(c),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Reveal(
                      index: 3,
                      child: _Section(
                        icon: Icons.flag_rounded,
                        title: 'Priority',
                        accent: accent,
                        child: _PrioritySelector(
                          state: state,
                          cubit: cubit,
                          accent: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Reveal(
                      index: 4,
                      child: _Section(
                        icon: Icons.palette_rounded,
                        title: 'Colour',
                        accent: accent,
                        child: Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            for (final entry in AppColors.itemPalette.entries)
                              _Swatch(
                                color: entry.value,
                                selected: state.color == entry.key,
                                onTap: () => cubit.colorChanged(entry.key),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Reveal(
                      index: 5,
                      child: _Section(
                        icon: Icons.photo_library_rounded,
                        title: 'Moodboard',
                        optional: true,
                        accent: accent,
                        child: _PhotosStrip(
                          state: state,
                          cubit: cubit,
                          accent: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Reveal(
                      index: 6,
                      child: _Section(
                        icon: Icons.place_rounded,
                        title: 'Where',
                        optional: true,
                        accent: accent,
                        child: _LocationFields(state: state, cubit: cubit),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Reveal(
                      index: 7,
                      child: _Section(
                        icon: Icons.event_rounded,
                        title: 'When',
                        optional: true,
                        accent: accent,
                        child: _DateTile(
                          state: state,
                          cubit: cubit,
                          accent: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

InputDecoration _bareDecoration(
  BuildContext context, {
  required String hint,
  TextStyle? hintStyle,
  IconData? icon,
  String? label,
}) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    labelText: label,
    hintStyle:
        hintStyle ??
        TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.55)),
    prefixIcon: icon == null
        ? null
        : Icon(icon, size: 20, color: scheme.onSurfaceVariant),
    filled: false,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(
      horizontal: icon == null ? 0 : 4,
      vertical: 10,
    ),
    isDense: true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Entrance animation
// ─────────────────────────────────────────────────────────────────────────────

class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live preview hero card
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.state, required this.accent});

  final AddItemState state;
  final Color accent;

  String? get _coverPath {
    if (state.existingMedia.isNotEmpty) return state.existingMedia.first.path;
    if (state.pendingImagePaths.isNotEmpty)
      return state.pendingImagePaths.first;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _s(state.title);
    final ItemCategory? category = state.category;
    final ItemPriority? priority = state.priority;
    final DateTime? date = state.targetDate;
    final location = [
      _s(state.place),
      _s(state.city),
      _s(state.state),
      _s(state.country),
    ].where((e) => e.isNotEmpty).take(2).join(', ');
    final cover = _coverPath;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      height: 224,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, _darken(accent, 0.45)],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.4),
            blurRadius: 36,
            offset: const Offset(0, 18),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cover != null)
              Image.file(
                File(cover),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            // Decorative orbs for depth.
            Positioned(
              right: -40,
              top: -40,
              child: _Orb(size: 160, alpha: 0.14),
            ),
            Positioned(
              left: -30,
              bottom: -60,
              child: _Orb(size: 150, alpha: 0.08),
            ),
            // Readability scrim.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: cover != null ? 0.15 : 0.0),
                    Colors.black.withValues(alpha: cover != null ? 0.7 : 0.35),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlassTag(
                        icon: category == null
                            ? Icons.auto_awesome_rounded
                            : _categoryIcon(category.name),
                        label: category?.label ?? 'Category',
                      ),
                      const SizedBox(width: 8),
                      if (priority != null)
                        _GlassTag(
                          icon: _priorityIcon(priority.index),
                          label: priority.label,
                        ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      title.isEmpty ? 'Your next big dream' : title,
                      key: ValueKey(title.isEmpty),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white.withValues(
                          alpha: title.isEmpty ? 0.6 : 1,
                        ),
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (location.isNotEmpty) ...[
                        const Icon(
                          Icons.place_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (location.isNotEmpty && date != null)
                        const SizedBox(width: 14),
                      if (date != null) ...[
                        const Icon(
                          Icons.event_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM y').format(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (location.isEmpty && date == null)
                        Text(
                          'Live preview',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _GlassTag extends StatelessWidget {
  const _GlassTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section container
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.accent,
    required this.child,
    this.optional = false,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 17, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              if (optional) ...[
                const Spacer(),
                Text(
                  'OPTIONAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Choices
// ─────────────────────────────────────────────────────────────────────────────

class _PillChoice extends StatelessWidget {
  const _PillChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color accent;
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
              ? accent
              : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
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

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.state,
    required this.cubit,
    required this.accent,
  });

  final AddItemState state;
  final AddItemCubit cubit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final p in ItemPriority.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  cubit.priorityChanged(p);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: state.priority == p ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: state.priority == p
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.38),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                              spreadRadius: -3,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _priorityIcon(p.index),
                        size: 17,
                        color: state.priority == p
                            ? Colors.white
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          p.label,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: state.priority == p
                                    ? Colors.white
                                    : scheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        width: 46,
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? ring : Colors.transparent,
            width: 2,
          ),
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 260),
          scale: selected ? 1 : 0.86,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, _darken(color, 0.25)],
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photos
// ─────────────────────────────────────────────────────────────────────────────

/// Horizontal moodboard strip: saved media first (when editing), then picked
/// but unsaved images, plus a trailing tile to pick more. The first photo is
/// used as the cover on the preview card.
class _PhotosStrip extends StatelessWidget {
  const _PhotosStrip({
    required this.state,
    required this.cubit,
    required this.accent,
  });

  final AddItemState state;
  final AddItemCubit cubit;
  final Color accent;

  static const double _tile = 104;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var i = 0;
    final tiles = <Widget>[
      for (final media in state.existingMedia)
        _Thumbnail(
          path: media.path,
          size: _tile,
          isCover: i++ == 0,
          onRemove: () => cubit.removeExistingMedia(media.id),
        ),
      for (final path in state.pendingImagePaths)
        _Thumbnail(
          path: path,
          size: _tile,
          isCover: i++ == 0,
          onRemove: () => cubit.removePendingImage(path),
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final t in tiles) ...[t, const SizedBox(width: 10)],
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              cubit.pickImages();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: _tile,
              height: _tile,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    color: accent,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tiles.isEmpty ? 'Add photos' : 'Add more',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.path,
    required this.size,
    required this.onRemove,
    this.isCover = false,
  });

  final String path;
  final double size;
  final VoidCallback onRemove;
  final bool isCover;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: scheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          if (isCover)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'COVER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location
// ─────────────────────────────────────────────────────────────────────────────

class _LocationFields extends StatelessWidget {
  const _LocationFields({required this.state, required this.cubit});

  final AddItemState state;
  final AddItemCubit cubit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Divider(
      height: 1,
      indent: 44,
      color: scheme.outlineVariant.withValues(alpha: 0.5),
    );

    Widget field({
      required String? initial,
      required ValueChanged<String> onChanged,
      required IconData icon,
      required String hint,
    }) {
      return TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
        decoration: _bareDecoration(context, hint: hint, icon: icon),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          field(
            initial: state.country,
            onChanged: cubit.countryChanged,
            icon: Icons.public_rounded,
            hint: 'Country',
          ),
          divider,
          field(
            initial: state.state,
            onChanged: cubit.stateChanged,
            icon: Icons.map_outlined,
            hint: 'State / region',
          ),
          divider,
          field(
            initial: state.city,
            onChanged: cubit.cityChanged,
            icon: Icons.location_city_rounded,
            hint: 'City',
          ),
          divider,
          field(
            initial: state.place,
            onChanged: cubit.placeChanged,
            icon: Icons.push_pin_outlined,
            hint: 'Specific place',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Target date
// ─────────────────────────────────────────────────────────────────────────────

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.state,
    required this.cubit,
    required this.accent,
  });

  final AddItemState state;
  final AddItemCubit cubit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final DateTime? date = state.targetDate;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        );
        if (picked != null) cubit.targetDateChanged(picked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: date == null
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
              : accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: date == null
                ? Colors.transparent
                : accent.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              date == null
                  ? Icons.calendar_today_rounded
                  : Icons.event_available_rounded,
              color: date == null ? scheme.onSurfaceVariant : accent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date == null
                        ? 'Set a target date'
                        : DateFormat('EEEE, MMMM d, y').format(date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date == null
                        ? 'A deadline makes dreams real'
                        : _countdown(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: date == null ? scheme.onSurfaceVariant : accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => cubit.targetDateChanged(null),
              )
            else
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky save bar
// ─────────────────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.state,
    required this.accent,
    required this.isEditing,
    required this.onSave,
  });

  final AddItemState state;
  final Color accent;
  final bool isEditing;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final saving = state.status == AddItemStatus.saving;
    final enabled = state.canSave && !saving;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        12,
        AppSpacing.md,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: enabled || saving
              ? LinearGradient(colors: [accent, _darken(accent, 0.35)])
              : null,
          color: enabled || saving ? null : scheme.surfaceContainerHighest,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                    spreadRadius: -6,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: enabled
                ? () {
                    HapticFeedback.mediumImpact();
                    onSave();
                  }
                : null,
            child: Center(
              child: saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEditing
                              ? Icons.check_rounded
                              : Icons.auto_awesome_rounded,
                          size: 20,
                          color: enabled
                              ? Colors.white
                              : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEditing ? 'Save changes' : 'Add to bucket list',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: enabled
                                ? Colors.white
                                : scheme.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
