import 'package:equatable/equatable.dart';
import '../database/app_database.dart';

/// Aggregates everything the Item Details screen needs to render, so the
/// UI/cubit don't have to juggle four separate streams.
class ItemDetailsData extends Equatable {
  final BucketListItem item;
  final List<Link> links;
  final List<MediaItem> media;
  final Memory? memory;

  const ItemDetailsData({
    required this.item,
    required this.links,
    required this.media,
    required this.memory,
  });

  @override
  List<Object?> get props => [item, links, media, memory];
}
