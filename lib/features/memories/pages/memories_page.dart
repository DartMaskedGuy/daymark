// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../../app/theme/app_colors.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../core/extensions/date_x.dart';
// import '../../../data/repositories/bucket_list_repository.dart';
// import '../../bucket_list/widgets/empty_state.dart';
// import '../bloc/memories_cubit.dart';

// class MemoriesPage extends StatelessWidget {
//   const MemoriesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => MemoriesCubit(context.read<BucketListRepository>()),
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Memories')),
//         body: BlocBuilder<MemoriesCubit, MemoriesState>(
//           builder: (context, state) {
//             if (state.status == MemoriesStatus.loading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (state.items.isEmpty) {
//               return const EmptyState(
//                 icon: Icons.auto_stories_outlined,
//                 title: 'No memories yet.',
//                 message: 'Complete something and save the moment.',
//               );
//             }
//             return GridView.builder(
//               padding: const EdgeInsets.all(AppSpacing.md),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: AppSpacing.sm,
//                 crossAxisSpacing: AppSpacing.sm,
//                 childAspectRatio: 0.85,
//               ),
//               itemCount: state.items.length,
//               itemBuilder: (context, index) {
//                 final item = state.items[index];
//                 final accent = AppColors.fromKey(item.color);
//                 return Card(
//                   clipBehavior: Clip.antiAlias,
//                   child: InkWell(
//                     onTap: () => context.push('/bucket-list/${item.id}'),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Container(
//                             width: double.infinity,
//                             color: accent.withValues(alpha: 0.15),
//                             child: Icon(Icons.photo_outlined, color: accent, size: 32),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(AppSpacing.sm),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.title,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: Theme.of(context).textTheme.titleMedium,
//                               ),
//                               Text(
//                                 item.completedAt?.relativeOrFormatted ?? '',
//                                 style: Theme.of(context).textTheme.labelSmall,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
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
import '../../../core/extensions/date_x.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../bucket_list/widgets/empty_state.dart';
import '../bloc/memories_cubit.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MemoriesCubit(
        context.read<BucketListRepository>(),
        context.read<MediaRepository>(),
        context.read<MemoryRepository>(),
      ),
      child: const _MemoriesView(),
    );
  }
}

class _MemoriesView extends StatelessWidget {
  const _MemoriesView();

  Future<void> _openMemory(BuildContext context, String itemId) async {
    await context.push('/memory/$itemId');
    if (context.mounted) context.read<MemoriesCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memories')),
      body: BlocBuilder<MemoriesCubit, MemoriesState>(
        builder: (context, state) {
          if (state.status == MemoriesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.entries.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'No memories yet.',
              message: 'Complete something and save the moment.',
            );
          }

          final groups = _groupByMonth(state.entries);

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.xxl,
            ),
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final group = groups[groupIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      group.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (var i = 0; i < group.entries.length; i++)
                    _TimelineRow(
                      entry: group.entries[i],
                      isLast: i == group.entries.length - 1,
                      onTap: () =>
                          _openMemory(context, group.entries[i].item.id),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<_MonthGroup> _groupByMonth(List<MemoryEntry> entries) {
    final groups = <_MonthGroup>[];
    for (final entry in entries) {
      final date = entry.item.completedAt ?? DateTime.now();
      final label = DateFormat('MMMM y').format(date);
      if (groups.isNotEmpty && groups.last.label == label) {
        groups.last.entries.add(entry);
      } else {
        groups.add(_MonthGroup(label: label, entries: [entry]));
      }
    }
    return groups;
  }
}

class _MonthGroup {
  _MonthGroup({required this.label, required this.entries});
  final String label;
  final List<MemoryEntry> entries;
}

/// One row of the timeline: a node (lead photo, or a colored icon when
/// there isn't one yet) connected to the next row by a dashed vertical
/// line — the same "path connecting your moments" idea as the dashed
/// trail in Home's stats strip, continued down through time here instead
/// of across a row of numbers.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  final MemoryEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  static const double _nodeSize = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.fromKey(entry.item.color);
    final trailColor =
        theme.dividerTheme.color ??
        theme.colorScheme.outline.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _nodeSize,
              child: Column(
                children: [
                  _Node(entry: entry, accent: accent, size: _nodeSize),
                  if (!isLast)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: CustomPaint(
                          size: const Size(1, double.infinity),
                          painter: _DashedVerticalPainter(color: trailColor),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MemoryCard(entry: entry, accent: accent, onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.entry, required this.accent, required this.size});

  final MemoryEntry entry;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = entry.leadPhoto;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent, width: 2),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: photo != null
            ? Image.file(
                File(photo.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: accent.withValues(alpha: 0.15),
                  child: Icon(
                    _categoryIcon(entry.item.category),
                    color: accent,
                    size: 18,
                  ),
                ),
              )
            : ColoredBox(
                color: accent.withValues(alpha: 0.15),
                child: Icon(
                  _categoryIcon(entry.item.category),
                  color: accent,
                  size: 18,
                ),
              ),
      ),
    );
  }

  IconData _categoryIcon(String category) => switch (category) {
    'Travel' => Icons.flight_takeoff,
    'Experience' => Icons.auto_awesome,
    'Personal' => Icons.person_outline,
    'Career' => Icons.work_outline,
    'Education' => Icons.school_outlined,
    'Adventure' => Icons.terrain,
    _ => Icons.star_outline,
  };
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.entry,
    required this.accent,
    required this.onTap,
  });

  final MemoryEntry entry;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entry.item;
    final location = [
      item.city,
      item.country,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    item.completedAt?.relativeOrFormatted ?? '',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 13,
                      color: theme.textTheme.bodyMedium?.color,
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
              if (entry.notesPreview != null &&
                  entry.notesPreview!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  entry.notesPreview!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (entry.mediaCount > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.mediaCount} attached',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedVerticalPainter extends CustomPainter {
  _DashedVerticalPainter({required this.color});

  final Color color;
  static const double _dashHeight = 4;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final x = size.width / 2;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + _dashHeight), paint);
      y += _dashHeight + _gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedVerticalPainter oldDelegate) =>
      oldDelegate.color != color;
}
