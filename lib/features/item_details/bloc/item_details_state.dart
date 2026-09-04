part of 'item_details_cubit.dart';

enum ItemDetailsStatus { loading, ready, notFound, error }

class ItemDetailsState extends Equatable {
  final ItemDetailsStatus status;
  final BucketListItem? item;
  final List<Link> links;
  final List<MediaItem> media;
  final Memory? memory;
  final String? errorMessage;

  const ItemDetailsState({
    this.status = ItemDetailsStatus.loading,
    this.item,
    this.links = const [],
    this.media = const [],
    this.memory,
    this.errorMessage,
  });

  ItemDetailsState copyWith({
    ItemDetailsStatus? status,
    BucketListItem? item,
    List<Link>? links,
    List<MediaItem>? media,
    Memory? memory,
    String? errorMessage,
  }) {
    return ItemDetailsState(
      status: status ?? this.status,
      item: item ?? this.item,
      links: links ?? this.links,
      media: media ?? this.media,
      memory: memory ?? this.memory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, item, links, media, memory, errorMessage];
}
