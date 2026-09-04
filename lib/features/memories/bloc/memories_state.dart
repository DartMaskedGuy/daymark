part of 'memories_cubit.dart';

enum MemoriesStatus { loading, ready, error }

class MemoriesState extends Equatable {
  final MemoriesStatus status;
  final List<BucketListItem> items;

  const MemoriesState({this.status = MemoriesStatus.loading, this.items = const []});

  MemoriesState copyWith({MemoriesStatus? status}) =>
      MemoriesState(status: status ?? this.status, items: items);

  @override
  List<Object?> get props => [status, items];
}
