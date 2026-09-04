import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';

part 'memories_state.dart';

/// Memories are just completed items viewed as a personal archive; V1
/// reuses the bucket-list stream rather than a separate query.
class MemoriesCubit extends Cubit<MemoriesState> {
  MemoriesCubit(this._repository) : super(const MemoriesState()) {
    _subscription = _repository.watchAll().listen((items) {
      final completed = items.where((i) => i.isCompleted).toList()
        ..sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0)));
      emit(MemoriesState(status: MemoriesStatus.ready, items: completed));
    }, onError: (_) => emit(state.copyWith(status: MemoriesStatus.error)));
  }

  final BucketListRepository _repository;
  late final StreamSubscription<List<BucketListItem>> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
