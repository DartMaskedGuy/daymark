import 'package:drift/drift.dart';
import 'bucket_list_items_table.dart';

/// The journal entry recorded once an item is completed: notes and the
/// date the experience actually happened. One item has at most one memory.
@DataClassName('Memory')
class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()
      .references(BucketListItems, #id, onDelete: KeyAction.cascade)
      .unique()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get memoryDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
