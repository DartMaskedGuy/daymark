part of 'memory_editor_cubit.dart';

enum MemoryEditorStatus { loading, ready, saving, saved, notFound, error }

class MemoryEditorState extends Equatable {
  final MemoryEditorStatus status;
  final BucketListItem? item;
  final String notes;
  final DateTime? memoryDate;
  final List<MediaItem> photos;
  final List<MediaItem> videos;
  final List<Link> links;
  final String? errorMessage;

  const MemoryEditorState({
    this.status = MemoryEditorStatus.loading,
    this.item,
    this.notes = '',
    this.memoryDate,
    this.photos = const [],
    this.videos = const [],
    this.links = const [],
    this.errorMessage,
  });

  MemoryEditorState copyWith({
    MemoryEditorStatus? status,
    BucketListItem? item,
    String? notes,
    DateTime? memoryDate,
    List<MediaItem>? photos,
    List<MediaItem>? videos,
    List<Link>? links,
    String? errorMessage,
  }) {
    return MemoryEditorState(
      status: status ?? this.status,
      item: item ?? this.item,
      notes: notes ?? this.notes,
      memoryDate: memoryDate ?? this.memoryDate,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      links: links ?? this.links,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    item,
    notes,
    memoryDate,
    photos,
    videos,
    links,
    errorMessage,
  ];
}
