import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/date_x.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../bucket_list/widgets/empty_state.dart';
import '../bloc/memories_cubit.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MemoriesCubit(context.read<BucketListRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Memories')),
        body: BlocBuilder<MemoriesCubit, MemoriesState>(
          builder: (context, state) {
            if (state.status == MemoriesStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.items.isEmpty) {
              return const EmptyState(
                icon: Icons.auto_stories_outlined,
                title: 'No memories yet.',
                message: 'Complete something and save the moment.',
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.85,
              ),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                final accent = AppColors.fromKey(item.color);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/bucket-list/${item.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: accent.withValues(alpha: 0.15),
                            child: Icon(Icons.photo_outlined, color: accent, size: 32),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                item.completedAt?.relativeOrFormatted ?? '',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
