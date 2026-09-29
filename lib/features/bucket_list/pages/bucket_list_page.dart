// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../core/constants/item_categories.dart';
// import '../../../data/repositories/bucket_list_repository.dart';
// import '../bloc/bucket_list_cubit.dart';
// import '../widgets/bucket_list_item_card.dart';
// import '../widgets/empty_state.dart';
// import '../widgets/filter_sheet.dart';

// class BucketListPage extends StatelessWidget {
//   const BucketListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           BucketListCubit(context.read<BucketListRepository>()),
//       child: const _BucketListView(),
//     );
//   }
// }

// class _BucketListView extends StatelessWidget {
//   const _BucketListView();

//   Future<void> _openFilters(
//     BuildContext context,
//     BucketListFilters current,
//   ) async {
//     final cubit = context.read<BucketListCubit>();
//     final result = await showModalBottomSheet<BucketListFilters>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => FilterSheet(initial: current),
//     );
//     if (result != null) cubit.applyFilters(result);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       body: SafeArea(
//         // top: false,
//         // bottom: ,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 AppSpacing.md,
//                 AppSpacing.sm,
//                 AppSpacing.md,
//                 0,
//               ),
//               child: BlocBuilder<BucketListCubit, BucketListState>(
//                 builder: (context, state) {
//                   final total = state.allItems.length;
//                   final completed = state.allItems
//                       .where((i) => i.isCompleted)
//                       .length;
//                   return Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Bucket List',
//                               style: theme.textTheme.displaySmall?.copyWith(
//                                 fontSize: 28,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               total == 0
//                                   ? 'Nothing on your list yet'
//                                   : '$completed lived • ${total - completed} ahead',
//                               style: theme.textTheme.bodyMedium,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: AppSpacing.sm),
//                       IconButton.filledTonal(
//                         icon: Badge(
//                           isLabelVisible: !state.filters.isEmpty,
//                           child: const Icon(Icons.tune),
//                         ),
//                         onPressed: () => _openFilters(context, state.filters),
//                       ),
//                       const SizedBox(width: AppSpacing.xs),
//                       PopupMenuButton<SortOption>(
//                         icon: const Icon(Icons.sort),
//                         onSelected: (v) =>
//                             context.read<BucketListCubit>().changeSort(v),
//                         itemBuilder: (_) => const [
//                           PopupMenuItem(
//                             value: SortOption.recentlyAdded,
//                             child: Text('Recently added'),
//                           ),
//                           PopupMenuItem(
//                             value: SortOption.oldestAdded,
//                             child: Text('Oldest added'),
//                           ),
//                           PopupMenuItem(
//                             value: SortOption.alphabetical,
//                             child: Text('Alphabetical'),
//                           ),
//                           PopupMenuItem(
//                             value: SortOption.priority,
//                             child: Text('Priority'),
//                           ),
//                           PopupMenuItem(
//                             value: SortOption.targetDate,
//                             child: Text('Target date'),
//                           ),
//                           PopupMenuItem(
//                             value: SortOption.recentlyCompleted,
//                             child: Text('Recently completed'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             BlocBuilder<BucketListCubit, BucketListState>(
//               buildWhen: (a, b) => a.filters != b.filters,
//               builder: (context, state) {
//                 if (state.filters.isEmpty) return const SizedBox.shrink();
//                 final cubit = context.read<BucketListCubit>();
//                 return Padding(
//                   padding: const EdgeInsets.fromLTRB(
//                     AppSpacing.md,
//                     AppSpacing.sm,
//                     AppSpacing.md,
//                     0,
//                   ),
//                   child: SizedBox(
//                     height: 32,
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       children: [
//                         if (state.filters.category != null)
//                           _FilterChip(
//                             label: state.filters.category!.label,
//                             onRemoved: () => cubit.applyFilters(
//                               state.filters.copyWith(clearCategory: true),
//                             ),
//                           ),
//                         if (state.filters.priority != null)
//                           _FilterChip(
//                             label: '${state.filters.priority!.label} priority',
//                             onRemoved: () => cubit.applyFilters(
//                               state.filters.copyWith(clearPriority: true),
//                             ),
//                           ),
//                         TextButton(
//                           onPressed: cubit.clearFilters,
//                           child: const Text('Clear all'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 AppSpacing.md,
//                 AppSpacing.md,
//                 AppSpacing.md,
//                 0,
//               ),
//               child: _SearchField(
//                 onChanged: (v) => context.read<BucketListCubit>().search(v),
//               ),
//             ),
//             const SizedBox(height: AppSpacing.sm),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
//               child: BlocBuilder<BucketListCubit, BucketListState>(
//                 buildWhen: (a, b) => a.tab != b.tab,
//                 builder: (context, state) {
//                   return _TabPills(
//                     selected: state.tab,
//                     onChanged: (tab) =>
//                         context.read<BucketListCubit>().selectTab(tab),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: AppSpacing.sm),
//             Expanded(
//               child: BlocConsumer<BucketListCubit, BucketListState>(
//                 listenWhen: (a, b) =>
//                     a.errorMessage != b.errorMessage && b.errorMessage != null,
//                 listener: (context, state) {
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
//                 },
//                 builder: (context, state) {
//                   if (state.status == BucketListStatus.loading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final items = state.visibleItems;
//                   if (items.isEmpty) {
//                     return EmptyState(
//                       icon: Icons.flag_outlined,
//                       title: state.tab == BucketListFilterTab.completed
//                           ? 'Your story is just beginning.'
//                           : 'Nothing here yet.',
//                       message: state.tab == BucketListFilterTab.completed
//                           ? 'Complete your first bucket-list item and it will appear here.'
//                           : 'Your next great experience starts with one idea.',
//                       actionLabel: state.tab == BucketListFilterTab.completed
//                           ? null
//                           : 'Add something',
//                       onAction: state.tab == BucketListFilterTab.completed
//                           ? null
//                           : () => context.push('/bucket-list/add'),
//                     );
//                   }

//                   return ListView.separated(
//                     padding: const EdgeInsets.fromLTRB(
//                       AppSpacing.md,
//                       0,
//                       AppSpacing.md,
//                       96,
//                     ),
//                     itemCount: items.length,
//                     separatorBuilder: (_, __) =>
//                         const SizedBox(height: AppSpacing.sm),
//                     itemBuilder: (context, index) {
//                       final item = items[index];
//                       return BucketListItemCard(
//                         item: item,
//                         onTap: () => context.push('/bucket-list/${item.id}'),
//                         onToggleCompleted: () => context
//                             .read<BucketListCubit>()
//                             .toggleCompleted(item),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsetsGeometry.only(bottom: 80),
//         child: FloatingActionButton.extended(
//           onPressed: () => context.push('/bucket-list/add'),
//           icon: const Icon(Icons.add),
//           label: const Text('Add'),
//         ),
//       ),
//     );
//   }
// }

// class _FilterChip extends StatelessWidget {
//   const _FilterChip({required this.label, required this.onRemoved});

//   final String label;
//   final VoidCallback onRemoved;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: AppSpacing.sm),
//       child: InputChip(
//         label: Text(label),
//         onDeleted: onRemoved,
//         deleteIconColor: Theme.of(context).colorScheme.primary,
//         side: BorderSide.none,
//         backgroundColor: Theme.of(
//           context,
//         ).colorScheme.primary.withValues(alpha: 0.10),
//       ),
//     );
//   }
// }

// /// Rounded pill search field with a clear button, styled to match the
// /// app's tonal-fill input language rather than the default boxy TextField.
// class _SearchField extends StatefulWidget {
//   const _SearchField({required this.onChanged});

//   final ValueChanged<String> onChanged;

//   @override
//   State<_SearchField> createState() => _SearchFieldState();
// }

// class _SearchFieldState extends State<_SearchField> {
//   final _controller = TextEditingController();

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: _controller,
//       onChanged: (v) {
//         setState(() {});
//         widget.onChanged(v);
//       },
//       decoration: InputDecoration(
//         hintText: 'Search your list',
//         prefixIcon: const Icon(Icons.search),
//         suffixIcon: _controller.text.isEmpty
//             ? null
//             : IconButton(
//                 icon: const Icon(Icons.close, size: 18),
//                 onPressed: () {
//                   _controller.clear();
//                   setState(() {});
//                   widget.onChanged('');
//                 },
//               ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(999),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(999),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(999),
//           borderSide: BorderSide(
//             color: Theme.of(context).colorScheme.primary,
//             width: 1.5,
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Custom segmented control with a sliding indicator, echoing the floating
// /// nav bar's pill language instead of the stock Material SegmentedButton.
// class _TabPills extends StatelessWidget {
//   const _TabPills({required this.selected, required this.onChanged});

//   final BucketListFilterTab selected;
//   final ValueChanged<BucketListFilterTab> onChanged;

//   static const _tabs = [
//     (value: BucketListFilterTab.all, label: 'All'),
//     (value: BucketListFilterTab.todo, label: 'To Do'),
//     (value: BucketListFilterTab.completed, label: 'Completed'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final index = _tabs.indexWhere((t) => t.value == selected);

//     return Container(
//       height: 44,
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: theme.dividerTheme.color ?? Colors.transparent,
//         ),
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final segmentWidth = constraints.maxWidth / _tabs.length;
//           return Stack(
//             children: [
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 220),
//                 curve: Curves.easeOutCubic,
//                 left: segmentWidth * index,
//                 width: segmentWidth,
//                 top: 0,
//                 bottom: 0,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary,
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                 ),
//               ),
//               Row(
//                 children: [
//                   for (final tab in _tabs)
//                     Expanded(
//                       child: GestureDetector(
//                         behavior: HitTestBehavior.opaque,
//                         onTap: () => onChanged(tab.value),
//                         child: Center(
//                           child: Text(
//                             tab.label,
//                             style: theme.textTheme.labelSmall?.copyWith(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w700,
//                               color: tab.value == selected
//                                   ? Colors.white
//                                   : theme.textTheme.bodyMedium?.color,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/item_categories.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../bloc/bucket_list_cubit.dart';
import '../widgets/bucket_list_item_card.dart';
import '../widgets/filter_sheet.dart';

Color _darken(Color c, [double amount = 0.4]) =>
    Color.lerp(c, Colors.black, amount) ?? c;

class BucketListPage extends StatelessWidget {
  const BucketListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BucketListCubit(context.read<BucketListRepository>()),
      child: const _BucketListView(),
    );
  }
}

class _BucketListView extends StatelessWidget {
  const _BucketListView();

  Future<void> _openFilters(
    BuildContext context,
    BucketListFilters current,
  ) async {
    final cubit = context.read<BucketListCubit>();
    final result = await showModalBottomSheet<BucketListFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(initial: current),
    );
    if (result != null) cubit.applyFilters(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient glow behind the header.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 360,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withValues(alpha: 0.20),
                      primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: BlocBuilder<BucketListCubit, BucketListState>(
                    builder: (context, state) {
                      final total = state.allItems.length;
                      final completed = state.allItems
                          .where((i) => i.isCompleted)
                          .length;
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bucket List',
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.6,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      total == 0
                                          ? 'Nothing on your list yet'
                                          : 'Your dreams, all in one place',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              _RoundButton(
                                onTap: () =>
                                    _openFilters(context, state.filters),
                                child: Badge(
                                  isLabelVisible: !state.filters.isEmpty,
                                  child: const Icon(Icons.tune_rounded),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              PopupMenuButton<SortOption>(
                                tooltip: 'Sort',
                                offset: const Offset(0, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (v) => context
                                    .read<BucketListCubit>()
                                    .changeSort(v),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: SortOption.recentlyAdded,
                                    child: _MenuRow(
                                      Icons.schedule_rounded,
                                      'Recently added',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SortOption.oldestAdded,
                                    child: _MenuRow(
                                      Icons.history_rounded,
                                      'Oldest added',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SortOption.alphabetical,
                                    child: _MenuRow(
                                      Icons.sort_by_alpha_rounded,
                                      'Alphabetical',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SortOption.priority,
                                    child: _MenuRow(
                                      Icons.local_fire_department_rounded,
                                      'Priority',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SortOption.targetDate,
                                    child: _MenuRow(
                                      Icons.event_rounded,
                                      'Target date',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SortOption.recentlyCompleted,
                                    child: _MenuRow(
                                      Icons.check_circle_rounded,
                                      'Recently completed',
                                    ),
                                  ),
                                ],
                                child: const _RoundButton(
                                  child: Icon(Icons.swap_vert_rounded),
                                ),
                              ),
                            ],
                          ),
                          if (total > 0) ...[
                            const SizedBox(height: AppSpacing.md),
                            _ProgressHero(total: total, completed: completed),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  child: _SearchField(
                    onChanged: (v) => context.read<BucketListCubit>().search(v),
                  ),
                ),
                BlocBuilder<BucketListCubit, BucketListState>(
                  buildWhen: (a, b) => a.filters != b.filters,
                  builder: (context, state) {
                    final cubit = context.read<BucketListCubit>();
                    return AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: state.filters.isEmpty
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.sm,
                                AppSpacing.md,
                                0,
                              ),
                              child: SizedBox(
                                height: 36,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    if (state.filters.category != null)
                                      _ActiveFilterChip(
                                        label: state.filters.category!.label,
                                        onRemoved: () => cubit.applyFilters(
                                          state.filters.copyWith(
                                            clearCategory: true,
                                          ),
                                        ),
                                      ),
                                    if (state.filters.priority != null)
                                      _ActiveFilterChip(
                                        label:
                                            '${state.filters.priority!.label} priority',
                                        onRemoved: () => cubit.applyFilters(
                                          state.filters.copyWith(
                                            clearPriority: true,
                                          ),
                                        ),
                                      ),
                                    TextButton(
                                      onPressed: cubit.clearFilters,
                                      child: const Text('Clear all'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: BlocBuilder<BucketListCubit, BucketListState>(
                    buildWhen: (a, b) =>
                        a.tab != b.tab || a.allItems != b.allItems,
                    builder: (context, state) {
                      final total = state.allItems.length;
                      final done = state.allItems
                          .where((i) => i.isCompleted)
                          .length;
                      return _TabPills(
                        selected: state.tab,
                        counts: {
                          BucketListFilterTab.all: total,
                          BucketListFilterTab.todo: total - done,
                          BucketListFilterTab.completed: done,
                        },
                        onChanged: (tab) {
                          HapticFeedback.selectionClick();
                          context.read<BucketListCubit>().selectTab(tab);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: BlocConsumer<BucketListCubit, BucketListState>(
                    listenWhen: (a, b) =>
                        a.errorMessage != b.errorMessage &&
                        b.errorMessage != null,
                    listener: (context, state) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    },
                    builder: (context, state) {
                      if (state.status == BucketListStatus.loading) {
                        return const _SkeletonList();
                      }

                      final items = state.visibleItems;
                      if (items.isEmpty) {
                        final cubit = context.read<BucketListCubit>();
                        final completedTab =
                            state.tab == BucketListFilterTab.completed;
                        if (!state.filters.isEmpty) {
                          return _EmptyView(
                            icon: Icons.filter_alt_off_rounded,
                            title: 'No matches',
                            message:
                                'Nothing fits those filters. Try loosening them.',
                            actionLabel: 'Clear filters',
                            onAction: cubit.clearFilters,
                          );
                        }
                        return _EmptyView(
                          icon: completedTab
                              ? Icons.emoji_events_rounded
                              : Icons.flag_rounded,
                          title: completedTab
                              ? 'Your story is just beginning.'
                              : 'Nothing here yet.',
                          message: completedTab
                              ? 'Complete your first bucket-list item and it will appear here.'
                              : 'Your next great experience starts with one idea.',
                          actionLabel: completedTab ? null : 'Add something',
                          onAction: completedTab
                              ? null
                              : () => context.push('/bucket-list/add'),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          96,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _ListReveal(
                            key: ValueKey(item.id),
                            index: index,
                            child: BucketListItemCard(
                              item: item,
                              onTap: () =>
                                  context.push('/bucket-list/${item.id}'),
                              onToggleCompleted: () => context
                                  .read<BucketListCubit>()
                                  .toggleCompleted(item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: _AddButton(onTap: () => context.push('/bucket-list/add')),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header pieces
// ─────────────────────────────────────────────────────────────────────────────

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      shape: CircleBorder(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: Center(child: child)),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

/// Gradient summary card with an animated completion ring.
class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.total, required this.completed});

  final int total;
  final int completed;

  String get _message {
    final pct = total == 0 ? 0.0 : completed / total;
    if (completed == 0) return 'Every journey starts with one step.';
    if (pct < 0.5) return 'Momentum is building. Keep going!';
    if (pct < 1) return 'More than halfway there!';
    return 'You lived it all. Time to dream bigger!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final value = total == 0 ? 0.0 : completed / total;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, _darken(primary, 0.45)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.38),
            blurRadius: 30,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: -44,
              child: _Orb(size: 150, alpha: 0.13),
            ),
            Positioned(
              left: -30,
              bottom: -56,
              child: _Orb(size: 130, alpha: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  _ProgressRing(value: value),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIFE PROGRESS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completed of $total lived',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return SizedBox(
          width: 70,
          height: 70,
          child: CustomPaint(
            painter: _RingPainter(t),
            child: Center(
              child: Text(
                '${(t * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Search, filters, tabs
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemoved});

  final String label;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemoved,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close_rounded, size: 14, color: primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded pill search field with a clear button, styled to match the
/// app's tonal-fill input language rather than the default boxy TextField.
class _SearchField extends StatefulWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _controller,
      onChanged: (v) {
        setState(() {});
        widget.onChanged(v);
      },
      decoration: InputDecoration(
        hintText: 'Search your dreams',
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  widget.onChanged('');
                },
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Custom segmented control with a sliding gradient indicator and live counts.
class _TabPills extends StatelessWidget {
  const _TabPills({
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final BucketListFilterTab selected;
  final Map<BucketListFilterTab, int> counts;
  final ValueChanged<BucketListFilterTab> onChanged;

  static const _tabs = [
    (value: BucketListFilterTab.all, label: 'All'),
    (value: BucketListFilterTab.todo, label: 'To Do'),
    (value: BucketListFilterTab.completed, label: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final index = _tabs.indexWhere((t) => t.value == selected);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / _tabs.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: segmentWidth * index,
                width: segmentWidth,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, _darken(scheme.primary, 0.3)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final tab in _tabs)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(tab.value),
                        child: _TabLabel(
                          label: tab.label,
                          count: counts[tab.value] ?? 0,
                          selected: tab.value == selected,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.count,
    required this.selected,
  });

  final String label;
  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? Colors.white : theme.textTheme.bodyMedium?.color;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
              child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.25)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.8,
                    ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List states
// ─────────────────────────────────────────────────────────────────────────────

/// Fade + slide-up entrance for the first screenful of cards.
class _ListReveal extends StatelessWidget {
  const _ListReveal({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (index > 8) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final strong = scheme.surfaceContainerHighest;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: strong,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final o = 0.45 + 0.4 * Curves.easeInOut.transform(_controller.value);
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            0,
          ),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, __) => Opacity(
            opacity: o,
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: strong,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(150, 14),
                        const SizedBox(height: 8),
                        bar(100, 11),
                        const SizedBox(height: 10),
                        bar(70, 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatefulWidget {
  const _EmptyView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_EmptyView> createState() => _EmptyViewState();
}

class _EmptyViewState extends State<_EmptyView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  -8 * Curves.easeInOut.transform(_controller.value),
                ),
                child: child,
              ),
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: 0.07),
                      ),
                    ),
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: 0.13),
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primary, _darken(primary, 0.4)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 34),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (widget.actionLabel != null && widget.onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _GradientPillButton(
                label: widget.actionLabel!,
                icon: Icons.add_rounded,
                onTap: widget.onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────────

class _GradientPillButton extends StatelessWidget {
  const _GradientPillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(colors: [primary, _darken(primary, 0.35)]),
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
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _GradientPillButton(
      label: 'New dream',
      icon: Icons.add_rounded,
      onTap: onTap,
    );
  }
}
