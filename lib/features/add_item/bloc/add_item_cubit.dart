import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/item_categories.dart';
import '../../../data/repositories/bucket_list_repository.dart';

part 'add_item_state.dart';

/// Drives the Add/Edit Item screen. Only title is required — every other
/// field, including location, stays optional per the product spec.
class AddItemCubit extends Cubit<AddItemState> {
  AddItemCubit(this._repository, {this.existingId})
    : super(const AddItemState()) {
    if (existingId != null) _loadExisting();
  }

  final BucketListRepository _repository;
  final String? existingId;

  Future<void> _loadExisting() async {
    final item = await _repository.getById(existingId!);
    if (item == null) return;
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
        await _repository.createItem(
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
