import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/date_x.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../bucket_list/widgets/empty_state.dart';
import '../bloc/home_cubit.dart';
import '../widgets/progress_card.dart';
import '../widgets/stat_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(context.read<BucketListRepository>()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting, style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text('Your journey, one mark at a time.',
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ProgressCard(
                  completed: state.completed,
                  total: state.total,
                  progress: state.progress,
                ),
                if (state.total > 0) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Your world', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.8,
                    children: [
                      StatTile(value: state.completed, label: 'Completed'),
                      StatTile(value: state.remaining, label: 'To Go'),
                      if (state.countries > 0)
                        StatTile(value: state.countries, label: 'Countries'),
                      if (state.states > 0)
                        StatTile(value: state.states, label: 'States'),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text('Recently lived', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (state.recentlyCompleted.isEmpty)
                  const EmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: 'Your story is just beginning.',
                    message: 'Complete your first bucket-list item\nand it will appear here.',
                  )
                else
                  ...state.recentlyCompleted.map((item) {
                    final location = [item.city, item.country]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(', ');
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        onTap: () => context.push('/bucket-list/${item.id}'),
                        leading: Icon(Icons.check_circle,
                            color: theme.colorScheme.primary),
                        title: Text(item.title),
                        subtitle: Text(
                          [
                            if (location.isNotEmpty) location,
                            'Completed ${item.completedAt?.relativeOrFormatted ?? ''}',
                          ].join('\n'),
                        ),
                        isThreeLine: location.isNotEmpty,
                      ),
                    );
                  }),
                if (state.highPriority.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Must experience', style: theme.textTheme.titleMedium),
                      TextButton(
                        onPressed: () => context.go('/bucket-list'),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  ...state.highPriority.map((item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/bucket-list/${item.id}'),
                      )),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }
}
