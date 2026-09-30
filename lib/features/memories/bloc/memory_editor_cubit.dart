import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/services/media_storage_service.dart';

part 'memory_editor_state.dart';

/// Drives the memory-capture screen for one completed item. Notes and
/// date are staged locally and only written on [save]; photos, videos,
/// and links are persisted the moment they're added (the item already
/// exists, so there's no "new item has no id yet" problem to defer for —
/// same reasoning as editing an existing item in AddItemCubit).
class MemoryEditorCubit extends Cubit<MemoryEditorState> {
  MemoryEditorCubit(
    this._bucketListRepo,
    this._mediaRepo,
    this._memoryRepo,
    this.itemId,
  ) : super(const MemoryEditorState()) {
    _load();
    _mediaSub = _mediaRepo.watchForItem(itemId).listen((media) {
      emit(
        state.copyWith(
          photos: media.where((m) => m.type == 'image').toList(),
          videos: media.where((m) => m.type == 'video').toList(),
        ),
      );
    });
    _linksSub = _bucketListRepo.watchLinks(itemId).listen((links) {
      emit(state.copyWith(links: links));
    });
  }

  final BucketListRepository _bucketListRepo;
  final MediaRepository _mediaRepo;
  final MemoryRepository _memoryRepo;
  final String itemId;
  final ImagePicker _picker = ImagePicker();
  final MediaStorageService _mediaStorage = MediaStorageService();
  late final StreamSubscription<List<MediaItem>> _mediaSub;
  late final StreamSubscription<List<Link>> _linksSub;

  Future<void> _load() async {
    try {
      final item = await _bucketListRepo.getById(itemId);
      if (item == null) {
        emit(state.copyWith(status: MemoryEditorStatus.notFound));
        return;
      }
      final memory = await _memoryRepo.getForItem(itemId);
      emit(
        state.copyWith(
          status: MemoryEditorStatus.ready,
          item: item,
          notes: memory?.notes ?? '',
          memoryDate: memory?.memoryDate ?? item.completedAt,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MemoryEditorStatus.error,
          errorMessage: 'Something went wrong while loading this memory.',
        ),
      );
    }
  }

  void notesChanged(String value) => emit(state.copyWith(notes: value));
  void dateChanged(DateTime value) => emit(state.copyWith(memoryDate: value));

  Future<void> pickPhotos() async {
    try {
      final picked = await _picker.pickMultiImage();
      for (final file in picked) {
        final path = await _mediaStorage.persistFile(file.path);
        await _mediaRepo.addMedia(itemId: itemId, type: 'image', path: path);
      }
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Something went wrong while adding photos.',
        ),
      );
    }
  }

  Future<void> pickVideo() async {
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;
      final path = await _mediaStorage.persistFile(picked.path);
      await _mediaRepo.addMedia(itemId: itemId, type: 'video', path: path);
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Something went wrong while adding that video.',
        ),
      );
    }
  }

  Future<void> removeMedia(MediaItem media) async {
    try {
      await _mediaRepo.removeMedia(media.id);
      await _mediaStorage.deleteFile(media.path);
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Something went wrong while removing that.',
        ),
      );
    }
  }

  /// Basic validation: require a title, and either a parseable URL as-is
  /// or one that becomes parseable once an "https://" scheme is assumed.
  Future<void> addLink(String title, String rawUrl) async {
    final trimmedTitle = title.trim();
    final trimmedUrl = rawUrl.trim();
    if (trimmedTitle.isEmpty || trimmedUrl.isEmpty) return;

    var url = trimmedUrl;
    var uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      url = 'https://$trimmedUrl';
      uri = Uri.tryParse(url);
    }
    if (uri == null || !uri.hasAuthority) {
      emit(
        state.copyWith(
          errorMessage: 'That link doesn\'t look right — check the URL.',
        ),
      );
      return;
    }

    final updated = [
      ...state.links.map((l) => (title: l.title, url: l.url)),
      (title: trimmedTitle, url: url),
    ];
    await _bucketListRepo.replaceLinks(itemId, updated);
  }

  Future<void> removeLink(Link link) async {
    final updated = state.links
        .where((l) => l.id != link.id)
        .map((l) => (title: l.title, url: l.url))
        .toList();
    await _bucketListRepo.replaceLinks(itemId, updated);
  }

  Future<void> save() async {
    emit(state.copyWith(status: MemoryEditorStatus.saving));
    try {
      await _memoryRepo.saveMemory(
        itemId: itemId,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        memoryDate: state.memoryDate,
      );
      emit(state.copyWith(status: MemoryEditorStatus.saved));
    } catch (_) {
      emit(
        state.copyWith(
          status: MemoryEditorStatus.error,
          errorMessage: 'Something went wrong while saving this memory.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _mediaSub.cancel();
    _linksSub.cancel();
    return super.close();
  }
}
