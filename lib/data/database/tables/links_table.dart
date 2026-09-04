import 'package:drift/drift.dart';
import 'bucket_list_items_table.dart';

/// An external link attached to a bucket-list item (guide, article, etc.).
@DataClassName('Link')
class Links extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(BucketListItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get url => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
