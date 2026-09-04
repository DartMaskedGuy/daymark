import 'package:drift/drift.dart';
import 'bucket_list_items_table.dart';

/// A local photo or video attached to a bucket-list item. Only the file
/// path/metadata is stored — binary media is never duplicated into SQLite.
///
/// Explicit @DataClassName is required here: the table class is named
/// `Media`, which doesn't end in "s", so Drift can't auto-derive a
/// singular row-class name from it and would otherwise collide with the
/// table class itself. This makes the generated row class `MediaItem`,
/// matching what the DAOs/repositories reference.
@DataClassName('MediaItem')
class Media extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(BucketListItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()(); // 'image' or 'video'
  TextColumn get path => text()();
  TextColumn get thumbnailPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
