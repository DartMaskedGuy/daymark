// part of 'add_item_cubit.dart';

// enum AddItemStatus { editing, saving, saved, error }

// class AddItemState extends Equatable {
//   final AddItemStatus status;
//   final String title;
//   final String description;
//   final ItemCategory category;
//   final ItemPriority priority;
//   final String color;
//   final String? country;
//   final String? state;
//   final String? city;
//   final String? place;
//   final DateTime? targetDate;
//   final String? errorMessage;

//   const AddItemState({
//     this.status = AddItemStatus.editing,
//     this.title = '',
//     this.description = '',
//     this.category = ItemCategory.travel,
//     this.priority = ItemPriority.medium,
//     this.color = 'indigo',
//     this.country,
//     this.state,
//     this.city,
//     this.place,
//     this.targetDate,
//     this.errorMessage,
//   });

//   bool get canSave => title.trim().isNotEmpty;

//   AddItemState copyWith({
//     AddItemStatus? status,
//     String? title,
//     String? description,
//     ItemCategory? category,
//     ItemPriority? priority,
//     String? color,
//     String? country,
//     String? state,
//     String? city,
//     String? place,
//     DateTime? targetDate,
//     bool clearTargetDate = false,
//     String? errorMessage,
//   }) {
//     return AddItemState(
//       status: status ?? this.status,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       category: category ?? this.category,
//       priority: priority ?? this.priority,
//       color: color ?? this.color,
//       country: country ?? this.country,
//       state: state ?? this.state,
//       city: city ?? this.city,
//       place: place ?? this.place,
//       targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
//       errorMessage: errorMessage,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         status, title, description, category, priority, color,
//         country, state, city, place, targetDate, errorMessage,
//       ];
// }

part of 'add_item_cubit.dart';

enum AddItemStatus { editing, saving, saved, error }

class AddItemState extends Equatable {
  final AddItemStatus status;
  final String title;
  final String description;
  final ItemCategory category;
  final ItemPriority priority;
  final String color;
  final String? country;
  final String? state;
  final String? city;
  final String? place;
  final DateTime? targetDate;
  final List<String> pendingImagePaths;
  final List<MediaItem> existingMedia;
  final String? errorMessage;

  const AddItemState({
    this.status = AddItemStatus.editing,
    this.title = '',
    this.description = '',
    this.category = ItemCategory.travel,
    this.priority = ItemPriority.medium,
    this.color = 'indigo',
    this.country,
    this.state,
    this.city,
    this.place,
    this.targetDate,
    this.pendingImagePaths = const [],
    this.existingMedia = const [],
    this.errorMessage,
  });

  bool get canSave => title.trim().isNotEmpty;

  AddItemState copyWith({
    AddItemStatus? status,
    String? title,
    String? description,
    ItemCategory? category,
    ItemPriority? priority,
    String? color,
    String? country,
    String? state,
    String? city,
    String? place,
    DateTime? targetDate,
    bool clearTargetDate = false,
    List<String>? pendingImagePaths,
    List<MediaItem>? existingMedia,
    String? errorMessage,
  }) {
    return AddItemState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      place: place ?? this.place,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      pendingImagePaths: pendingImagePaths ?? this.pendingImagePaths,
      existingMedia: existingMedia ?? this.existingMedia,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    title,
    description,
    category,
    priority,
    color,
    country,
    state,
    city,
    place,
    targetDate,
    pendingImagePaths,
    existingMedia,
    errorMessage,
  ];
}
