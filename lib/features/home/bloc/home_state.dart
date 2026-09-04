part of 'home_cubit.dart';

enum HomeStatus { loading, ready, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final int total;
  final int completed;
  final int countries;
  final int states;
  final List<BucketListItem> recentlyCompleted;
  final List<BucketListItem> highPriority;

  const HomeState({
    this.status = HomeStatus.loading,
    this.total = 0,
    this.completed = 0,
    this.countries = 0,
    this.states = 0,
    this.recentlyCompleted = const [],
    this.highPriority = const [],
  });

  int get remaining => total - completed;
  double get progress => total == 0 ? 0 : completed / total;

  HomeState copyWith({HomeStatus? status}) => HomeState(
        status: status ?? this.status,
        total: total,
        completed: completed,
        countries: countries,
        states: states,
        recentlyCompleted: recentlyCompleted,
        highPriority: highPriority,
      );

  @override
  List<Object?> get props =>
      [status, total, completed, countries, states, recentlyCompleted, highPriority];
}
