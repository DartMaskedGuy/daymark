import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bucket List'),
        actions: [
          BlocBuilder<BucketListCubit, BucketListState>(
            buildWhen: (a, b) => a.filters != b.filters,
            builder: (context, state) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: !state.filters.isEmpty,
                  child: const Icon(Icons.tune),
                ),
                onPressed: () async {
                  final cubit = context.read<BucketListCubit>();
                  final result = await showModalBottomSheet<BucketListFilters>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => FilterSheet(initial: state.filters),
                  );
                  if (result != null) cubit.applyFilters(result);
                },
              );
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (v) => context.read<BucketListCubit>().changeSort(v),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bucket-list/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: TextField(
              onChanged: (v) => context.read<BucketListCubit>().search(v),
              decoration: const InputDecoration(
                hintText: 'Search your list',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: BlocBuilder<BucketListCubit, BucketListState>(
              buildWhen: (a, b) => a.tab != b.tab,
              builder: (context, state) {
                return SegmentedButton<BucketListFilterTab>(
                  segments: const [
                    ButtonSegment(
                      value: BucketListFilterTab.all,
                      label: Text('All'),
                    ),
                    ButtonSegment(
                      value: BucketListFilterTab.todo,
                      label: Text('To Do'),
                    ),
                    ButtonSegment(
                      value: BucketListFilterTab.completed,
                      label: Text('Completed'),
                    ),
                  ],
                  selected: {state.tab},
                  onSelectionChanged: (s) =>
                      context.read<BucketListCubit>().selectTab(s.first),
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
                    AppSpacing.xxl,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return BucketListItemCard(
                      item: item,
                      onTap: () => context.push('/bucket-list/${item.id}'),
                      onToggleCompleted: () =>
                          context.read<BucketListCubit>().toggleCompleted(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
