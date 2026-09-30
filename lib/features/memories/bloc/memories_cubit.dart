// import 'dart:async';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../data/database/app_database.dart';
// import '../../../data/repositories/bucket_list_repository.dart';

// part 'memories_state.dart';

// /// Memories are just completed items viewed as a personal archive; V1
// /// reuses the bucket-list stream rather than a separate query.
// class MemoriesCubit extends Cubit<MemoriesState> {
//   MemoriesCubit(this._repository) : super(const MemoriesState()) {
//     _subscription = _repository.watchAll().listen((items) {
//       final completed = items.where((i) => i.isCompleted).toList()
//         ..sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0)));
//       emit(MemoriesState(status: MemoriesStatus.ready, items: completed));
//     }, onError: (_) => emit(state.copyWith(status: MemoriesStatus.error)));
//   }

//   final BucketListRepository _repository;
//   late final StreamSubscription<List<BucketListItem>> _subscription;

//   @override
//   Future<void> close() {
//     _subscription.cancel();
//     return super.close();
//   }
// }

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/memory_repository.dart';

part 'memories_state.dart';

/// Memories are completed items enriched with their notes preview, lead
/// photo, and media count. The items stream (bucket-list completions)
/// drives the base list reactively; the memory/media enrichment is a
/// one-shot fetch per emission rather than three more streams — see
/// [refresh] for why that's not fully self-updating.
class MemoriesCubit extends Cubit<MemoriesState> {
  MemoriesCubit(this._bucketListRepo, this._mediaRepo, this._memoryRepo)
    : super(const MemoriesState()) {
    _subscription = _bucketListRepo.watchAll().listen(
      _rebuild,
      onError: (_) => emit(state.copyWith(status: MemoriesStatus.error)),
    );
  }

  final BucketListRepository _bucketListRepo;
  final MediaRepository _mediaRepo;
  final MemoryRepository _memoryRepo;
  late final StreamSubscription<List<BucketListItem>> _subscription;
  List<BucketListItem> _lastItems = [];

  Future<void> _rebuild(List<BucketListItem> items) async {
    _lastItems = items;
    final completed = items.where((i) => i.isCompleted).toList()
      ..sort(
        (a, b) => (b.completedAt ?? DateTime(0)).compareTo(
          a.completedAt ?? DateTime(0),
        ),
      );

    final entries = await Future.wait(
      completed.map((item) async {
        final memory = await _memoryRepo.getForItem(item.id);
        final media = await _mediaRepo.watchForItem(item.id).first;
        final photos = media.where((m) => m.type == 'image').toList();
        return MemoryEntry(
          item: item,
          notesPreview: memory?.notes,
          leadPhoto: photos.isEmpty ? null : photos.first,
          mediaCount: media.length,
        );
      }),
    );

    emit(MemoriesState(status: MemoriesStatus.ready, entries: entries));
  }

  /// Editing a memory (notes, photos, links) doesn't touch the
  /// BucketListItems table, so the reactive stream above never re-emits
  /// for those changes. Call this after returning from the memory editor
  /// to pick them up without adding three more permanent subscriptions
  /// this screen would otherwise hold open at all times.
  Future<void> refresh() => _rebuild(_lastItems);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
