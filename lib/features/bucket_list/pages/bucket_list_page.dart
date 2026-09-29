// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/constants/app_spacing.dart';
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Bucket List'),
//         actions: [
//           BlocBuilder<BucketListCubit, BucketListState>(
//             buildWhen: (a, b) => a.filters != b.filters,
//             builder: (context, state) {
//               return IconButton(
//                 icon: Badge(
//                   isLabelVisible: !state.filters.isEmpty,
//                   child: const Icon(Icons.tune),
//                 ),
//                 onPressed: () async {
//                   final cubit = context.read<BucketListCubit>();
//                   final result = await showModalBottomSheet<BucketListFilters>(
//                     context: context,
//                     isScrollControlled: true,
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(20),
//                       ),
//                     ),
//                     builder: (_) => FilterSheet(initial: state.filters),
//                   );
//                   if (result != null) cubit.applyFilters(result);
//                 },
//               );
//             },
//           ),
//           PopupMenuButton<SortOption>(
//             icon: const Icon(Icons.sort),
//             onSelected: (v) => context.read<BucketListCubit>().changeSort(v),
//             itemBuilder: (_) => const [
//               PopupMenuItem(
//                 value: SortOption.recentlyAdded,
//                 child: Text('Recently added'),
//               ),
//               PopupMenuItem(
//                 value: SortOption.oldestAdded,
//                 child: Text('Oldest added'),
//               ),
//               PopupMenuItem(
//                 value: SortOption.alphabetical,
//                 child: Text('Alphabetical'),
//               ),
//               PopupMenuItem(
//                 value: SortOption.priority,
//                 child: Text('Priority'),
//               ),
//               PopupMenuItem(
//                 value: SortOption.targetDate,
//                 child: Text('Target date'),
//               ),
//               PopupMenuItem(
//                 value: SortOption.recentlyCompleted,
//                 child: Text('Recently completed'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.push('/bucket-list/add'),
//         child: const Icon(Icons.add),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               AppSpacing.md,
//               AppSpacing.sm,
//               AppSpacing.md,
//               0,
//             ),
//             child: TextField(
//               onChanged: (v) => context.read<BucketListCubit>().search(v),
//               decoration: const InputDecoration(
//                 hintText: 'Search your list',
//                 prefixIcon: Icon(Icons.search),
//               ),
//             ),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
//             child: BlocBuilder<BucketListCubit, BucketListState>(
//               buildWhen: (a, b) => a.tab != b.tab,
//               builder: (context, state) {
//                 return SegmentedButton<BucketListFilterTab>(
//                   segments: const [
//                     ButtonSegment(
//                       value: BucketListFilterTab.all,
//                       label: Text('All'),
//                     ),
//                     ButtonSegment(
//                       value: BucketListFilterTab.todo,
//                       label: Text('To Do'),
//                     ),
//                     ButtonSegment(
//                       value: BucketListFilterTab.completed,
//                       label: Text('Completed'),
//                     ),
//                   ],
//                   selected: {state.tab},
//                   onSelectionChanged: (s) =>
//                       context.read<BucketListCubit>().selectTab(s.first),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           Expanded(
//             child: BlocConsumer<BucketListCubit, BucketListState>(
//               listenWhen: (a, b) =>
//                   a.errorMessage != b.errorMessage && b.errorMessage != null,
//               listener: (context, state) {
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
//               },
//               builder: (context, state) {
//                 if (state.status == BucketListStatus.loading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final items = state.visibleItems;
//                 if (items.isEmpty) {
//                   return EmptyState(
//                     icon: Icons.flag_outlined,
//                     title: state.tab == BucketListFilterTab.completed
//                         ? 'Your story is just beginning.'
//                         : 'Nothing here yet.',
//                     message: state.tab == BucketListFilterTab.completed
//                         ? 'Complete your first bucket-list item and it will appear here.'
//                         : 'Your next great experience starts with one idea.',
//                     actionLabel: state.tab == BucketListFilterTab.completed
//                         ? null
//                         : 'Add something',
//                     onAction: state.tab == BucketListFilterTab.completed
//                         ? null
//                         : () => context.push('/bucket-list/add'),
//                   );
//                 }

//                 return ListView.separated(
//                   padding: const EdgeInsets.fromLTRB(
//                     AppSpacing.md,
//                     0,
//                     AppSpacing.md,
//                     AppSpacing.xxl,
//                   ),
//                   itemCount: items.length,
//                   separatorBuilder: (_, _) =>
//                       const SizedBox(height: AppSpacing.sm),
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     return BucketListItemCard(
//                       item: item,
//                       onTap: () => context.push('/bucket-list/${item.id}'),
//                       onToggleCompleted: () =>
//                           context.read<BucketListCubit>().toggleCompleted(item),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/item_categories.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../bloc/bucket_list_cubit.dart';
import '../widgets/bucket_list_item_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_sheet.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterSheet(initial: current),
    );
    if (result != null) cubit.applyFilters(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
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
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bucket List',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              total == 0
                                  ? 'Nothing on your list yet'
                                  : '$completed lived • ${total - completed} ahead',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filledTonal(
                        icon: Badge(
                          isLabelVisible: !state.filters.isEmpty,
                          child: const Icon(Icons.tune),
                        ),
                        onPressed: () => _openFilters(context, state.filters),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      PopupMenuButton<SortOption>(
                        icon: const Icon(Icons.sort),
                        onSelected: (v) =>
                            context.read<BucketListCubit>().changeSort(v),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: SortOption.recentlyAdded,
                            child: Text('Recently added'),
                          ),
                          PopupMenuItem(
                            value: SortOption.oldestAdded,
                            child: Text('Oldest added'),
                          ),
                          PopupMenuItem(
                            value: SortOption.alphabetical,
                            child: Text('Alphabetical'),
                          ),
                          PopupMenuItem(
                            value: SortOption.priority,
                            child: Text('Priority'),
                          ),
                          PopupMenuItem(
                            value: SortOption.targetDate,
                            child: Text('Target date'),
                          ),
                          PopupMenuItem(
                            value: SortOption.recentlyCompleted,
                            child: Text('Recently completed'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            BlocBuilder<BucketListCubit, BucketListState>(
              buildWhen: (a, b) => a.filters != b.filters,
              builder: (context, state) {
                if (state.filters.isEmpty) return const SizedBox.shrink();
                final cubit = context.read<BucketListCubit>();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (state.filters.category != null)
                          _FilterChip(
                            label: state.filters.category!.label,
                            onRemoved: () => cubit.applyFilters(
                              state.filters.copyWith(clearCategory: true),
                            ),
                          ),
                        if (state.filters.priority != null)
                          _FilterChip(
                            label: '${state.filters.priority!.label} priority',
                            onRemoved: () => cubit.applyFilters(
                              state.filters.copyWith(clearPriority: true),
                            ),
                          ),
                        TextButton(
                          onPressed: cubit.clearFilters,
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: BlocBuilder<BucketListCubit, BucketListState>(
                buildWhen: (a, b) => a.tab != b.tab,
                builder: (context, state) {
                  return _TabPills(
                    selected: state.tab,
                    onChanged: (tab) =>
                        context.read<BucketListCubit>().selectTab(tab),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: BlocConsumer<BucketListCubit, BucketListState>(
                listenWhen: (a, b) =>
                    a.errorMessage != b.errorMessage && b.errorMessage != null,
                listener: (context, state) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                },
                builder: (context, state) {
                  if (state.status == BucketListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = state.visibleItems;
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.flag_outlined,
                      title: state.tab == BucketListFilterTab.completed
                          ? 'Your story is just beginning.'
                          : 'Nothing here yet.',
                      message: state.tab == BucketListFilterTab.completed
                          ? 'Complete your first bucket-list item and it will appear here.'
                          : 'Your next great experience starts with one idea.',
                      actionLabel: state.tab == BucketListFilterTab.completed
                          ? null
                          : 'Add something',
                      onAction: state.tab == BucketListFilterTab.completed
                          ? null
                          : () => context.push('/bucket-list/add'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      96,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return BucketListItemCard(
                        item: item,
                        onTap: () => context.push('/bucket-list/${item.id}'),
                        onToggleCompleted: () => context
                            .read<BucketListCubit>()
                            .toggleCompleted(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bucket-list/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemoved});

  final String label;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InputChip(
        label: Text(label),
        onDeleted: onRemoved,
        deleteIconColor: Theme.of(context).colorScheme.primary,
        side: BorderSide.none,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.10),
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
    return TextField(
      controller: _controller,
      onChanged: (v) {
        setState(() {});
        widget.onChanged(v);
      },
      decoration: InputDecoration(
        hintText: 'Search your list',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
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
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Custom segmented control with a sliding indicator, echoing the floating
/// nav bar's pill language instead of the stock Material SegmentedButton.
class _TabPills extends StatelessWidget {
  const _TabPills({required this.selected, required this.onChanged});

  final BucketListFilterTab selected;
  final ValueChanged<BucketListFilterTab> onChanged;

  static const _tabs = [
    (value: BucketListFilterTab.all, label: 'All'),
    (value: BucketListFilterTab.todo, label: 'To Do'),
    (value: BucketListFilterTab.completed, label: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final index = _tabs.indexWhere((t) => t.value == selected);

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / _tabs.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: segmentWidth * index,
                width: segmentWidth,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(18),
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
                        child: Center(
                          child: Text(
                            tab.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: tab.value == selected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
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
