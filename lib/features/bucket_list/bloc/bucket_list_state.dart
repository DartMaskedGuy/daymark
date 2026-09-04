part of 'bucket_list_cubit.dart';

enum BucketListStatus { loading, ready, error }

enum BucketListFilterTab { all, todo, completed }

enum SortOption { recentlyAdded, oldestAdded, alphabetical, priority, targetDate, recentlyCompleted }

class BucketListFilters extends Equatable {
  final String? country;
  final String? state;
  final ItemCategory? category;
  final ItemPriority? priority;

  const BucketListFilters({this.country, this.state, this.category, this.priority});

  bool get isEmpty => country == null && state == null && category == null && priority == null;

  BucketListFilters copyWith({
    String? country,
    bool clearCountry = false,
    String? state,
    bool clearState = false,
    ItemCategory? category,
    bool clearCategory = false,
    ItemPriority? priority,
    bool clearPriority = false,
  }) {
    return BucketListFilters(
      country: clearCountry ? null : (country ?? this.country),
      state: clearState ? null : (state ?? this.state),
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
    );
  }

  @override
  List<Object?> get props => [country, state, category, priority];
}

class BucketListState extends Equatable {
  final BucketListStatus status;
  final List<BucketListItem> allItems;
  final BucketListFilterTab tab;
  final String query;
  final BucketListFilters filters;
  final SortOption sort;
  final String? errorMessage;

  const BucketListState({
    this.status = BucketListStatus.loading,
    this.allItems = const [],
    this.tab = BucketListFilterTab.all,
    this.query = '',
    this.filters = const BucketListFilters(),
    this.sort = SortOption.recentlyAdded,
    this.errorMessage,
  });

  List<BucketListItem> get visibleItems {
    var items = allItems.where((item) {
      final matchesTab = switch (tab) {
        BucketListFilterTab.all => true,
        BucketListFilterTab.todo => !item.isCompleted,
        BucketListFilterTab.completed => item.isCompleted,
      };
      if (!matchesTab) return false;

      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final haystack = [
          item.title,
          item.description ?? '',
          item.country ?? '',
          item.state ?? '',
          item.city ?? '',
          item.category,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }

      if (filters.country != null && item.country != filters.country) return false;
      if (filters.state != null && item.state != filters.state) return false;
      if (filters.category != null && item.category != filters.category!.label) {
        return false;
      }
      if (filters.priority != null && item.priority != filters.priority!.label) {
        return false;
      }
      return true;
    }).toList();

    items.sort((a, b) => switch (sort) {
          SortOption.recentlyAdded => b.createdAt.compareTo(a.createdAt),
          SortOption.oldestAdded => a.createdAt.compareTo(b.createdAt),
          SortOption.alphabetical => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          SortOption.priority => _priorityRank(b.priority).compareTo(_priorityRank(a.priority)),
          SortOption.targetDate => (a.targetDate ?? DateTime(9999))
              .compareTo(b.targetDate ?? DateTime(9999)),
          SortOption.recentlyCompleted => (b.completedAt ?? DateTime(0))
              .compareTo(a.completedAt ?? DateTime(0)),
        });

    return items;
  }

  static int _priorityRank(String label) =>
      ItemPriorityX.fromLabel(label).index;

  BucketListState copyWith({
    BucketListStatus? status,
    List<BucketListItem>? allItems,
    BucketListFilterTab? tab,
    String? query,
    BucketListFilters? filters,
    SortOption? sort,
    String? errorMessage,
  }) {
    return BucketListState(
      status: status ?? this.status,
      allItems: allItems ?? this.allItems,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allItems, tab, query, filters, sort, errorMessage];
}
