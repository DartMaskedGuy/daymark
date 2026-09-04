import 'package:drift/drift.dart';

/// A single bucket-list entry: something the user wants to do, or has done.
/// Uses a string UUID primary key so records remain stable identifiers once
/// cloud sync is introduced later.
@DataClassName('BucketListItem')
class BucketListItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  TextColumn get country => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get place => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('Medium'))();
  TextColumn get color => text().withDefault(const Constant('indigo'))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
