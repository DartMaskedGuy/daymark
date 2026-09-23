// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../app/theme/app_colors.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../data/repositories/bucket_list_repository.dart';
// import '../../../data/repositories/memory_repository.dart';
// import '../bloc/item_details_cubit.dart';

// class ItemDetailsPage extends StatelessWidget {
//   const ItemDetailsPage({super.key, required this.itemId});

//   final String itemId;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ItemDetailsCubit(
//         context.read<BucketListRepository>(),
//         context.read<MemoryRepository>(),
//         itemId,
//       ),
//       child: const _ItemDetailsView(),
//     );
//   }
// }

// class _ItemDetailsView extends StatelessWidget {
//   const _ItemDetailsView();

//   Future<void> _confirmDelete(BuildContext context) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete this bucket-list item?'),
//         content: const Text('This will remove the item and its saved memories.'),
//         actions: [
//           TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
//           FilledButton(onPressed: () => context.pop(true), child: const Text('Delete')),
//         ],
//       ),
//     );
//     if (confirmed == true && context.mounted) {
//       await context.read<ItemDetailsCubit>().delete();
//       if (context.mounted) context.pop();
//     }
//   }

//   Future<void> _handleToggle(BuildContext context) async {
//     final nowCompleted = await context.read<ItemDetailsCubit>().toggleCompleted();
//     if (!context.mounted || !nowCompleted) return;
//     final add = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('You lived it. ✨'),
//         content: const Text('Want to save the memory?'),
//         actions: [
//           TextButton(onPressed: () => context.pop(false), child: const Text('Maybe later')),
//           FilledButton(onPressed: () => context.pop(true), child: const Text('Add memory')),
//         ],
//       ),
//     );
//     if (add == true) {
//       // Memory capture reuses the item details screen's own notes section;
//       // no separate route needed for V1.
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       body: BlocConsumer<ItemDetailsCubit, ItemDetailsState>(
//         listenWhen: (a, b) => a.errorMessage != b.errorMessage && b.errorMessage != null,
//         listener: (context, state) => ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(state.errorMessage!))),
//         builder: (context, state) {
//           if (state.status == ItemDetailsStatus.loading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state.status == ItemDetailsStatus.notFound || state.item == null) {
//             return const Center(child: Text('This item no longer exists.'));
//           }

//           final item = state.item!;
//           final accent = AppColors.fromKey(item.color);
//           final location = [item.city, item.state, item.country]
//               .where((s) => s != null && s.isNotEmpty)
//               .join(', ');

//           return CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 pinned: true,
//                 backgroundColor: theme.scaffoldBackgroundColor,
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.edit_outlined),
//                     onPressed: () => context.push('/bucket-list/${item.id}/edit'),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.delete_outline),
//                     onPressed: () => _confirmDelete(context),
//                   ),
//                 ],
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(
//                     AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(item.title, style: theme.textTheme.displaySmall),
//                       const SizedBox(height: AppSpacing.sm),
//                       Wrap(
//                         spacing: AppSpacing.sm,
//                         children: [
//                           Chip(
//                             label: Text(item.category),
//                             backgroundColor: accent.withValues(alpha: 0.15),
//                           ),
//                           Chip(label: Text('${item.priority} Priority')),
//                         ],
//                       ),
//                       if (location.isNotEmpty) ...[
//                         const SizedBox(height: AppSpacing.md),
//                         Row(
//                           children: [
//                             const Icon(Icons.place_outlined, size: 18),
//                             const SizedBox(width: AppSpacing.xs),
//                             Text(location, style: theme.textTheme.bodyLarge),
//                           ],
//                         ),
//                       ],
//                       if (item.targetDate != null) ...[
//                         const SizedBox(height: AppSpacing.sm),
//                         Row(
//                           children: [
//                             const Icon(Icons.event_outlined, size: 18),
//                             const SizedBox(width: AppSpacing.xs),
//                             Text('Target: ${item.targetDate!.month}/${item.targetDate!.year}',
//                                 style: theme.textTheme.bodyLarge),
//                           ],
//                         ),
//                       ],
//                       if (item.description != null && item.description!.isNotEmpty) ...[
//                         const SizedBox(height: AppSpacing.lg),
//                         Text('Description', style: theme.textTheme.titleMedium),
//                         const SizedBox(height: AppSpacing.xs),
//                         Text(item.description!, style: theme.textTheme.bodyLarge),
//                       ],
//                       if (state.links.isNotEmpty) ...[
//                         const SizedBox(height: AppSpacing.lg),
//                         Text('Links', style: theme.textTheme.titleMedium),
//                         const SizedBox(height: AppSpacing.xs),
//                         ...state.links.map((link) => ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               leading: const Icon(Icons.link),
//                               title: Text(link.title),
//                               onTap: () => launchUrl(Uri.parse(link.url)),
//                             )),
//                       ],
//                       const SizedBox(height: AppSpacing.lg),
//                       Text('Status', style: theme.textTheme.titleMedium),
//                       const SizedBox(height: AppSpacing.xs),
//                       Text(
//                         item.isCompleted
//                             ? 'Completed ✓\n${item.completedAt != null ? '${item.completedAt!.month}/${item.completedAt!.day}/${item.completedAt!.year}' : ''}'
//                             : 'Not completed',
//                         style: theme.textTheme.bodyLarge,
//                       ),
//                       const SizedBox(height: AppSpacing.xl),
//                       SizedBox(
//                         width: double.infinity,
//                         child: FilledButton(
//                           onPressed: () => _handleToggle(context),
//                           child: Text(item.isCompleted ? 'Mark as incomplete' : 'Mark as completed'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../bloc/item_details_cubit.dart';

const double _heroHeight = 320;

class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemDetailsCubit(
        context.read<BucketListRepository>(),
        context.read<MediaRepository>(),
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
        content: const Text(
          'This will remove the item and its saved memories.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ItemDetailsCubit>().delete();
      if (context.mounted) context.pop();
    }
  }

  Future<void> _handleToggle(BuildContext context) async {
    final nowCompleted = await context
        .read<ItemDetailsCubit>()
        .toggleCompleted();
    if (!context.mounted || !nowCompleted) return;
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('You lived it. ✨'),
        content: const Text('Want to save the memory?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Maybe later'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Add memory'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: BlocConsumer<ItemDetailsCubit, ItemDetailsState>(
          listenWhen: (a, b) =>
              a.errorMessage != b.errorMessage && b.errorMessage != null,
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
          builder: (context, state) {
            if (state.status == ItemDetailsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ItemDetailsStatus.notFound ||
                state.item == null) {
              return const Center(child: Text('This item no longer exists.'));
            }

            final item = state.item!;
            final accent = AppColors.fromKey(item.color);
            final location = [
              item.city,
              item.state,
              item.country,
            ].where((s) => s != null && s.isNotEmpty).join(', ');

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Hero(
                    media: state.media,
                    accent: accent,
                    category: item.category,
                    isCompleted: item.isCompleted,
                    onBack: () => context.pop(),
                    onEdit: () => context.push('/bucket-list/${item.id}/edit'),
                    onDelete: () => _confirmDelete(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.xxl,
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
                              side: BorderSide.none,
                            ),
                            Chip(
                              label: Text('${item.priority} Priority'),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        if (location.isNotEmpty || item.targetDate != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              if (location.isNotEmpty)
                                Expanded(
                                  child: _FactTile(
                                    icon: Icons.place_outlined,
                                    label: 'Location',
                                    value: location,
                                  ),
                                ),
                              if (location.isNotEmpty &&
                                  item.targetDate != null)
                                const SizedBox(width: AppSpacing.sm),
                              if (item.targetDate != null)
                                Expanded(
                                  child: _FactTile(
                                    icon: Icons.event_outlined,
                                    label: 'Target',
                                    value:
                                        '${item.targetDate!.month}/${item.targetDate!.year}',
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (item.description != null &&
                            item.description!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Description',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.description!,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                        if (state.links.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text('Links', style: theme.textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          ...state.links.map(
                            (link) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.link),
                              title: Text(link.title),
                              onTap: () => launchUrl(Uri.parse(link.url)),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        _StatusCard(item: item, accent: accent),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: item.isCompleted
                              ? OutlinedButton(
                                  onPressed: () => _handleToggle(context),
                                  child: const Text('Mark as incomplete'),
                                )
                              : FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        theme.brightness == Brightness.dark
                                        ? AppColors.darkSuccess
                                        : AppColors.lightSuccess,
                                  ),
                                  onPressed: () => _handleToggle(context),
                                  child: const Text('Mark as completed'),
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
      ),
    );
  }
}

/// Edge-to-edge hero: a photo carousel when the item has media, or an
/// accent-tinted panel carrying the category glyph when it doesn't — the
/// item's own color does the work here instead of a generic placeholder.
/// Floating controls sit on translucent scrims over the image itself
/// rather than in a separate app bar, and a rotated stamp lands on
/// completed items — the one intentionally bold element on the page.
class _Hero extends StatefulWidget {
  const _Hero({
    required this.media,
    required this.accent,
    required this.category,
    required this.isCompleted,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  final List<MediaItem> media;
  final Color accent;
  final String category;
  final bool isCompleted;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondary) => FadeTransition(
          opacity: animation,
          child: _FullScreenGallery(
            media: widget.media,
            initialIndex: initialIndex,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = widget.media.isNotEmpty;

    return SizedBox(
      height: _heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasMedia)
            PageView.builder(
              controller: _pageController,
              itemCount: widget.media.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final item = widget.media[index];
                return GestureDetector(
                  onTap: () => _openFullScreen(index),
                  child: Hero(
                    tag: 'media-${item.id}',
                    child: Image.file(
                      File(item.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: widget.accent.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: widget.accent,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accent.withValues(alpha: 0.35),
                    widget.accent.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _iconFor(widget.category),
                  size: 64,
                  color: widget.accent,
                ),
              ),
            ),

          // Bottom gradient so floating controls and dots stay legible
          // over a bright photo.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),

          if (hasMedia && widget.media.length > 1)
            Positioned(
              bottom: AppSpacing.md,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.media.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: i == _page ? 0.9 : 0.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

          if (widget.isCompleted)
            Positioned(
              top: AppSpacing.xl,
              right: AppSpacing.lg,
              child: Transform.rotate(
                angle: -0.28,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 18),
                      Text(
                        'LIVED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ScrimIconButton(
                    icon: Icons.arrow_back,
                    onTap: widget.onBack,
                  ),
                  Row(
                    children: [
                      _ScrimIconButton(
                        icon: Icons.edit_outlined,
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ScrimIconButton(
                        icon: Icons.delete_outline,
                        onTap: widget.onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String category) => switch (category) {
    'Travel' => Icons.flight_takeoff,
    'Experience' => Icons.auto_awesome,
    'Personal' => Icons.person_outline,
    'Career' => Icons.work_outline,
    'Education' => Icons.school_outlined,
    'Adventure' => Icons.terrain,
    _ => Icons.star_outline,
  };
}

class _ScrimIconButton extends StatelessWidget {
  const _ScrimIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// A labeled fact, styled like Home's stat tiles so this screen reads as
/// part of the same design language rather than a one-off layout.
class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// Status card with a left accent bar, matching the bucket-list item
/// card's visual language elsewhere in the app.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.item, required this.accent});

  final BucketListItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              color: item.isCompleted ? accent : theme.colorScheme.outline,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      item.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: item.isCompleted
                          ? accent
                          : theme.textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.isCompleted
                            ? 'Completed ${item.completedAt != null ? '${item.completedAt!.month}/${item.completedAt!.day}/${item.completedAt!.year}' : ''}'
                            : 'Not completed yet',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed, pinch-to-zoom viewer for a tapped photo, opened as a
/// Hero-linked overlay rather than a full page transition.
class _FullScreenGallery extends StatelessWidget {
  const _FullScreenGallery({required this.media, required this.initialIndex});

  final List<MediaItem> media;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: media.length,
              itemBuilder: (context, index) {
                final item = media[index];
                return Center(
                  child: Hero(
                    tag: 'media-${item.id}',
                    child: InteractiveViewer(
                      child: Image.file(File(item.path)),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _ScrimIconButton(
                icon: Icons.close,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
