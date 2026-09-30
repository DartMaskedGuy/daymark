// part of 'memories_cubit.dart';

// enum MemoriesStatus { loading, ready, error }

// class MemoriesState extends Equatable {
//   final MemoriesStatus status;
//   final List<BucketListItem> items;

//   const MemoriesState({this.status = MemoriesStatus.loading, this.items = const []});

//   MemoriesState copyWith({MemoriesStatus? status}) =>
//       MemoriesState(status: status ?? this.status, items: items);

//   @override
//   List<Object?> get props => [status, items];
// }

part of 'memories_cubit.dart';

enum MemoriesStatus { loading, ready, error }

/// One completed item enriched with just enough from its memory and media
/// to render a timeline card, without the page needing three separate
/// lookups per entry.
class MemoryEntry extends Equatable {
  const MemoryEntry({
    required this.item,
    this.notesPreview,
    this.leadPhoto,
    required this.mediaCount,
  });

  final BucketListItem item;
  final String? notesPreview;
  final MediaItem? leadPhoto;
  final int mediaCount;

  @override
  List<Object?> get props => [item, notesPreview, leadPhoto, mediaCount];
}

class MemoriesState extends Equatable {
  const MemoriesState({
    this.status = MemoriesStatus.loading,
    this.entries = const [],
  });

  final MemoriesStatus status;
  final List<MemoryEntry> entries;

  MemoriesState copyWith({MemoriesStatus? status}) =>
      MemoriesState(status: status ?? this.status, entries: entries);

  @override
  List<Object?> get props => [status, entries];
}
