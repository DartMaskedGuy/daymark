import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/item_categories.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';

part 'bucket_list_state.dart';

/// Drives the Bucket List screen: keeps a live stream of items from Drift
/// and applies tab/search/filter/sort purely in memory, so switching tabs
/// or typing a search query never touches the database.
class BucketListCubit extends Cubit<BucketListState> {
  BucketListCubit(this._repository) : super(const BucketListState()) {
    _subscription = _repository.watchAll().listen(
          (items) => emit(state.copyWith(
            status: BucketListStatus.ready,
            allItems: items,
          )),
          onError: (_) => emit(state.copyWith(
            status: BucketListStatus.error,
            errorMessage: 'Something went wrong while loading your list.',
          )),
        );
  }

  final BucketListRepository _repository;
  late final StreamSubscription<List<BucketListItem>> _subscription;
  Timer? _debounce;

  void selectTab(BucketListFilterTab tab) => emit(state.copyWith(tab: tab));

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      emit(state.copyWith(query: query));
    });
  }

  void applyFilters(BucketListFilters filters) =>
      emit(state.copyWith(filters: filters));

  void clearFilters() => emit(state.copyWith(filters: const BucketListFilters()));

  void changeSort(SortOption sort) => emit(state.copyWith(sort: sort));

  Future<void> toggleCompleted(BucketListItem item) async {
    try {
      await _repository.setCompleted(item.id, !item.isCompleted);
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Something went wrong while updating this item.',
      ));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Something went wrong while deleting this item.',
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _subscription.cancel();
    return super.close();
  }
}
