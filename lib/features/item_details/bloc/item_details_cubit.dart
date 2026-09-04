import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/memory_repository.dart';

part 'item_details_state.dart';

/// Combines the item itself, its links, media, and memory into one state
/// for the details screen, and owns the complete/incomplete toggle.
class ItemDetailsCubit extends Cubit<ItemDetailsState> {
  ItemDetailsCubit(this._bucketListRepo, this._memoryRepo, this.itemId)
      : super(const ItemDetailsState()) {
    _load();
    _linksSub = _bucketListRepo.watchLinks(itemId).listen((links) {
      emit(state.copyWith(links: links));
    });
  }

  final BucketListRepository _bucketListRepo;
  final MemoryRepository _memoryRepo;
  final String itemId;
  late final StreamSubscription<List<Link>> _linksSub;

  Future<void> _load() async {
    try {
      final item = await _bucketListRepo.getById(itemId);
      if (item == null) {
        emit(state.copyWith(status: ItemDetailsStatus.notFound));
        return;
      }
      final memory = await _memoryRepo.getForItem(itemId);
      emit(state.copyWith(status: ItemDetailsStatus.ready, item: item, memory: memory));
    } catch (_) {
      emit(state.copyWith(
        status: ItemDetailsStatus.error,
        errorMessage: 'Something went wrong while loading this item.',
      ));
    }
  }

  Future<void> refresh() => _load();

  Future<bool> toggleCompleted() async {
    final item = state.item;
    if (item == null) return false;
    final newValue = !item.isCompleted;
    await _bucketListRepo.setCompleted(item.id, newValue);
    await _load();
    return newValue;
  }

  Future<void> delete() => _bucketListRepo.deleteItem(itemId);

  @override
  Future<void> close() {
    _linksSub.cancel();
    return super.close();
  }
}
