// import 'package:drift/drift.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/constants/item_categories.dart';
// import '../../../data/repositories/bucket_list_repository.dart';

// part 'add_item_state.dart';

// /// Drives the Add/Edit Item screen. Only title is required — every other
// /// field, including location, stays optional per the product spec.
// class AddItemCubit extends Cubit<AddItemState> {
//   AddItemCubit(this._repository, {this.existingId})
//     : super(const AddItemState()) {
//     if (existingId != null) _loadExisting();
//   }

//   final BucketListRepository _repository;
//   final String? existingId;

//   Future<void> _loadExisting() async {
//     final item = await _repository.getById(existingId!);
//     if (item == null) return;
//     emit(
//       state.copyWith(
//         title: item.title,
//         description: item.description ?? '',
//         category: ItemCategoryX.fromLabel(item.category),
//         priority: ItemPriorityX.fromLabel(item.priority),
//         color: item.color,
//         country: item.country,
//         state: item.state,
//         city: item.city,
//         place: item.place,
//         targetDate: item.targetDate,
//       ),
//     );
//   }

//   void titleChanged(String value) => emit(state.copyWith(title: value));
//   void descriptionChanged(String value) =>
//       emit(state.copyWith(description: value));
//   void categoryChanged(ItemCategory value) =>
//       emit(state.copyWith(category: value));
//   void priorityChanged(ItemPriority value) =>
//       emit(state.copyWith(priority: value));
//   void colorChanged(String value) => emit(state.copyWith(color: value));
//   void countryChanged(String? value) => emit(state.copyWith(country: value));
//   void stateChanged(String? value) => emit(state.copyWith(state: value));
//   void cityChanged(String? value) => emit(state.copyWith(city: value));
//   void placeChanged(String? value) => emit(state.copyWith(place: value));
//   void targetDateChanged(DateTime? value) => value == null
//       ? emit(state.copyWith(clearTargetDate: true))
//       : emit(state.copyWith(targetDate: value));

//   Future<void> save() async {
//     if (!state.canSave) return;
//     emit(state.copyWith(status: AddItemStatus.saving));
//     try {
//       if (existingId != null) {
//         final existing = await _repository.getById(existingId!);
//         if (existing != null) {
//           await _repository.updateItem(
//             existing.copyWith(
//               title: state.title.trim(),
//               description: Value(
//                 state.description.trim().isEmpty
//                     ? null
//                     : state.description.trim(),
//               ),
//               category: state.category.label,
//               priority: state.priority.label,
//               color: state.color,
//               country: Value(state.country),
//               state: Value(state.state),
//               city: Value(state.city),
//               place: Value(state.place),
//               targetDate: Value(state.targetDate),
//             ),
//           );
//         }
//       } else {
//         await _repository.createItem(
//           title: state.title.trim(),
//           description: state.description.trim().isEmpty
//               ? null
//               : state.description.trim(),
//           category: state.category.label,
//           priority: state.priority.label,
//           color: state.color,
//           country: state.country,
//           state: state.state,
//           city: state.city,
//           place: state.place,
//           targetDate: state.targetDate,
//         );
//       }
//       emit(state.copyWith(status: AddItemStatus.saved));
//     } catch (_) {
//       emit(
//         state.copyWith(
//           status: AddItemStatus.error,
//           errorMessage: 'Something went wrong while saving this item.',
//         ),
//       );
//     }
//   }
// }

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/item_categories.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';

part 'add_item_state.dart';

/// Drives the Add/Edit Item screen. Only title is required — every other
/// field, including location, stays optional per the product spec.
///
/// Image handling has two paths, because a new item has no id yet:
/// - Editing an existing item: a picked photo is written to [MediaRepository]
///   immediately, independent of the "Save changes" button.
/// - Creating a new item: picked photos sit in [AddItemState.pendingImagePaths]
///   and are only persisted once [save] creates the item and has an id
///   to attach them to.
class AddItemCubit extends Cubit<AddItemState> {
  AddItemCubit(this._repository, this._mediaRepository, {this.existingId})
    : super(const AddItemState()) {
    if (existingId != null) _loadExisting();
  }

  final BucketListRepository _repository;
  final MediaRepository _mediaRepository;
  final String? existingId;
  final ImagePicker _picker = ImagePicker();

  Future<void> _loadExisting() async {
    final item = await _repository.getById(existingId!);
    if (item == null) return;
    final media = await _mediaRepository.watchForItem(existingId!).first;
    emit(
      state.copyWith(
        title: item.title,
        description: item.description ?? '',
        category: ItemCategoryX.fromLabel(item.category),
        priority: ItemPriorityX.fromLabel(item.priority),
        color: item.color,
        country: item.country,
        state: item.state,
        city: item.city,
        place: item.place,
        targetDate: item.targetDate,
        existingMedia: media,
      ),
    );
  }

  void titleChanged(String value) => emit(state.copyWith(title: value));
  void descriptionChanged(String value) =>
      emit(state.copyWith(description: value));
  void categoryChanged(ItemCategory value) =>
      emit(state.copyWith(category: value));
  void priorityChanged(ItemPriority value) =>
      emit(state.copyWith(priority: value));
  void colorChanged(String value) => emit(state.copyWith(color: value));
  void countryChanged(String? value) => emit(state.copyWith(country: value));
  void stateChanged(String? value) => emit(state.copyWith(state: value));
  void cityChanged(String? value) => emit(state.copyWith(city: value));
  void placeChanged(String? value) => emit(state.copyWith(place: value));
  void targetDateChanged(DateTime? value) => value == null
      ? emit(state.copyWith(clearTargetDate: true))
      : emit(state.copyWith(targetDate: value));

  Future<void> pickImages() async {
    try {
      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;

      if (existingId != null) {
        for (final file in picked) {
          await _mediaRepository.addMedia(
            itemId: existingId!,
            type: 'image',
            path: file.path,
          );
        }
        final media = await _mediaRepository.watchForItem(existingId!).first;
        emit(state.copyWith(existingMedia: media));
      } else {
        emit(
          state.copyWith(
            pendingImagePaths: [
              ...state.pendingImagePaths,
              ...picked.map((file) => file.path),
            ],
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Something went wrong while adding photos.',
        ),
      );
    }
  }

  void removePendingImage(String path) {
    emit(
      state.copyWith(
        pendingImagePaths: state.pendingImagePaths
            .where((p) => p != path)
            .toList(),
      ),
    );
  }

  Future<void> removeExistingMedia(String id) async {
    try {
      await _mediaRepository.removeMedia(id);
      emit(
        state.copyWith(
          existingMedia: state.existingMedia.where((m) => m.id != id).toList(),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Something went wrong while removing this photo.',
        ),
      );
    }
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(status: AddItemStatus.saving));
    try {
      if (existingId != null) {
        final existing = await _repository.getById(existingId!);
        if (existing != null) {
          await _repository.updateItem(
            existing.copyWith(
              title: state.title.trim(),
              description: Value(
                state.description.trim().isEmpty
                    ? null
                    : state.description.trim(),
              ),
              category: state.category.label,
              priority: state.priority.label,
              color: state.color,
              country: Value(state.country),
              state: Value(state.state),
              city: Value(state.city),
              place: Value(state.place),
              targetDate: Value(state.targetDate),
            ),
          );
        }
      } else {
        final newId = await _repository.createItem(
          title: state.title.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          category: state.category.label,
          priority: state.priority.label,
          color: state.color,
          country: state.country,
          state: state.state,
          city: state.city,
          place: state.place,
          targetDate: state.targetDate,
        );
        for (final path in state.pendingImagePaths) {
          await _mediaRepository.addMedia(
            itemId: newId,
            type: 'image',
            path: path,
          );
        }
      }
      emit(state.copyWith(status: AddItemStatus.saved));
    } catch (_) {
      emit(
        state.copyWith(
          status: AddItemStatus.error,
          errorMessage: 'Something went wrong while saving this item.',
        ),
      );
    }
  }
}
