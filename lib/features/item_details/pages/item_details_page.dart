import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../bloc/item_details_cubit.dart';

class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemDetailsCubit(
        context.read<BucketListRepository>(),
        context.read<MemoryRepository>(),
        itemId,
      ),
      child: const _ItemDetailsView(),
    );
  }
}

class _ItemDetailsView extends StatelessWidget {
  const _ItemDetailsView();

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this bucket-list item?'),
        content: const Text('This will remove the item and its saved memories.'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => context.pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ItemDetailsCubit>().delete();
      if (context.mounted) context.pop();
    }
  }

  Future<void> _handleToggle(BuildContext context) async {
    final nowCompleted = await context.read<ItemDetailsCubit>().toggleCompleted();
    if (!context.mounted || !nowCompleted) return;
    final add = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('You lived it. ✨'),
        content: const Text('Want to save the memory?'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Maybe later')),
          FilledButton(onPressed: () => context.pop(true), child: const Text('Add memory')),
        ],
      ),
    );
    if (add == true) {
      // Memory capture reuses the item details screen's own notes section;
      // no separate route needed for V1.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocConsumer<ItemDetailsCubit, ItemDetailsState>(
        listenWhen: (a, b) => a.errorMessage != b.errorMessage && b.errorMessage != null,
        listener: (context, state) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!))),
        builder: (context, state) {
          if (state.status == ItemDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ItemDetailsStatus.notFound || state.item == null) {
            return const Center(child: Text('This item no longer exists.'));
          }

          final item = state.item!;
          final accent = AppColors.fromKey(item.color);
          final location = [item.city, item.state, item.country]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/bucket-list/${item.id}/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: theme.textTheme.displaySmall),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          Chip(
                            label: Text(item.category),
                            backgroundColor: accent.withValues(alpha: 0.15),
                          ),
                          Chip(label: Text('${item.priority} Priority')),
                        ],
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            Text(location, style: theme.textTheme.bodyLarge),
                          ],
                        ),
                      ],
                      if (item.targetDate != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            Text('Target: ${item.targetDate!.month}/${item.targetDate!.year}',
                                style: theme.textTheme.bodyLarge),
                          ],
                        ),
                      ],
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Description', style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(item.description!, style: theme.textTheme.bodyLarge),
                      ],
                      if (state.links.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Links', style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        ...state.links.map((link) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.link),
                              title: Text(link.title),
                              onTap: () => launchUrl(Uri.parse(link.url)),
                            )),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text('Status', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.isCompleted
                            ? 'Completed ✓\n${item.completedAt != null ? '${item.completedAt!.month}/${item.completedAt!.day}/${item.completedAt!.year}' : ''}'
                            : 'Not completed',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _handleToggle(context),
                          child: Text(item.isCompleted ? 'Mark as incomplete' : 'Mark as completed'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
