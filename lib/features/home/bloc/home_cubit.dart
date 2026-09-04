import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';

part 'home_state.dart';

/// Loads the Home screen's stats and highlight lists from the same live
/// item stream the Bucket List screen uses, so both stay in sync for free.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState()) {
    _subscription = _repository.watchAll().listen((items) {
      final completed = items.where((i) => i.isCompleted).toList()
        ..sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0)));
      final highPriority = items
          .where((i) => !i.isCompleted && i.priority == 'High')
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final countries = items
          .map((i) => i.country)
          .whereType<String>()
          .where((c) => c.isNotEmpty)
          .toSet()
          .length;
      final states = items
          .map((i) => i.state)
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .length;

      emit(HomeState(
        status: HomeStatus.ready,
        total: items.length,
        completed: completed.length,
        countries: countries,
        states: states,
        recentlyCompleted: completed.take(3).toList(),
        highPriority: highPriority.take(5).toList(),
      ));
    }, onError: (_) => emit(state.copyWith(status: HomeStatus.error)));
  }

  final BucketListRepository _repository;
  late final StreamSubscription<List<BucketListItem>> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
