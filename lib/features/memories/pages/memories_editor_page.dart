import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/date_x.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../bloc/memory_editor_cubit.dart';

class MemoryEditorPage extends StatelessWidget {
  const MemoryEditorPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MemoryEditorCubit(
        context.read<BucketListRepository>(),
        context.read<MediaRepository>(),
        context.read<MemoryRepository>(),
        itemId,
      ),
      child: const _MemoryEditorView(),
    );
  }
}

class _MemoryEditorView extends StatefulWidget {
  const _MemoryEditorView();

  @override
  State<_MemoryEditorView> createState() => _MemoryEditorViewState();
}

class _MemoryEditorViewState extends State<_MemoryEditorView> {
  late final TextEditingController _notesController;
  bool _initialized = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addLink(BuildContext context) async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      await context.read<MemoryEditorCubit>().addLink(
        titleController.text,
        urlController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Memory')),
      body: BlocConsumer<MemoryEditorCubit, MemoryEditorState>(
        listenWhen: (a, b) =>
            a.status != b.status || a.errorMessage != b.errorMessage,
        listener: (context, state) {
          if (state.status == MemoryEditorStatus.saved) {
            context.pop();
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == MemoryEditorStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MemoryEditorStatus.notFound ||
              state.item == null) {
            return const Center(child: Text('This item no longer exists.'));
          }

          if (!_initialized) {
            _notesController = TextEditingController(text: state.notes);
            _initialized = true;
          }

          final item = state.item!;
          final accent = AppColors.fromKey(item.color);
          final cubit = context.read<MemoryEditorCubit>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.auto_stories_outlined,
                      color: accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: theme.textTheme.titleMedium),
                        if (item.completedAt != null)
                          Text(
                            'Lived ${item.completedAt!.relativeOrFormatted}',
                            style: theme.textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('What happened?', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notesController,
                onChanged: cubit.notesChanged,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      "This was one of the most memorable trips I've ever taken.",
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('When did this happen?'),
                subtitle: Text(
                  state.memoryDate != null ? state.memoryDate!.long : 'Not set',
                  style: theme.textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.memoryDate ?? DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) cubit.dateChanged(picked);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Photos', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _MediaRow(
                items: state.photos,
                onAdd: cubit.pickPhotos,
                onRemove: cubit.removeMedia,
                addIcon: Icons.add_photo_alternate_outlined,
                isVideo: false,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Videos', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _MediaRow(
                items: state.videos,
                onAdd: cubit.pickVideo,
                onRemove: cubit.removeMedia,
                addIcon: Icons.video_call_outlined,
                isVideo: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Links', style: theme.textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: () => _addLink(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add link'),
                  ),
                ],
              ),
              if (state.links.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'No links yet.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                ...state.links.map(
                  (link) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link),
                    title: Text(link.title),
                    subtitle: Text(
                      link.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => launchUrl(Uri.parse(link.url)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => cubit.removeLink(link),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: state.status == MemoryEditorStatus.saving
                    ? null
                    : cubit.save,
                child: state.status == MemoryEditorStatus.saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save memory'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Horizontal row of media thumbnails plus an add tile. Videos show a dark
/// placeholder with a play glyph rather than a real decoded frame — adding
/// a thumbnail-generation package for that felt like more dependency than
/// this earns in V1.
class _MediaRow extends StatelessWidget {
  const _MediaRow({
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.addIcon,
    required this.isVideo,
  });

  final List<MediaItem> items;
  final VoidCallback onAdd;
  final ValueChanged<MediaItem> onRemove;
  final IconData addIcon;
  final bool isVideo;

  static const double _size = 84;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final media in items)
          SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isVideo
                      ? Container(
                          color: Colors.black87,
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white70,
                            size: 28,
                          ),
                        )
                      : Image.file(
                          File(media.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemove(media),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(addIcon, color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
